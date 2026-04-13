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
            .background {
                Image(asset: Asset.Images.buttonBg)
                    .resizable()
                    .scaledToFill()
                    .opacity(configuration.isPressed ? 0.72 : 1.0)
            }
            .clipShape(Capsule())
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == EncipherGradientButtonStyle {
    /// The Encipher branded gradient button style.
    static var encipherGradient: EncipherGradientButtonStyle { .init() }
}
