import SwiftUI

struct SingleValueSlider: View {
    @Binding var value: Int

    let bounds: ClosedRange<Int>

    private let thumbSize: CGFloat = 26
    private let trackHeight: CGFloat = 6

    var body: some View {
        GeometryReader { geometry in
            let usableWidth = max(1, geometry.size.width - thumbSize)
            let centerX = xPosition(for: value, usableWidth: usableWidth)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: trackHeight)
                    .padding(.horizontal, thumbSize / 2)

                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: max(0, centerX - (thumbSize / 2)), height: trackHeight)
                    .offset(x: thumbSize / 2)

                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: centerX - (thumbSize / 2))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                self.value = valueForLocationX(value.location.x, usableWidth: usableWidth)
                            }
                    )
            }
            .frame(maxHeight: .infinity)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Radius Slider")
        .accessibilityValue("\(value)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                value = min(value + 1, bounds.upperBound)
            case .decrement:
                value = max(value - 1, bounds.lowerBound)
            @unknown default:
                break
            }
        }
    }

    private func xPosition(for value: Int, usableWidth: CGFloat) -> CGFloat {
        let range = CGFloat(bounds.upperBound - bounds.lowerBound)
        guard range > 0 else { return thumbSize / 2 }
        let fraction = CGFloat(value - bounds.lowerBound) / range
        return (thumbSize / 2) + (fraction * usableWidth)
    }

    private func valueForLocationX(_ locationX: CGFloat, usableWidth: CGFloat) -> Int {
        let clampedX = min(max(locationX, thumbSize / 2), usableWidth + (thumbSize / 2))
        let fraction = (clampedX - (thumbSize / 2)) / usableWidth
        let rawValue = CGFloat(bounds.lowerBound) + (fraction * CGFloat(bounds.upperBound - bounds.lowerBound))
        return min(max(Int(round(rawValue)), bounds.lowerBound), bounds.upperBound)
    }
}
