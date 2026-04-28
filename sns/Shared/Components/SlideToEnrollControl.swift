import SwiftUI

struct SlideToEnrollControl: View {
    let isEnrolledInBatch: Bool
    let resetTrigger: Int
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
                    .fill(Color.gray.opacity(0.18))

                Text(isEnrolledInBatch ? "Enrolled" : "Slide to Enroll")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)

                ZStack {
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.12), radius: 3, y: 1)

                    Image(systemName: isEnrolledInBatch ? "checkmark" : "chevron.right")
                        .font(.headline)
                        .foregroundStyle(isEnrolledInBatch ? .green : .gray)
                }
                .frame(width: knobSize, height: knobSize)
                .offset(x: isEnrolledInBatch ? maxOffset + knobInset : knobOffset + knobInset)
            }
            .frame(height: trackHeight)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard !isEnrolledInBatch else { return }
                        knobOffset = min(max(0, value.translation.width), maxOffset)
                    }
                    .onEnded { _ in
                        guard !isEnrolledInBatch else { return }

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
        .onChange(of: resetTrigger) { _, _ in
            guard !isEnrolledInBatch else { return }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                knobOffset = 0
            }
        }
    }
}
