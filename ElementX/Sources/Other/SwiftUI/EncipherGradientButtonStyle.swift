//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

// MARK: - Button Style

/// Encipher branded gradient button — SSoT primary button style for
/// onboarding and authentication screens.
///
/// Usage:
/// ```swift
/// Button("Sign In") { … }
///     .buttonStyle(.encipherGradient)
/// ```
struct EncipherGradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .tracking(2)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .foregroundColor(.white)
            .background { buttonBackground(isPressed: configuration.isPressed) }
            .clipShape(Capsule())
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    @ViewBuilder
    private func buttonBackground(isPressed: Bool) -> some View {
        ZStack {
            // 1. Dark base
            Color(red: 0.04, green: 0.05, blue: 0.11)

            // 2. Structural linear gradient — top dark → blue → blue-purple
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.05, green: 0.07, blue: 0.16), location: 0.00),
                    .init(color: Color(red: 0.11, green: 0.20, blue: 0.42), location: 0.30),
                    .init(color: Color(red: 0.24, green: 0.34, blue: 0.63), location: 0.65),
                    .init(color: Color(red: 0.34, green: 0.28, blue: 0.60), location: 1.00)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // 3. Teal-blue organic bloom — upper-center, adds luminous depth
            RadialGradient(
                colors: [
                    Color(red: 0.12, green: 0.38, blue: 0.72).opacity(0.55),
                    Color.clear
                ],
                center: UnitPoint(x: 0.42, y: 0.20),
                startRadius: 0,
                endRadius: 150
            )

            // 4. Blue-violet bloom — lower center, rich and luminous
            RadialGradient(
                colors: [
                    Color(red: 0.38, green: 0.35, blue: 0.78).opacity(0.55),
                    Color.clear
                ],
                center: UnitPoint(x: 0.52, y: 0.78),
                startRadius: 0,
                endRadius: 120
            )

            // 5. Lavender-pink bloom — bottom edge for the purple warmth
            RadialGradient(
                colors: [
                    Color(red: 0.68, green: 0.55, blue: 0.78).opacity(0.28),
                    Color.clear
                ],
                center: UnitPoint(x: 0.50, y: 1.08),
                startRadius: 0,
                endRadius: 70
            )

            // 6. Subtle top specular — thin glass-like sheen for polished surface feel
            LinearGradient(
                colors: [Color.white.opacity(0.07), Color.clear],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.35)
            )

            // 7. Edge vignette — crushes corners dark for crisp capsule depth
            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.70)],
                center: .center,
                startRadius: 12,
                endRadius: 165
            )
        }
        .opacity(isPressed ? 0.72 : 1.0)
    }
}

extension ButtonStyle where Self == EncipherGradientButtonStyle {
    /// The Encipher branded gradient button style.
    static var encipherGradient: EncipherGradientButtonStyle { .init() }
}
