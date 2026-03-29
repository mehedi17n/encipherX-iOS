//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

// MARK: - Coordinator

enum AuthenticationStartScreenCoordinatorAction {
    case loginWithQR
    case login
    case register
    case reportProblem

    case loginDirectlyWithOIDC(data: OIDCAuthorizationDataProxy, window: UIWindow)
    case loginDirectlyWithPassword(loginHint: String?)
}

enum AuthenticationStartScreenViewModelAction: Equatable {
    case loginWithQR
    case login
    case register
    case reportProblem

    case loginDirectlyWithOIDC(data: OIDCAuthorizationDataProxy, window: UIWindow)
    case loginDirectlyWithPassword(loginHint: String?)
}

struct AuthenticationLanguageOption: Identifiable, Equatable {
    let id: String
    let title: String
    let shortTitle: String
}

struct AuthenticationStartScreenViewState: BindableState {
    /// The presentation anchor used for OIDC authentication.
    var window: UIWindow?

    let serverName: String?
    let showCreateAccountButton: Bool
    let showQRCodeLoginButton: Bool

    let hideBrandChrome: Bool

    let availableLanguages: [AuthenticationLanguageOption]
    var selectedLanguageCode: String

    var shouldShowLanguagePicker: Bool {
        availableLanguages.count > 1
    }

    var selectedLanguageTitle: String? {
        availableLanguages.first(where: { $0.id == selectedLanguageCode })?.title
    }

    var bindings = AuthenticationStartScreenViewStateBindings()

    var loginButtonTitle: String {
        if let serverName {
            L10n.screenOnboardingSignInTo(serverName)
        } else {
            L10n.screenOnboardingSignInManually
        }
    }
}

struct AuthenticationStartScreenViewStateBindings {
    var alertInfo: AlertInfo<AuthenticationStartScreenAlertType>?
}

enum AuthenticationStartScreenAlertType {
    case genericError
}

enum AuthenticationStartScreenViewAction {
    /// Updates the window used as the OIDC presentation anchor.
    case updateWindow(UIWindow)

    case loginWithQR
    case login
    case register
    case reportProblem
    case selectLanguage(code: String)
}
