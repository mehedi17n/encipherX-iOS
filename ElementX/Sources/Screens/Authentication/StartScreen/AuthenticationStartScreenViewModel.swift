//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

typealias AuthenticationStartScreenViewModelType = StateStoreViewModelV2<AuthenticationStartScreenViewState, AuthenticationStartScreenViewAction>

class AuthenticationStartScreenViewModel: AuthenticationStartScreenViewModelType, AuthenticationStartScreenViewModelProtocol {
    private let authenticationService: AuthenticationServiceProtocol
    private let provisioningParameters: AccountProvisioningParameters?
    private let appSettings: AppSettings
    private let userIndicatorController: UserIndicatorControllerProtocol

    private let canReportProblem: Bool

    private var actionsSubject: PassthroughSubject<AuthenticationStartScreenViewModelAction, Never> = .init()

    var actions: AnyPublisher<AuthenticationStartScreenViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    private static let supportedLanguageOptions: [AuthenticationLanguageOption] = [
        .init(id: "en", title: "English", shortTitle: "EN"),
        .init(id: "id", title: "Bahasa Indonesia", shortTitle: "ID")
    ]
    private static let supportedLanguageCodes = Set(supportedLanguageOptions.map(\.id))

    init(authenticationService: AuthenticationServiceProtocol,
         provisioningParameters: AccountProvisioningParameters?,
         isBugReportServiceEnabled: Bool,
         appSettings: AppSettings,
         userIndicatorController: UserIndicatorControllerProtocol) {
        self.authenticationService = authenticationService
        self.provisioningParameters = provisioningParameters
        self.appSettings = appSettings
        self.userIndicatorController = userIndicatorController
        canReportProblem = isBugReportServiceEnabled

        let isQRCodeScanningSupported = !ProcessInfo.processInfo.isiOSAppOnMac
        let initialLanguage = Self.initialLanguage(preferredCode: appSettings.preferredLanguageCode)

        let initialViewState = if !appSettings.allowOtherAccountProviders {
            // We don't show the create account button when custom providers are disallowed.
            // The assumption here being that if you're running a custom app, your users will already be created.
            AuthenticationStartScreenViewState(serverName: appSettings.accountProviders.count == 1 ? appSettings.accountProviders[0] : nil,
                                               showCreateAccountButton: false,
                                               showQRCodeLoginButton: isQRCodeScanningSupported,
                                               hideBrandChrome: appSettings.hideBrandChrome,
                                               availableLanguages: Self.supportedLanguageOptions,
                                               selectedLanguageCode: initialLanguage)
        } else if let provisioningParameters {
            // We only show the "Sign in to …" button when using a provisioning link.
            AuthenticationStartScreenViewState(serverName: provisioningParameters.accountProvider,
                                               showCreateAccountButton: false,
                                               showQRCodeLoginButton: false,
                                               hideBrandChrome: appSettings.hideBrandChrome,
                                               availableLanguages: Self.supportedLanguageOptions,
                                               selectedLanguageCode: initialLanguage)
        } else {
            // The default configuration.
            AuthenticationStartScreenViewState(serverName: nil,
                                               showCreateAccountButton: appSettings.showCreateAccountButton,
                                               showQRCodeLoginButton: isQRCodeScanningSupported,
                                               hideBrandChrome: appSettings.hideBrandChrome,
                                               availableLanguages: Self.supportedLanguageOptions,
                                               selectedLanguageCode: initialLanguage)
        }

        super.init(initialViewState: initialViewState)

        applyLanguageSelection(initialLanguage, persistSelection: appSettings.preferredLanguageCode != nil)
    }

    override func process(viewAction: AuthenticationStartScreenViewAction) {
        switch viewAction {
        case .updateWindow(let window):
            guard state.window != window else { return }
            state.window = window
        case .loginWithQR:
            actionsSubject.send(.loginWithQR)
        case .login:
            Task { await login() }
        case .register:
            actionsSubject.send(.register)
        case .reportProblem:
            if canReportProblem {
                actionsSubject.send(.reportProblem)
            }
        case .selectLanguage(let code):
            applyLanguageSelection(code)
        }
    }

    // MARK: - Language

    private func applyLanguageSelection(_ code: String, persistSelection: Bool = true) {
        guard Self.supportedLanguageCodes.contains(code) else { return }
        if state.selectedLanguageCode != code {
            state.selectedLanguageCode = code
        }
        Bundle.overrideLocalizations = [code]
        if persistSelection {
            appSettings.preferredLanguageCode = code
        }
    }

    private static func initialLanguage(preferredCode: String?) -> String {
        if let preferredCode, supportedLanguageCodes.contains(preferredCode.lowercased()) {
            return preferredCode.lowercased()
        }
        for localeIdentifier in Locale.preferredLanguages {
            let normalized = normalizedLanguageCode(from: localeIdentifier)
            if supportedLanguageCodes.contains(normalized) {
                return normalized
            }
        }
        return "en"
    }

    private static func normalizedLanguageCode(from identifier: String) -> String {
        identifier
            .split(whereSeparator: { $0 == "-" || $0 == "_" })
            .first
            .map { String($0).lowercased() } ?? identifier.lowercased()
    }
    
    // MARK: - Private
    
    private func login() async {
        if let serverName = state.serverName {
            await configureAccountProvider(serverName, loginHint: provisioningParameters?.loginHint)
        } else {
            actionsSubject.send(.login) // No need to configure anything here, continue the flow.
        }
    }
    
    private func configureAccountProvider(_ accountProvider: String, loginHint: String? = nil) async {
        startLoading()
        defer { stopLoading() }
        
        guard case .success = await authenticationService.configure(for: accountProvider, flow: .login) else {
            // As the server was provisioned, we don't worry about the specifics and show a generic error to the user.
            displayError()
            return
        }
        
        guard authenticationService.homeserver.value.loginMode.supportsOIDCFlow else {
            actionsSubject.send(.loginDirectlyWithPassword(loginHint: loginHint))
            return
        }
        
        guard let window = state.window else {
            displayError()
            return
        }
        
        switch await authenticationService.urlForOIDCLogin(loginHint: loginHint) {
        case .success(let oidcData):
            actionsSubject.send(.loginDirectlyWithOIDC(data: oidcData, window: window))
        case .failure:
            displayError()
        }
    }
    
    private let loadingIndicatorID = "\(AuthenticationStartScreenViewModel.self)-Loading"
    
    private func startLoading() {
        userIndicatorController.submitIndicator(UserIndicator(id: loadingIndicatorID,
                                                              type: .modal,
                                                              title: L10n.commonLoading,
                                                              persistent: true))
    }
    
    private func stopLoading() {
        userIndicatorController.retractIndicatorWithId(loadingIndicatorID)
    }
    
    private func displayError() {
        state.bindings.alertInfo = AlertInfo(id: .genericError)
    }
}
