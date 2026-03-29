//
// Copyright 2025 Element Creations Ltd.
// Copyright 2023-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

/// The background gradient shown on the launch, splash and onboarding screens.
struct AuthenticationStartScreenBackgroundImage: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.white

            VStack(spacing: 0) {
                Image(asset: ImageAsset(name: "auth-background-grad"))
                    .resizable()
                    .scaledToFill()
                    .opacity(0.32)
                    .frame(height: 420)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.white.opacity(0.0), location: 0.0),
                                .init(color: Color.white.opacity(0.5), location: 0.5),
                                .init(color: Color.white.opacity(1.0), location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Spacer()
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}
