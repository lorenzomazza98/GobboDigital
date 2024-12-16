import SwiftUI

// TimerCircleView is a reusable SwiftUI component that displays a circular timer with customizable labels, icons, and colors.
struct TimerCircleView: View {
    // Properties:
    // - title: The subtitle displayed below the timer.
    // - iconLeft: System image name for the optional left icon.
    // - iconRight: System image name for the optional right icon.
    // - timeRemaining: Text displaying the remaining time inside the circle.
    // - color: Color of the circular stroke and icons.
    // - circleSize: Diameter of the circle; determines the size of all elements.
    var title: String
    var iconLeft: String
    var iconRight: String
    var timeRemaining: String
    var color: Color
    var circleSize: CGFloat

    var body: some View {
        ZStack { // ZStack layers the circle and its contents.
            // Outer circle with a stroke
            Circle()
                .stroke(color, lineWidth: circleSize * 0.05) // Line thickness scales with the circle size.
                .frame(width: circleSize, height: circleSize) // Circle dimensions.
                .shadow(color: color.opacity(0.6), radius: circleSize * 0.08) // Outer shadow for visual depth.

            // Inner content including time text and subtitle
            VStack(spacing: circleSize * 0.05) { // Spacing scales with circle size.
                // Main time display text
                Text(timeRemaining)
                    .font(.system(size: circleSize * 0.18, weight: .bold, design: .rounded)) // Font size scales with circle size.
                    .foregroundColor(.white) // Text color.
                    .shadow(radius: circleSize * 0.02) // Subtle shadow for readability.

                // A divider between time and subtitle
                Rectangle()
                    .frame(height: circleSize * 0.01) // Thin horizontal line.
                    .frame(width: circleSize * 0.6) // Width relative to circle size.
                    .foregroundColor(.gray)

                // Subtitle text
                Text(title)
                    .font(.system(size: circleSize * 0.08, weight: .medium, design: .rounded)) // Scaled subtitle font.
                    .textCase(.uppercase) // Converts the text to uppercase.
                    .foregroundColor(.gray) // Subtitle color.
                    .multilineTextAlignment(.center) // Centers text alignment.
            }
            .padding(circleSize * 0.1) // Inner padding scales with circle size.

            // Left icon, if specified
            if !iconLeft.isEmpty {
                ZStack {
                    // Background circle for the icon
                    Circle()
                        .frame(width: circleSize * 0.25, height: circleSize * 0.25) // Circle size scales.
                        .foregroundColor(.black) // Black background.
                        .offset(x: -circleSize * 0.4, y: -circleSize * 0.3) // Positioned to the top left of the main circle.

                    // Stroke around the icon's background circle
                    Circle()
                        .stroke(color, lineWidth: circleSize * 0.03) // Stroke with the primary color.
                        .scaledToFit()
                        .frame(width: circleSize * 0.25, height: circleSize * 0.25) // Matches the background circle's size.
                        .offset(x: -circleSize * 0.4, y: -circleSize * 0.3)

                    // Icon image
                    Image(systemName: iconLeft)
                        .resizable()
                        .foregroundStyle(color) // Icon color matches the primary color.
                        .scaledToFit()
                        .frame(width: circleSize * 0.15, height: circleSize * 0.15) // Icon size scales with circle size.
                        .offset(x: -circleSize * 0.4, y: -circleSize * 0.3)
                }
            }

            // Right icon, if specified
            if !iconRight.isEmpty {
                ZStack {
                    // Background circle for the icon
                    Circle()
                        .frame(width: circleSize * 0.25, height: circleSize * 0.25)
                        .foregroundColor(.black)
                        .offset(x: circleSize * 0.4, y: -circleSize * 0.3) // Positioned to the top right of the main circle.

                    // Stroke around the icon's background circle
                    Circle()
                        .stroke(color, lineWidth: circleSize * 0.03)
                        .scaledToFit()
                        .frame(width: circleSize * 0.25, height: circleSize * 0.25)
                        .offset(x: circleSize * 0.4, y: -circleSize * 0.3)

                    // Icon image
                    Image(systemName: iconRight)
                        .resizable()
                        .foregroundStyle(color)
                        .scaledToFit()
                        .frame(width: circleSize * 0.15, height: circleSize * 0.15)
                        .offset(x: circleSize * 0.4, y: -circleSize * 0.3)
                }
            }
        }
    }
}
