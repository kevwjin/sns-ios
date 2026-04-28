import SwiftUI

struct AgeRangeSlider: View {
    @Binding var minValue: Int
    @Binding var maxValue: Int

    let bounds: ClosedRange<Int>

    private let thumbSize: CGFloat = 26
    private let trackHeight: CGFloat = 6

    var body: some View {
        GeometryReader { geometry in
            let usableWidth = max(1, geometry.size.width - thumbSize)
            let minCenterX = xPosition(for: minValue, usableWidth: usableWidth)
            let maxCenterX = xPosition(for: maxValue, usableWidth: usableWidth)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: trackHeight)
                    .padding(.horizontal, thumbSize / 2)

                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: max(0, maxCenterX - minCenterX), height: trackHeight)
                    .offset(x: minCenterX)

                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: minCenterX - (thumbSize / 2))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let newValue = valueForLocationX(value.location.x, usableWidth: usableWidth)
                                minValue = min(newValue, maxValue)
                            }
                    )

                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: maxCenterX - (thumbSize / 2))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let newValue = valueForLocationX(value.location.x, usableWidth: usableWidth)
                                maxValue = max(newValue, minValue)
                            }
                    )
            }
            .frame(maxHeight: .infinity)
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
