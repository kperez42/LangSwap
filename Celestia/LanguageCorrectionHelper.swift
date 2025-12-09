//
//  LanguageCorrectionHelper.swift
//  LangSwap
//
//  Tools for providing and receiving language corrections during chat
//

import SwiftUI

// MARK: - Correction Model

struct LanguageCorrection: Identifiable, Codable, Hashable {
    let id: String
    let originalText: String
    let correctedText: String
    let explanation: String?
    let correctionType: CorrectionType
    let timestamp: Date
    let senderId: String

    enum CorrectionType: String, Codable, CaseIterable {
        case grammar = "Grammar"
        case spelling = "Spelling"
        case vocabulary = "Vocabulary"
        case pronunciation = "Pronunciation"
        case naturalness = "Naturalness"
        case punctuation = "Punctuation"

        var icon: String {
            switch self {
            case .grammar: return "text.badge.checkmark"
            case .spelling: return "character.cursor.ibeam"
            case .vocabulary: return "book.fill"
            case .pronunciation: return "speaker.wave.2.fill"
            case .naturalness: return "sparkles"
            case .punctuation: return "textformat.abc"
            }
        }

        var color: Color {
            switch self {
            case .grammar: return .blue
            case .spelling: return .red
            case .vocabulary: return .purple
            case .pronunciation: return .orange
            case .naturalness: return .teal
            case .punctuation: return .gray
            }
        }
    }

    init(
        id: String = UUID().uuidString,
        originalText: String,
        correctedText: String,
        explanation: String? = nil,
        correctionType: CorrectionType,
        timestamp: Date = Date(),
        senderId: String
    ) {
        self.id = id
        self.originalText = originalText
        self.correctedText = correctedText
        self.explanation = explanation
        self.correctionType = correctionType
        self.timestamp = timestamp
        self.senderId = senderId
    }
}

// MARK: - Correction Input View

struct CorrectionInputView: View {
    let originalText: String
    let onSubmit: (LanguageCorrection) -> Void
    @Environment(\.dismiss) var dismiss

    @State private var correctedText: String
    @State private var explanation = ""
    @State private var selectedType: LanguageCorrection.CorrectionType = .grammar
    @State private var showTypeSelector = false

    init(originalText: String, onSubmit: @escaping (LanguageCorrection) -> Void) {
        self.originalText = originalText
        self.onSubmit = onSubmit
        self._correctedText = State(initialValue: originalText)
    }

    var body: some View {
        NavigationStack {
            Form {
                // Original Text
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Original", systemImage: "text.quote")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(originalText)
                            .font(.body)
                            .padding(12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                // Corrected Text
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Correction", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("Enter the corrected text", text: $correctedText, axis: .vertical)
                            .lineLimit(3...6)
                            .padding(12)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                // Correction Type
                Section("Type of Correction") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(LanguageCorrection.CorrectionType.allCases, id: \.self) { type in
                                CorrectionTypeChip(
                                    type: type,
                                    isSelected: selectedType == type
                                ) {
                                    selectedType = type
                                }
                            }
                        }
                    }
                }

                // Explanation (Optional)
                Section("Explanation (Optional)") {
                    TextField("Why is this correction helpful?", text: $explanation, axis: .vertical)
                        .lineLimit(2...4)
                }

                // Preview
                Section("Preview") {
                    CorrectionBubblePreview(
                        original: originalText,
                        corrected: correctedText,
                        type: selectedType,
                        explanation: explanation.isEmpty ? nil : explanation
                    )
                }
            }
            .navigationTitle("Suggest Correction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send") {
                        let correction = LanguageCorrection(
                            originalText: originalText,
                            correctedText: correctedText,
                            explanation: explanation.isEmpty ? nil : explanation,
                            correctionType: selectedType,
                            senderId: AuthService.shared.currentUser?.id ?? ""
                        )
                        onSubmit(correction)
                        dismiss()
                    }
                    .disabled(correctedText.isEmpty || correctedText == originalText)
                }
            }
        }
    }
}

struct CorrectionTypeChip: View {
    let type: LanguageCorrection.CorrectionType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: type.icon)
                    .font(.caption)
                Text(type.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? type.color : Color.gray.opacity(0.15))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

struct CorrectionBubblePreview: View {
    let original: String
    let corrected: String
    let type: LanguageCorrection.CorrectionType
    let explanation: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.caption)
                    .foregroundColor(type.color)

                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(type.color)
            }

            // Correction
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(original)
                        .strikethrough()
                        .foregroundColor(.red)

                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(corrected)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
                .font(.subheadline)

                if let explanation = explanation, !explanation.isEmpty {
                    Text(explanation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .padding(12)
        .background(Color.teal.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Correction Message Bubble (for display in chat)

struct CorrectionMessageBubble: View {
    let correction: LanguageCorrection
    let isFromCurrentUser: Bool

    var body: some View {
        VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
            // Label
            HStack(spacing: 4) {
                Image(systemName: "pencil.and.outline")
                    .font(.caption2)
                Text("Language Correction")
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundColor(.teal)

            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Type Badge
                HStack(spacing: 4) {
                    Image(systemName: correction.correctionType.icon)
                        .font(.caption2)
                    Text(correction.correctionType.rawValue)
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .foregroundColor(correction.correctionType.color)

                // Original → Corrected
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(correction.originalText)
                            .strikethrough()
                            .foregroundColor(.red.opacity(0.8))
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Text(correction.correctedText)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
                .font(.subheadline)

                // Explanation
                if let explanation = correction.explanation {
                    Text(explanation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
            .padding(12)
            .background(
                isFromCurrentUser
                    ? Color.teal.opacity(0.15)
                    : Color(.systemGray6)
            )
            .cornerRadius(16)
        }
    }
}

// MARK: - Quick Correction Menu

struct QuickCorrectionMenu: View {
    let messageText: String
    let onCorrect: () -> Void

    var body: some View {
        Button(action: onCorrect) {
            Label("Suggest Correction", systemImage: "pencil.and.outline")
        }
    }
}

// MARK: - Correction Stats View

struct CorrectionStatsView: View {
    let correctionsReceived: Int
    let correctionsMade: Int

    var body: some View {
        HStack(spacing: 20) {
            StatItem(
                title: "Received",
                value: correctionsReceived,
                icon: "arrow.down.circle.fill",
                color: .blue
            )

            Divider()
                .frame(height: 40)

            StatItem(
                title: "Given",
                value: correctionsMade,
                icon: "arrow.up.circle.fill",
                color: .green
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private struct StatItem: View {
        let title: String
        let value: Int
        let icon: String
        let color: Color

        var body: some View {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text("\(value)")
                    .font(.title3.bold())

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Previews

#Preview("Correction Input") {
    CorrectionInputView(originalText: "I goed to the store yesterday") { correction in
        print("Correction: \(correction)")
    }
}

#Preview("Correction Bubble") {
    VStack(spacing: 16) {
        CorrectionMessageBubble(
            correction: LanguageCorrection(
                originalText: "I goed to store",
                correctedText: "I went to the store",
                explanation: "Use 'went' (past tense of 'go') instead of 'goed'",
                correctionType: .grammar,
                senderId: "user1"
            ),
            isFromCurrentUser: true
        )

        CorrectionMessageBubble(
            correction: LanguageCorrection(
                originalText: "Their going to the park",
                correctedText: "They're going to the park",
                explanation: "Use 'they're' (they are) instead of 'their' (possessive)",
                correctionType: .spelling,
                senderId: "user2"
            ),
            isFromCurrentUser: false
        )
    }
    .padding()
}

#Preview("Correction Stats") {
    CorrectionStatsView(correctionsReceived: 15, correctionsMade: 23)
        .padding()
}
