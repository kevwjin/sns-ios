import SwiftUI

struct SlideToEnrollControl: View {
    let isEnrolledInBatch: Bool
    var isEnabled: Bool = true
    let resetTrigger: Int
    var disabledText = "Add availability to enroll"
    let onCompleted: () -> Void

    @State private var knobOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let trackHeight: CGFloat = 56
            let knobInset: CGFloat = 4
            let knobSize = trackHeight - (knobInset * 2)
            let maxOffset = geometry.size.width - knobSize - (knobInset * 2)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(isEnabled || isEnrolledInBatch ? 0.18 : 0.1))

                Text(sliderText)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)

                ZStack {
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.12), radius: 3, y: 1)

                    Image(systemName: knobSystemImage)
                        .font(.headline)
                        .foregroundStyle(knobColor)
                }
                .frame(width: knobSize, height: knobSize)
                .offset(x: isEnrolledInBatch ? maxOffset + knobInset : knobOffset + knobInset)
            }
            .frame(height: trackHeight)
            .contentShape(Rectangle())
            .accessibilityElement(children: .contain)
            .accessibilityLabel(sliderText)
            .accessibilityIdentifier("Weekly Batch Enrollment Slider")
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard isEnabled, !isEnrolledInBatch else { return }
                        knobOffset = min(max(0, value.translation.width), maxOffset)
                    }
                    .onEnded { _ in
                        guard isEnabled, !isEnrolledInBatch else { return }

                        if knobOffset >= (maxOffset * 0.85) {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                knobOffset = maxOffset
                            }
                            onCompleted()
                        } else {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                knobOffset = 0
                            }
                        }
                    }
            )
        }
        .frame(height: 56)
        .opacity(isEnabled || isEnrolledInBatch ? 1 : 0.65)
        .onChange(of: resetTrigger) { _, _ in
            guard !isEnrolledInBatch else { return }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                knobOffset = 0
            }
        }
        .onChange(of: isEnabled) { _, newValue in
            guard !newValue, !isEnrolledInBatch else { return }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                knobOffset = 0
            }
        }
    }

    private var sliderText: String {
        if isEnrolledInBatch {
            return "Enrolled"
        }

        return isEnabled ? "Slide to Enroll" : disabledText
    }

    private var knobSystemImage: String {
        if isEnrolledInBatch {
            return "checkmark"
        }

        return isEnabled ? "chevron.right" : "lock.fill"
    }

    private var knobColor: Color {
        if isEnrolledInBatch {
            return .green
        }

        return isEnabled ? .gray : .secondary
    }
}
