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
    static let encipherNavy = Color(red: 0, green: 0, blue: 0.533) // #000088
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
                            .fill(index == carouselIndex ? Color.encipherNavy : Color.encipherNavy.opacity(0.25))
                            .frame(width: index == carouselIndex ? 48 : 36, height: 3)
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
                    .onAppear { carouselItemCount = slides.count }
            }

            Spacer()

            Spacer()
        }
        .padding(.bottom)
        .readableFrame()
    }

    /// Returns localized slide items for the given language code.
    private func slideItems(for language: String) -> [OnboardingSlideItem] {
        switch language {
        case "id":
            return [
                OnboardingSlideItem(imageAssetName: "slide-1",
                                    title: "Amankan Suara Anda,\nMiliki Cerita Anda.",
                                    subtitle: "Komunikasi rahasia dan pribadi, seaman percakapan personal di rumah."),
                OnboardingSlideItem(imageAssetName: "slide-2",
                                    title: "Anda yang Berkuasa",
                                    subtitle: "Pilih di mana percakapan Anda disimpan, memberikan kontrol dan kemandirian."),
                OnboardingSlideItem(imageAssetName: "slide-3",
                                    title: "Pesan yang Aman",
                                    subtitle: "Terenkripsi end-to-end, tanpa nomor telepon. Tanpa iklan atau penambangan data."),
                // OnboardingSlideItem(imageAssetName: "slide-4",
                //                     title: "Dibangun untuk kecepatan",
                //                     subtitle: "Cepat, andal, dan mudah digunakan setiap hari.")
            ]
        default: // "en"
            return [
                OnboardingSlideItem(imageAssetName: "slide-1",
                                    title: "Secure Your Voice,\nOwn Your Story.",
                                    subtitle: "Confidential and private communication, as secure as a personal conversation at home."),
                OnboardingSlideItem(imageAssetName: "slide-2",
                                    title: "You're in Control",
                                    subtitle: "Choose where your conversations are kept, giving you control and independence."),
                OnboardingSlideItem(imageAssetName: "slide-3",
                                    title: "Secure Messaging",
                                    subtitle: "End-to-end Encrypted and no phone number required. No Ads or data mining."),
                // OnboardingSlideItem(imageAssetName: "slide-4",
                //                     title: "Built for speed",
                //                     subtitle: "Fast, reliable, and simple to use every day.")
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
            .buttonStyle(.encipherGradient)
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
                .foregroundStyle(isSelected ? Color.encipherNavy : Color.black.opacity(0.75))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white.opacity(0.4) : Color.white.opacity(0.12))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.encipherNavy.opacity(0.4) : Color.black.opacity(0.1), lineWidth: 0.8)
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
        TabView(selection: $currentIndex) {
            ForEach(items.indices, id: \.self) { index in
                if index == 0 {
                    OnboardingSlide1FullView(title: items[index].title, subtitle: items[index].subtitle)
                        .tag(index)
                        .contentShape(Rectangle())
                        .onTapGesture { toggleAutoScroll() }
                } else if index == 1 {
                    OnboardingSlide2FullView(title: items[index].title, subtitle: items[index].subtitle)
                        .tag(index)
                        .contentShape(Rectangle())
                        .onTapGesture { toggleAutoScroll() }
                } else if index == 2 {
                    OnboardingSlide3FullView(title: items[index].title, subtitle: items[index].subtitle)
                        .tag(index)
                        .contentShape(Rectangle())
                        .onTapGesture { toggleAutoScroll() }
                } else {
                    OnboardingStandardSlideView(item: items[index], cornerRadius: cornerRadius)
                        .tag(index)
                        .contentShape(Rectangle())
                        .onTapGesture { toggleAutoScroll() }
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(maxWidth: .infinity)
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

// MARK: - Onboarding Slide 1 (full custom layout)

private struct OnboardingSlide1FullView: View {
    let title: String
    let subtitle: String

    // Periwinkle ring color matching the design
    private let ringColor = Color(red: 0.60, green: 0.60, blue: 0.78)

    var body: some View {
        GeometryReader { geo in
            let W = geo.size.width
            let outerDiameter = W * 0.86
            let innerDiameter = outerDiameter * 0.63
            let iconSize = innerDiameter * 0.54

            VStack(spacing: 0) {
                // Title
                Text(title)
                    .font(.compound.headingMDBold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.compound.textPrimary)
                    .padding(.top, 12)
                    .padding(.horizontal, 20)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                // Concentric rings + encipher icon (no white card)
                ZStack {
                    Circle()
                        .stroke(ringColor.opacity(0.22), lineWidth: 1.5)
                        .frame(width: outerDiameter, height: outerDiameter)

                    Circle()
                        .stroke(ringColor.opacity(0.40), lineWidth: 1.5)
                        .frame(width: innerDiameter, height: innerDiameter)

                    Image(asset: Asset.encipherLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize)
                }
                .frame(height: outerDiameter)

                // Encipher text logo — sized proportional to screen width
                Image(asset: Asset.encipherLogoText)
                    .resizable()
                    .scaledToFit()
                    .frame(width: W * 0.56)
                    .padding(.top, 22)

                Spacer()

                // Subtitle
                Text(subtitle)
                    .font(.compound.bodyLG)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.compound.textSecondary)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 12)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: W, height: geo.size.height)
        }
    }
}

// MARK: - Onboarding Slide 2 (You're in Control)

private struct OnboardingSlide2FullView: View {
    let title: String
    let subtitle: String

    var body: some View {
        GeometryReader { geo in
            let W = geo.size.width
            let H = geo.size.height
            let iconSize = W * 0.32

            ZStack {
                // Background overlay — stretched to fill W×H exactly, no clipping
                Image(asset: Asset.onboarding2BgOverlay)
                    .resizable()
                    .frame(width: W, height: H)

                // Content on top
                VStack(spacing: 0) {
                    Text(title)
                        .font(.compound.headingMDBold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.compound.textPrimary)
                        .padding(.top, 12)
                        .padding(.horizontal, 20)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    Image(asset: Asset.onboarding2)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)

                    Spacer()

                    Text(subtitle)
                        .font(.compound.bodyLG)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.compound.textSecondary)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 12)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: W, height: H)
            }
            .frame(width: W, height: H)
        }
    }
}

// MARK: - Onboarding Slide 3 (Secure Messaging)

private struct OnboardingSlide3FullView: View {
    let title: String
    let subtitle: String

    var body: some View {
        GeometryReader { geo in
            let W = geo.size.width
            let H = geo.size.height
            let iconSize = W * 0.32

            ZStack {
                // Background overlay — stretched to fill W×H exactly, no clipping
                Image(asset: Asset.onboarding3BgOverlay)
                    .resizable()
                    .frame(width: W, height: H)

                // Content on top
                VStack(spacing: 0) {
                    Text(title)
                        .font(.compound.headingMDBold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.compound.textPrimary)
                        .padding(.top, 12)
                        .padding(.horizontal, 20)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    Image(asset: Asset.onboarding3)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)

                    Spacer()

                    Text(subtitle)
                        .font(.compound.bodyLG)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.compound.textSecondary)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 12)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: W, height: H)
            }
            .frame(width: W, height: H)
        }
    }
}

// MARK: - Standard slide (slides 2-4)

private struct OnboardingStandardSlideView: View {
    let item: OnboardingSlideItem
    let cornerRadius: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(asset: ImageAsset(name: item.imageAssetName))
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .padding(.horizontal, 4)

            VStack(spacing: 16) {
                Text(item.title)
                    .font(.compound.headingMDBold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.compound.textPrimary)
                Text(item.subtitle)
                    .font(.compound.bodyLG)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.compound.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 32)

            Spacer()
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
