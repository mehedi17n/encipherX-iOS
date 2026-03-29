//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

// MARK: - Encipher Brand Color

private extension Color {
    static let encipherGreen = Color(red: 0.039, green: 0.529, blue: 0.255)
}

// MARK: - Screen

/// The screen shown at the beginning of the onboarding flow.
struct AuthenticationStartScreen: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @Bindable var context: AuthenticationStartScreenViewModel.Context
    @State private var isLanguagePickerExpanded = false
    @State private var carouselIndex = 0
    @State private var carouselItemCount = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                mainContent(in: geometry)

                if context.viewState.shouldShowLanguagePicker {
                    OnboardingLanguagePicker(options: context.viewState.availableLanguages,
                                             selectedCode: context.viewState.selectedLanguageCode,
                                             isExpanded: $isLanguagePickerExpanded) { action in
                        switch action {
                        case .toggle:
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isLanguagePickerExpanded.toggle()
                            }
                        case .select(let code):
                            context.send(viewAction: .selectLanguage(code: code))
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                isLanguagePickerExpanded = false
                            }
                        }
                    }
                    .padding(.leading, 16)
                    .accessibilityLabel(context.viewState.selectedLanguageTitle ?? "Language")
                }

                HStack(spacing: 6) {
                    ForEach(0..<carouselItemCount, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index == carouselIndex ? Color.encipherGreen : Color.encipherGreen.opacity(0.25))
                            .frame(width: index == carouselIndex ? 28 : 18, height: 3)
                            .animation(.easeInOut(duration: 0.3), value: carouselIndex)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 16)
                .padding(.top, 22)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarHidden(true)
        .background {
            AuthenticationStartScreenBackgroundImage()
        }
        .alert(item: $context.alertInfo)
        .introspect(.window, on: .supportedVersions) { window in
            context.send(viewAction: .updateWindow(window))
        }
    }

    private func mainContent(in geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
                .frame(height: UIConstants.spacerHeight(in: geometry))

            content
                .frame(width: geometry.size.width)
                .accessibilityIdentifier(A11yIdentifiers.authenticationStartScreen.hidden)

            Spacer()
                .frame(height: UIConstants.spacerHeight(in: geometry))

            buttons
                .frame(width: geometry.size.width)
                .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 16)
                .padding(.top, 8)

            Spacer()
                .frame(height: UIConstants.spacerHeight(in: geometry))
        }
        .frame(maxHeight: .infinity)
    }

    var content: some View {
        let slides = slideItems(for: context.viewState.selectedLanguageCode)
        return VStack(spacing: 0) {
            Spacer()

            if verticalSizeClass == .regular {
                Spacer()
                OnboardingCarouselView(items: slides, currentIndex: $carouselIndex)
                    .padding(.horizontal, 16)
                    .onAppear { carouselItemCount = slides.count }
            }

            Spacer()

            Spacer()
        }
        .padding(.bottom)
        .padding(.horizontal, 16)
        .readableFrame()
    }

    /// Returns localized slide items for the given language code.
    private func slideItems(for language: String) -> [OnboardingSlideItem] {
        switch language {
        case "id":
            return [
                OnboardingSlideItem(imageAssetName: "slide-1",
                                    title: "Bersama Encipher Anda",
                                    subtitle: "Selamat datang di Encipher tercepat yang pernah ada.\nDisempurnakan untuk kecepatan dan kemudahan."),
                OnboardingSlideItem(imageAssetName: "slide-2",
                                    title: "Pribadi dan aman",
                                    subtitle: "Enkripsi End-to-end untuk menjaga percakapan Anda tetap aman."),
                OnboardingSlideItem(imageAssetName: "slide-3",
                                    title: "Panggilan super jernih",
                                    subtitle: "Komunikasi Suara dan video berkualitas tinggi untuk tim Anda."),
                OnboardingSlideItem(imageAssetName: "slide-4",
                                    title: "Dibangun untuk kecepatan",
                                    subtitle: "Cepat, andal, dan mudah digunakan setiap hari.")
            ]
        default: // "en"
            return [
                OnboardingSlideItem(imageAssetName: "slide-1",
                                    title: "Be in your Encipher",
                                    subtitle: "Welcome to the fastest Encipher ever. Supercharged for speed and simplicity."),
                OnboardingSlideItem(imageAssetName: "slide-2",
                                    title: "Private and secure",
                                    subtitle: "End‑to‑end encryption keeps your conversations safe."),
                OnboardingSlideItem(imageAssetName: "slide-3",
                                    title: "Crystal‑clear calls",
                                    subtitle: "High‑quality voice and video for your teams."),
                OnboardingSlideItem(imageAssetName: "slide-4",
                                    title: "Built for speed",
                                    subtitle: "Fast, reliable, and simple to use every day.")
            ]
        }
    }

    /// The main action buttons.
    var buttons: some View {
        VStack(spacing: 16) {
//            if context.viewState.showQRCodeLoginButton {
//                Button { context.send(viewAction: .loginWithQR) } label: {
//                    Label(L10n.screenOnboardingSignInWithQrCode, icon: \.qrCode)
//                }
//                .buttonStyle(.compound(.primary))
//                .accessibilityIdentifier(A11yIdentifiers.authenticationStartScreen.signInWithQr)
//            }

            Button { context.send(viewAction: .login) } label: {
                Text(context.viewState.loginButtonTitle)
            }
            .buttonStyle(EncipherPrimaryButtonStyle())
            .accessibilityIdentifier(A11yIdentifiers.authenticationStartScreen.signIn)

//            if context.viewState.showCreateAccountButton {
//                Button { context.send(viewAction: .register) } label: {
//                    Text(L10n.screenCreateAccountTitle)
//                }
//                .buttonStyle(.compound(.tertiary))
//            }

//            versionText
//                .font(.compound.bodySM)
//                .foregroundColor(.compound.textSecondary)
//                .frame(maxWidth: .infinity)
//                .padding(.top, 16)
//                .onTapGesture(count: 7) {
//                    context.send(viewAction: .reportProblem)
//                }
//                .accessibilityIdentifier(A11yIdentifiers.authenticationStartScreen.appVersion)
        }
        .padding(.horizontal, verticalSizeClass == .compact ? 128 : 24)
        .readableFrame()
    }

    var versionText: Text {
        // Let's not deal with snapshotting a changing version string.
        let shortVersionString = ProcessInfo.isRunningTests ? "0.0.0" : InfoPlistReader.main.bundleShortVersionString
        return Text(L10n.screenOnboardingAppVersion(shortVersionString))
    }
}

// MARK: - Button Style

private struct EncipherPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(16)
            .foregroundColor(.white)
            .background(Color.encipherGreen.opacity(configuration.isPressed ? 0.9 : 1.0))
            .cornerRadius(32)
    }
}

// MARK: - Language Picker

private struct OnboardingLanguagePicker: View {
    enum PickerAction {
        case toggle
        case select(String)
    }

    let options: [AuthenticationLanguageOption]
    let selectedCode: String
    @Binding var isExpanded: Bool
    let action: (PickerAction) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button {
                action(.toggle)
            } label: {
                Image(systemName: "globe")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.compound.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                    )
            }
            .buttonStyle(.plain)

            if isExpanded {
                ForEach(options) { option in
                    let isSelected = option.id == selectedCode
                    languageButton(for: option, isSelected: isSelected)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThickMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    private func languageButton(for option: AuthenticationLanguageOption, isSelected: Bool) -> some View {
        Button {
            action(.select(option.id))
        } label: {
            Text(option.shortTitle.uppercased())
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? Color.encipherGreen : Color.black.opacity(0.75))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white.opacity(0.4) : Color.white.opacity(0.12))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.encipherGreen.opacity(0.4) : Color.black.opacity(0.1), lineWidth: 0.8)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Carousel

private struct OnboardingSlideItem: Identifiable {
    let id = UUID()
    let imageAssetName: String
    let title: String
    let subtitle: String
}

private struct OnboardingCarouselView: View {
    let items: [OnboardingSlideItem]
    let autoScrollInterval: TimeInterval
    let cornerRadius: CGFloat

    @Binding var currentIndex: Int
    @State private var timerTask: Task<Void, Never>?

    init(items: [OnboardingSlideItem], currentIndex: Binding<Int>, autoScrollInterval: TimeInterval = 5.0, cornerRadius: CGFloat = 24) {
        self.items = items
        self._currentIndex = currentIndex
        self.autoScrollInterval = autoScrollInterval
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        VStack(spacing: 32) {
            TabView(selection: $currentIndex) {
                ForEach(items.indices, id: \.self) { index in
                    Image(asset: ImageAsset(name: items[index].imageAssetName))
                        .resizable()
                        .scaledToFit()
                        .tag(index)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        .contentShape(Rectangle())
                        .onTapGesture { toggleAutoScroll() }
                        .padding(.horizontal, 4)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(maxWidth: .infinity)
            .frame(height: 260)

            VStack(spacing: 16) {
                Text(items[currentIndex].title)
                    .font(.compound.headingMDBold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.compound.textPrimary)
                Text(items[currentIndex].subtitle)
                    .font(.compound.bodyLG)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.compound.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(autoScrollInterval * 1_000_000_000))
                guard !Task.isCancelled else { break }
                await MainActor.run {
                    withAnimation(.easeInOut) {
                        currentIndex = (currentIndex + 1) % items.count
                    }
                }
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func toggleAutoScroll() {
        if timerTask != nil {
            stopTimer()
        } else {
            startTimer()
        }
    }
}

// MARK: - Previews

struct AuthenticationStartScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel = makeViewModel()
    static let provisionedViewModel = makeViewModel(provisionedServerName: "example.com")

    static var previews: some View {
        AuthenticationStartScreen(context: viewModel.context)
            .previewDisplayName("Default")
        AuthenticationStartScreen(context: provisionedViewModel.context)
            .previewDisplayName("Provisioned")
    }

    static func makeViewModel(provisionedServerName: String? = nil) -> AuthenticationStartScreenViewModel {
        AuthenticationStartScreenViewModel(authenticationService: AuthenticationService.mock,
                                           provisioningParameters: provisionedServerName.map { .init(accountProvider: $0, loginHint: nil) },
                                           isBugReportServiceEnabled: true,
                                           appSettings: ServiceLocator.shared.settings,
                                           userIndicatorController: UserIndicatorControllerMock())
    }
}
