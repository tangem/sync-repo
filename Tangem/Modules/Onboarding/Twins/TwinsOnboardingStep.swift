//
//  TwinsOnboardingStep.swift
//  Tangem
//
//  Created by Andrew Son on 14.09.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import SwiftUI

protocol SuccessStep {
    var successTitle: LocalizedStringKey { get }
    var successButtonTitle: LocalizedStringKey { get }
    var successMessagesOffset: CGSize { get }
}

extension SuccessStep {
    var successTitle: LocalizedStringKey { "onboarding_done_header" }
    var successButtonTitle: LocalizedStringKey { "common_continue" }
    var successMessagesOffset: CGSize {
        .init(width: 0, height: -UIScreen.main.bounds.size.height * 0.115)
    }
}

enum TwinsOnboardingStep: Equatable {
    case welcome
    case intro(pairNumber: String)
    case first
    case second
    case third
    case topup
    case done
    case saveUserWallet
    case success
    case alert

    static var previewCases: [TwinsOnboardingStep] {
        [.intro(pairNumber: "2"), .topup, .done]
    }

    static var twinningProcessSteps: [TwinsOnboardingStep] {
        [.first, .second, .third]
    }

    static var topupSteps: [TwinsOnboardingStep] {
        [.topup, .done]
    }

    static var twinningSteps: [TwinsOnboardingStep] {
        var steps: [TwinsOnboardingStep] = []
        steps.append(.alert)
        steps.append(contentsOf: TwinsOnboardingStep.twinningProcessSteps)
        steps.append(.success)
        return steps
    }

    var topTwinCardIndex: Int {
        switch self {
        case .second: return 1
        default: return 0
        }
    }

    var isBackgroundVisible: Bool {
        switch self {
        case .intro: return true
        default: return false
        }
    }

    var isModal: Bool {
        switch self {
        case .second, .third: return true
        default: return false
        }
    }

    func backgroundFrame(in container: CGSize) -> CGSize {
        switch self {
        case .topup,  .done:
            return defaultBackgroundFrameSize(in: container)
        case .welcome:
            return .zero
        default: return .init(width: 10, height: 10)
        }
    }

    func backgroundCornerRadius(in container: CGSize) -> CGFloat {
        switch self {
        case .topup,  .done: return defaultBackgroundCornerRadius
        case .welcome: return 0
        default: return backgroundFrame(in: container).height / 2
        }
    }

    func backgroundOffset(in container: CGSize) -> CGSize {
        defaultBackgroundOffset(in: container)
    }

    var backgroundOpacity: Double {
        switch self {
        case .topup,  .done: return 1
        default: return 0
        }
    }
}

extension TwinsOnboardingStep: OnboardingProgressStepIndicatable {
    var isOnboardingFinished: Bool {
        switch self {
        case .success, .done:
            return true
        default:
            return false
        }
    }

    var successCircleOpacity: Double {
        switch self {
        case .success: return 1
        default: return 0
        }
    }

    var successCircleState: OnboardingCircleButton.State {
        switch self {
        case .success: return .doneCheckmark
        default: return .blank
        }
    }
}


extension TwinsOnboardingStep: OnboardingTopupBalanceLayoutCalculator {}

extension TwinsOnboardingStep: SuccessStep {}

extension TwinsOnboardingStep: OnboardingMessagesProvider {
    var title: LocalizedStringKey? {
        switch self {
        case .welcome: return WelcomeStep.welcome.title
        case .intro: return "twins_onboarding_subtitle"
        case .first, .third: return LocalizedStringKey(stringLiteral: "twins_recreate_title_format".localized("1"))
        case .second: return LocalizedStringKey(stringLiteral: "twins_recreate_title_format".localized("2"))
        case .topup: return "onboarding_topup_title"
        case .done: return "onboarding_confetti_title"
        case .saveUserWallet: return nil
        case .success: return successTitle
        case .alert: return "common_warning"
        }
    }

    var subtitle: LocalizedStringKey? {
        switch self {
        case .welcome: return WelcomeStep.welcome.subtitle
        case .intro(let pairNumber): return LocalizedStringKey(stringLiteral: "twins_onboarding_description_format".localized(pairNumber))
        case .first, .second, .third: return "onboarding_twins_interrupt_warning"
        case .topup: return "onboarding_top_up_body"
        case .saveUserWallet: return nil
        case .done, .success: return "onboarding_done_body"
        case .alert: return "twins_recreate_warning"
        }
    }

    var messagesOffset: CGSize {
        switch self {
        default: return .zero
        }
    }
}

extension TwinsOnboardingStep: OnboardingButtonsInfoProvider {
    var mainButtonTitle: LocalizedStringKey {
        switch self {
        case .welcome: return WelcomeStep.welcome.mainButtonTitle
        case .intro: return "common_continue"
        case .first, .third: return LocalizedStringKey(stringLiteral: "twins_recreate_button_format".localized("1"))
        case .second: return LocalizedStringKey(stringLiteral: "twins_recreate_button_format".localized("2"))
        case .topup: return "onboarding_top_up_button_but_crypto"
        case .done: return "common_continue"
        case .saveUserWallet: return BiometricAuthorizationUtils.allowButtonLocalizationKey
        case .success: return successButtonTitle
        case .alert: return "common_continue"
        }
    }

    var supplementButtonTitle: LocalizedStringKey {
        switch self {
        case .welcome: return WelcomeStep.welcome.supplementButtonTitle
        case .topup: return "onboarding_top_up_button_show_wallet_address"
        default: return ""
        }
    }

    var isSupplementButtonVisible: Bool {
        switch self {
        case .topup, .welcome: return true
        default: return false
        }
    }

    var isContainSupplementButton: Bool { true }

    var checkmarkText: LocalizedStringKey? {
        switch self {
        case .alert:
            return "common_understand"
        default:
            return nil
        }
    }

    var infoText: LocalizedStringKey? {
        switch self {
        case .saveUserWallet:
            return "save_user_wallet_agreement_notice"
        default:
            return nil
        }
    }
}

extension TwinsOnboardingStep: OnboardingInitialStepInfo {
    static var initialStep: TwinsOnboardingStep { .welcome }
    static var finalStep: TwinsOnboardingStep { .done }
}
