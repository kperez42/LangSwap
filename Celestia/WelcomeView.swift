//
//  WelcomeView.swift
//  LangSwap
//
//  Welcome screen for the language exchange app
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authService: AuthService
    @State private var currentFeature = 0
    @State private var animateGradient = false
    @State private var showContent = false
    @State private var featureTimer: Timer?
    @State private var showAwarenessSlides = false
    @State private var navigateToSignUp = false

    // Legal document sheets
    @State private var showTermsOfService = false
    @State private var showPrivacyPolicy = false

    let features = [
        Feature(icon: "globe", title: "Find Language Partners", description: "Connect with native speakers worldwide"),
        Feature(icon: "arrow.triangle.2.circlepath", title: "Complementary Matching", description: "Learn from each other - you teach, they teach"),
        Feature(icon: "message.fill", title: "Practice Together", description: "Video calls, voice messages, and text chat")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                animatedBackground

                // Floating particles
                floatingParticles

                // Main content
                VStack(spacing: 0) {
                    Spacer()

                    // Logo & branding
                    logoSection
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : -30)

                    Spacer()

                    // Feature carousel
                    featureCarousel
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)

                    Spacer()

                    // CTA Buttons
                    ctaButtons
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)
                        .padding(.bottom, 50)
                }
            }
            .ignoresSafeArea()
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    showContent = true
                }
                startFeatureTimer()
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    animateGradient = true
                }
            }
            .onDisappear {
                featureTimer?.invalidate()
                featureTimer = nil
            }
            .fullScreenCover(isPresented: $showAwarenessSlides) {
                WelcomeAwarenessSlidesView {
                    showAwarenessSlides = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        navigateToSignUp = true
                    }
                }
            }
            .sheet(isPresented: $showTermsOfService) {
                LegalDocumentView(documentType: .termsOfService)
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                LegalDocumentView(documentType: .privacyPolicy)
            }
        }
    }

    // MARK: - Animated Background

    private var animatedBackground: some View {
        ZStack {
            // Base gradient - Blue/Teal theme for language learning
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.9),
                    Color.teal.opacity(0.8),
                    Color.cyan.opacity(0.7)
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )

            // Overlay gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.3),
                    Color.clear,
                    Color.teal.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - Floating Particles

    private var floatingParticles: some View {
        GeometryReader { geometry in
            let safeWidth = max(geometry.size.width, 1)
            let safeHeight = max(geometry.size.height, 1)

            ZStack {
                ForEach(0..<20, id: \.self) { index in
                    FloatingParticle(
                        size: CGFloat.random(in: 4...12),
                        x: CGFloat.random(in: 0...safeWidth),
                        y: CGFloat.random(in: 0...safeHeight),
                        duration: Double.random(in: 3...6)
                    )
                }
            }
        }
    }

    // MARK: - Logo Section

    private var logoSection: some View {
        VStack(spacing: 20) {
            // Animated globe icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)

                Image(systemName: "globe")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .cyan.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .white.opacity(0.5), radius: 20)
            }

            VStack(spacing: 8) {
                Text("LangSwap")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 5)

                Text("Find your language exchange partner")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .shadow(color: .black.opacity(0.1), radius: 3)
            }
        }
    }

    // MARK: - Feature Carousel

    private var featureCarousel: some View {
        VStack(spacing: 20) {
            FeatureCard(feature: features[currentFeature])
                .accessibleTransition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(features[currentFeature].title). \(features[currentFeature].description)")

            // Pagination dots
            HStack(spacing: 10) {
                ForEach(0..<features.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentFeature ? Color.white : Color.white.opacity(0.4))
                        .frame(width: index == currentFeature ? 12 : 8, height: index == currentFeature ? 12 : 8)
                        .scaleEffect(index == currentFeature ? 1.0 : 0.85)
                        .accessibleAnimation(.spring(response: 0.3), value: currentFeature)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Feature page indicator")
            .accessibilityValue("Page \(currentFeature + 1) of \(features.count)")
        }
        .padding(.horizontal, 30)
    }

    // MARK: - CTA Buttons

    private var ctaButtons: some View {
        VStack(spacing: 15) {
            // Create Account - Primary
            Button {
                HapticManager.shared.impact(.medium)
                showAwarenessSlides = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "person.badge.plus")
                        .font(.headline)

                    Text("Start Learning")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    ZStack {
                        Color.white

                        LinearGradient(
                            colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.3),
                                Color.white.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .offset(x: animateGradient ? 200 : -200)
                    }
                )
                .cornerRadius(28)
                .shadow(color: .white.opacity(0.5), radius: 15, y: 5)
            }
            .accessibilityLabel("Start Learning")
            .accessibilityHint("Create your LangSwap account")
            .accessibilityIdentifier(AccessibilityIdentifier.signUpButton)
            .scaleButton()

            // Hidden NavigationLink
            NavigationLink(destination: SignUpView(), isActive: $navigateToSignUp) {
                EmptyView()
            }
            .hidden()

            // Sign In - Secondary
            NavigationLink {
                LoginView()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.headline)

                    Text("Sign In")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.white.opacity(0.2))
                .cornerRadius(28)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                )
            }
            .accessibilityLabel("Sign In")
            .accessibilityHint("Sign in to your existing account")
            .accessibilityIdentifier(AccessibilityIdentifier.signInButton)
            .scaleButton()

            // Terms & Privacy
            VStack(spacing: 8) {
                Text("By continuing, you agree to our")
                    .font(.caption)

                HStack(spacing: 8) {
                    Button("Terms of Service") {
                        showTermsOfService = true
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .underline()

                    Text("&")
                        .font(.caption)

                    Button("Privacy Policy") {
                        showPrivacyPolicy = true
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .underline()
                }
            }
            .foregroundColor(.white.opacity(0.9))
            .padding(.top, 5)
        }
        .padding(.horizontal, 40)
    }

    private func startFeatureTimer() {
        featureTimer?.invalidate()
        featureTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                currentFeature = (currentFeature + 1) % features.count
            }
        }
    }
}

// MARK: - Feature Card

struct FeatureCard: View {
    let feature: Feature

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .blur(radius: 15)

                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: feature.icon)
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            VStack(spacing: 8) {
                Text(feature.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(feature.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.15))
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Floating Particle

struct FloatingParticle: View {
    let size: CGFloat
    let x: CGFloat
    let y: CGFloat
    let duration: Double

    @State private var isAnimating = false

    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.3))
            .frame(width: size, height: size)
            .blur(radius: 2)
            .position(x: x, y: y)
            .offset(y: isAnimating ? -100 : 100)
            .opacity(isAnimating ? 0 : 1)
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Feature Model

struct Feature {
    let icon: String
    let title: String
    let description: String
}

// MARK: - Welcome Awareness Slides View

struct WelcomeAwarenessSlidesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    let onComplete: () -> Void

    let slides: [AwarenessSlide] = [
        AwarenessSlide(
            icon: "globe",
            title: "Welcome to LangSwap!",
            description: "Connect with language learners worldwide and practice together.",
            color: .blue,
            tips: [
                "Learn from native speakers",
                "Teach your language in return",
                "Practice through conversation"
            ]
        ),
        AwarenessSlide(
            icon: "arrow.triangle.2.circlepath",
            title: "How It Works",
            description: "LangSwap matches you with complementary language partners - you teach each other!",
            color: .teal,
            tips: [
                "Add languages you speak natively",
                "Add languages you want to learn",
                "Get matched with ideal partners"
            ]
        ),
        AwarenessSlide(
            icon: "person.2.fill",
            title: "Find Partners",
            description: "Browse profiles of language learners who want to practice with you.",
            color: .blue,
            tips: [
                "Filter by language and proficiency",
                "See shared learning goals",
                "Connect with like-minded learners"
            ]
        ),
        AwarenessSlide(
            icon: "bubble.left.and.bubble.right.fill",
            title: "Practice Together",
            description: "Choose how you want to practice - video calls, voice messages, or text chat.",
            color: .cyan,
            tips: [
                "Schedule video call sessions",
                "Exchange voice messages",
                "Practice through text conversations"
            ]
        ),
        AwarenessSlide(
            icon: "chart.line.uptrend.xyaxis",
            title: "Track Your Progress",
            description: "Set learning goals and track your language learning journey.",
            color: .green,
            tips: [
                "Set clear learning objectives",
                "Practice regularly with partners",
                "Improve through real conversations"
            ]
        ),
        AwarenessSlide(
            icon: "shield.checkered",
            title: "Stay Safe",
            description: "Your safety is our priority. We verify profiles and provide reporting tools.",
            color: .orange,
            tips: [
                "All profiles are reviewed",
                "Report inappropriate behavior",
                "Block users you're uncomfortable with",
                "Meet in public for in-person practice"
            ]
        )
    ]

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with progress and skip
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage >= index ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: currentPage == index ? 10 : 8, height: currentPage == index ? 10 : 8)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentPage)
                        }
                    }

                    HStack {
                        Spacer()
                        Button {
                            onComplete()
                        } label: {
                            Text("Skip")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // Swipeable slides
                TabView(selection: $currentPage) {
                    ForEach(Array(slides.enumerated()), id: \.element.id) { index, slide in
                        AwarenessSlideView(slide: slide)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Navigation buttons
                HStack(spacing: 15) {
                    if currentPage > 0 {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                currentPage -= 1
                                HapticManager.shared.impact(.light)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.left")
                                    .font(.subheadline.weight(.semibold))
                                Text("Back")
                                    .font(.headline)
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                        }
                    }

                    Button {
                        if currentPage < slides.count - 1 {
                            withAnimation(.spring(response: 0.3)) {
                                currentPage += 1
                                HapticManager.shared.impact(.medium)
                            }
                        } else {
                            HapticManager.shared.notification(.success)
                            onComplete()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(currentPage < slides.count - 1 ? "Next" : "Get Started")
                                .font(.headline)

                            Image(systemName: currentPage < slides.count - 1 ? "arrow.right" : "arrow.right.circle.fill")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.teal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
    }
}

// MARK: - Awareness Slide Model

struct AwarenessSlide: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
    let tips: [String]
}

// MARK: - Awareness Slide View

struct AwarenessSlideView: View {
    let slide: AwarenessSlide

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 20)

                // Header card with icon
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.12))
                            .frame(width: 80, height: 80)

                        Image(systemName: slide.icon)
                            .font(.system(size: 36))
                            .foregroundColor(.blue)
                    }

                    VStack(spacing: 10) {
                        Text(slide.title)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)

                        Text(slide.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                )
                .padding(.horizontal, 24)

                // Tips card
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.12))
                                .frame(width: 44, height: 44)

                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.blue)
                        }

                        Text("Quick Tips")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(slide.tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.body)
                                    .foregroundColor(.blue)

                                Text(tip)
                                    .font(.subheadline)
                                    .foregroundColor(.primary.opacity(0.8))

                                Spacer()
                            }
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                )
                .padding(.horizontal, 24)

                Spacer(minLength: 20)
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthService.shared)
}

#Preview("Awareness Slides") {
    WelcomeAwarenessSlidesView {
        print("Completed")
    }
}
