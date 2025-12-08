//
//  SwipeService.swift
//  LangSwap
//
//  Service for handling swipes (connections/skips) and creating language partner matches
//

import Foundation
import Firebase
import FirebaseFirestore

// MARK: - Connection Retry Configuration

private struct ConnectionRetryConfig {
    static let maxRetries = 3
    static let baseDelaySeconds: Double = 0.5
    static let maxDelaySeconds: Double = 4.0

    static func delay(for attempt: Int) -> TimeInterval {
        let delay = baseDelaySeconds * pow(2.0, Double(attempt))
        // Add jitter to prevent thundering herd
        let jitter = Double.random(in: 0...0.3)
        return min(delay + jitter, maxDelaySeconds)
    }
}

@MainActor
class SwipeService: ObservableObject, SwipeServiceProtocol {
    // Dependency injection: Repository for data access
    private let repository: SwipeRepository
    private let matchService: MatchService

    // Track pending operations for recovery
    private var pendingConnections: Set<String> = []

    // Singleton for backward compatibility (uses default repository)
    static let shared = SwipeService(
        repository: FirestoreSwipeRepository(),
        matchService: MatchService.shared
    )

    // Dependency injection initializer
    init(repository: SwipeRepository, matchService: MatchService) {
        self.repository = repository
        self.matchService = matchService
    }

    /// Record a connection request from user1 to user2 and check for mutual language partner match
    /// This method includes retry logic and is designed to be error-proof
    func likeUser(fromUserId: String, toUserId: String, isSuperLike: Bool = false) async throws -> Bool {
        // SECURITY: Validate input parameters
        guard !fromUserId.isEmpty, !toUserId.isEmpty else {
            Logger.shared.error("Invalid user IDs: fromUserId='\(fromUserId)', toUserId='\(toUserId)'", category: .matching)
            throw CelestiaError.invalidInput("User IDs cannot be empty")
        }

        guard fromUserId != toUserId else {
            Logger.shared.warning("Attempted self-connection prevented: \(fromUserId)", category: .matching)
            throw CelestiaError.invalidOperation("Cannot connect with yourself")
        }

        // Create unique operation ID for tracking
        let operationId = "\(fromUserId)_\(toUserId)"

        // Prevent duplicate concurrent operations
        guard !pendingConnections.contains(operationId) else {
            Logger.shared.warning("Connection operation already in progress: \(operationId)", category: .matching)
            throw CelestiaError.invalidOperation("Connection already in progress")
        }

        pendingConnections.insert(operationId)
        defer { pendingConnections.remove(operationId) }

        // SECURITY: Backend rate limit validation for swipes
        try await validateRateLimit(userId: fromUserId, isSuperLike: isSuperLike)

        // Save the connection with retry logic
        try await createConnectionWithRetry(
            fromUserId: fromUserId,
            toUserId: toUserId,
            isSuperConnect: isSuperLike
        )

        // Check for mutual connection with retry logic
        let isMutualConnection = await checkMutualConnectionWithRetry(fromUserId: fromUserId, toUserId: toUserId)

        if isMutualConnection {
            // Language partner found! Create the match
            Logger.shared.info("🎉 Mutual connection detected! Creating language partner match: \(fromUserId) <-> \(toUserId)", category: .matching)
            await matchService.createMatch(user1Id: fromUserId, user2Id: toUserId)
            return true
        }

        Logger.shared.debug("✅ Connection request recorded successfully: \(fromUserId) -> \(toUserId)", category: .matching)
        return false
    }

    // MARK: - Private Helper Methods

    /// Validate rate limit with fallback
    private func validateRateLimit(userId: String, isSuperLike: Bool) async throws {
        do {
            let action: RateLimitAction = isSuperLike ? .sendSuperConnect : .swipe
            let rateLimitResponse = try await BackendAPIService.shared.checkRateLimit(
                userId: userId,
                action: action
            )

            if !rateLimitResponse.allowed {
                Logger.shared.warning("Backend rate limit exceeded for swipes", category: .matching)

                if let retryAfter = rateLimitResponse.retryAfter {
                    throw CelestiaError.rateLimitExceededWithTime(retryAfter)
                }

                throw CelestiaError.rateLimitExceeded
            }

            Logger.shared.debug("✅ Backend rate limit check passed for swipe (remaining: \(rateLimitResponse.remaining))", category: .matching)

        } catch let error as BackendAPIError {
            // Backend rate limit service unavailable - use client-side fallback
            Logger.shared.warning("Backend rate limit check failed - using client-side fallback: \(error)", category: .matching)

            // Client-side rate limiting fallback
            if !isSuperLike {
                guard RateLimiter.shared.canSendConnection() else {
                    throw CelestiaError.rateLimitExceeded
                }
            }
        } catch let error as CelestiaError {
            // Re-throw rate limit errors
            throw error
        } catch {
            // For other errors, allow the operation (fail open for better UX)
            Logger.shared.warning("Rate limit check failed with unexpected error, proceeding anyway: \(error)", category: .matching)
        }
    }

    /// Create connection with automatic retry on transient failures
    private func createConnectionWithRetry(fromUserId: String, toUserId: String, isSuperConnect: Bool) async throws {
        var lastError: Error?

        for attempt in 0..<ConnectionRetryConfig.maxRetries {
            do {
                try await repository.createLike(fromUserId: fromUserId, toUserId: toUserId, isSuperLike: isSuperConnect)
                return // Success!
            } catch {
                lastError = error

                // Check if error is retryable
                if isRetryableError(error) && attempt < ConnectionRetryConfig.maxRetries - 1 {
                    let delay = ConnectionRetryConfig.delay(for: attempt)
                    Logger.shared.warning("Connection failed (attempt \(attempt + 1)/\(ConnectionRetryConfig.maxRetries)), retrying in \(delay)s: \(error.localizedDescription)", category: .matching)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                } else {
                    // Non-retryable error or max retries reached
                    break
                }
            }
        }

        // All retries failed
        Logger.shared.error("Connection failed after \(ConnectionRetryConfig.maxRetries) attempts", category: .matching, error: lastError)
        throw lastError ?? CelestiaError.networkError
    }

    /// Check mutual connection with retry logic - never miss a language partner match!
    private func checkMutualConnectionWithRetry(fromUserId: String, toUserId: String) async -> Bool {
        var lastError: Error?

        for attempt in 0..<ConnectionRetryConfig.maxRetries {
            do {
                let isMutual = try await repository.checkMutualLike(fromUserId: fromUserId, toUserId: toUserId)
                return isMutual
            } catch {
                lastError = error

                if attempt < ConnectionRetryConfig.maxRetries - 1 {
                    let delay = ConnectionRetryConfig.delay(for: attempt)
                    Logger.shared.warning("Mutual connection check failed (attempt \(attempt + 1)/\(ConnectionRetryConfig.maxRetries)), retrying in \(delay)s", category: .matching)
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }

        // Log error but don't fail the connection - partner match will be detected on next sync
        Logger.shared.error("Mutual connection check failed after retries, partner match may be detected later", category: .matching, error: lastError)

        // Schedule a background recheck
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            await self.recheckForMissedPartnerMatch(fromUserId: fromUserId, toUserId: toUserId)
        }

        return false
    }

    /// Background recheck for missed language partner matches
    private func recheckForMissedPartnerMatch(fromUserId: String, toUserId: String) async {
        do {
            let isMutual = try await repository.checkMutualLike(fromUserId: fromUserId, toUserId: toUserId)
            if isMutual {
                Logger.shared.info("🎉 Delayed mutual language partner match detected: \(fromUserId) <-> \(toUserId)", category: .matching)
                await matchService.createMatch(user1Id: fromUserId, user2Id: toUserId)
            }
        } catch {
            Logger.shared.error("Background mutual connection check failed", category: .matching, error: error)
        }
    }

    /// Check if an error is retryable (transient network issues)
    private func isRetryableError(_ error: Error) -> Bool {
        let nsError = error as NSError

        // Network errors
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet,
                 NSURLErrorNetworkConnectionLost,
                 NSURLErrorTimedOut,
                 NSURLErrorCannotFindHost,
                 NSURLErrorCannotConnectToHost,
                 NSURLErrorDNSLookupFailed:
                return true
            default:
                return false
            }
        }

        // Firebase-specific errors (unavailable, deadline exceeded)
        if nsError.domain == "FIRFirestoreErrorDomain" {
            // 14 = UNAVAILABLE, 4 = DEADLINE_EXCEEDED
            return nsError.code == 14 || nsError.code == 4
        }

        return false
    }

    /// Record a pass (swipe left)
    func passUser(fromUserId: String, toUserId: String) async throws {
        // SECURITY: Backend rate limit validation for passes/swipes
        do {
            let rateLimitResponse = try await BackendAPIService.shared.checkRateLimit(
                userId: fromUserId,
                action: .swipe
            )

            if !rateLimitResponse.allowed {
                Logger.shared.warning("Backend rate limit exceeded for passes", category: .matching)

                if let retryAfter = rateLimitResponse.retryAfter {
                    throw CelestiaError.rateLimitExceededWithTime(retryAfter)
                }

                throw CelestiaError.rateLimitExceeded
            }

            Logger.shared.debug("✅ Backend rate limit check passed for pass (remaining: \(rateLimitResponse.remaining))", category: .matching)

        } catch let error as BackendAPIError {
            // Backend rate limit service unavailable - use client-side fallback
            Logger.shared.error("Backend rate limit check failed for skip - using client-side fallback", category: .matching)

            // Client-side rate limiting fallback
            guard RateLimiter.shared.canSendConnection() else {
                throw CelestiaError.rateLimitExceeded
            }
        } catch {
            // Re-throw rate limit errors
            throw error
        }

        // Save the pass via repository
        try await repository.createPass(fromUserId: fromUserId, toUserId: toUserId)
    }

    /// Check if user1 has already connected/skipped user2
    func hasSwipedOn(fromUserId: String, toUserId: String) async throws -> (liked: Bool, passed: Bool) {
        return try await repository.hasSwipedOn(fromUserId: fromUserId, toUserId: toUserId)
    }

    /// Get all users who have sent connection requests to the current user
    func getLikesReceived(userId: String) async throws -> [String] {
        return try await repository.getLikesReceived(userId: userId)
    }

    /// Get all users the current user has sent connection requests to
    func getLikesSent(userId: String) async throws -> [String] {
        return try await repository.getLikesSent(userId: userId)
    }

    /// Delete a swipe (for rewind functionality)
    func deleteSwipe(fromUserId: String, toUserId: String) async throws {
        do {
            try await repository.deleteSwipe(fromUserId: fromUserId, toUserId: toUserId)
            Logger.shared.info("Swipe deleted for rewind", category: .matching)
        } catch {
            Logger.shared.error("Error deleting swipe", category: .matching, error: error)
            throw error
        }
    }

    /// Check if user has already sent a connection request to another user
    func checkIfLiked(fromUserId: String, toUserId: String) async throws -> Bool {
        return try await repository.checkLikeExists(fromUserId: fromUserId, toUserId: toUserId)
    }

    /// Disconnect from a user (remove the connection request)
    func unlikeUser(fromUserId: String, toUserId: String) async throws {
        try await repository.unlikeUser(fromUserId: fromUserId, toUserId: toUserId)
        Logger.shared.info("User disconnected: \(fromUserId) -> \(toUserId)", category: .matching)
    }
}
