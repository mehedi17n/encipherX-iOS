//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

extension LinearGradient {
    /// The brand gradient used across onboarding and authentication screens.
    ///
    /// Linear gradient:
    ///   - 0%:   #0048FF, opacity 0   (fully transparent)
    ///   - 100%: #9271BA, opacity 0.24
    static let encipherBrand = LinearGradient(
        stops: [
            .init(color: Color(red: 146 / 255, green: 113 / 255, blue: 186 / 255).opacity(0.24), location: 0),
            .init(color: Color(red: 0 / 255, green: 72 / 255, blue: 255 / 255).opacity(0), location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

/// Full-screen background view applying the Encipher brand gradient.
/// Use this as an SSoT wherever the brand gradient background is needed.
struct EncipherBrandGradientBackground: View {
    var body: some View {
        LinearGradient.encipherBrand
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}
