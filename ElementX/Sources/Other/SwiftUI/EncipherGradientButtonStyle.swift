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
            // 1. Pure black base
            Color.black

            // 2. Blue bloom (#0088FF) — bleeds upward from below bottom edge
            RadialGradient(
                stops: [
                    .init(color: Color(red: 0.00, green: 0.533, blue: 1.00).opacity(0.90), location: 0.0),
                    .init(color: Color(red: 0.00, green: 0.533, blue: 1.00).opacity(0.50), location: 0.4),
                    .init(color: Color(red: 0.00, green: 0.533, blue: 1.00).opacity(0.15), location: 0.75),
                    .init(color: Color.clear, location: 1.0)
                ],
                center: UnitPoint(x: 0.50, y: 1.15),
                startRadius: 0,
                endRadius: 210
            )

            // 3. Lavender bloom (#A988FF) — sits just below the blue
            RadialGradient(
                stops: [
                    .init(color: Color(red: 0.663, green: 0.533, blue: 1.00).opacity(0.80), location: 0.0),
                    .init(color: Color(red: 0.663, green: 0.533, blue: 1.00).opacity(0.40), location: 0.45),
                    .init(color: Color(red: 0.663, green: 0.533, blue: 1.00).opacity(0.10), location: 0.78),
                    .init(color: Color.clear, location: 1.0)
                ],
                center: UnitPoint(x: 0.50, y: 1.22),
                startRadius: 0,
                endRadius: 180
            )

            // 4. Black top curtain — smooth multi-stop fade for seamless transition
            LinearGradient(
                stops: [
                    .init(color: Color.black.opacity(1.00), location: 0.00),
                    .init(color: Color.black.opacity(0.88), location: 0.15),
                    .init(color: Color.black.opacity(0.60), location: 0.32),
                    .init(color: Color.black.opacity(0.25), location: 0.48),
                    .init(color: Color.black.opacity(0.06), location: 0.60),
                    .init(color: Color.clear,               location: 0.72)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .opacity(isPressed ? 0.72 : 1.0)
    }
}

extension ButtonStyle where Self == EncipherGradientButtonStyle {
    /// The Encipher branded gradient button style.
    static var encipherGradient: EncipherGradientButtonStyle { .init() }
}
