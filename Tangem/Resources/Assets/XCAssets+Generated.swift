// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum Asset {
  public enum Assets {
    public static let accessCodeFeature1 = ImageAsset(name: "access_code_feature_1")
    public static let accessCodeFeature2 = ImageAsset(name: "access_code_feature_2")
    public static let accessCodeFeature3 = ImageAsset(name: "access_code_feature_3")
    public static let darkCard = ImageAsset(name: "dark_card")
    public static let designCheckmark = ImageAsset(name: "design.checkmark")
    public static let inputWithLock = ImageAsset(name: "input_with_lock")
    public static let inputWithLock1 = ImageAsset(name: "input_with_lock1")
    public static let lightCard = ImageAsset(name: "light_card")
    public static let refresh = ImageAsset(name: "refresh")
    public static let walletCard = ImageAsset(name: "wallet_card")
    public static let box = ImageAsset(name: "box")
    public static let ticket = ImageAsset(name: "ticket")
    public static let amazement = ImageAsset(name: "amazement")
    public static let coinShower = ImageAsset(name: "coin_shower")
    public static let currency0 = ImageAsset(name: "currency-0")
    public static let currency1 = ImageAsset(name: "currency-1")
    public static let currency2 = ImageAsset(name: "currency-2")
    public static let currency3 = ImageAsset(name: "currency-3")
    public static let currency4 = ImageAsset(name: "currency-4")
    public static let dapps0 = ImageAsset(name: "dapps-0")
    public static let dapps1 = ImageAsset(name: "dapps-1")
    public static let dapps2 = ImageAsset(name: "dapps-2")
    public static let dapps3 = ImageAsset(name: "dapps-3")
    public static let dapps4 = ImageAsset(name: "dapps-4")
    public static let dapps5 = ImageAsset(name: "dapps-5")
    public static let handWithCard = ImageAsset(name: "hand_with_card")
    public static let hand = ImageAsset(name: "hand")
    public static let iphone = ImageAsset(name: "iphone")
    public static let noTokens = ImageAsset(name: "no_tokens")
    public static let payId = ImageAsset(name: "payId")
    public static let plus = SymbolAsset(name: "plus")
    public static let save = ImageAsset(name: "save")
    public static let scan = ImageAsset(name: "scan")
    public static let shopBag = ImageAsset(name: "shopBag")
    public static let tangemArrowDown = ImageAsset(name: "tangemArrowDown")
    public static let tangemLogo = ImageAsset(name: "tangemLogo")
    public static let verticalDots = ImageAsset(name: "verticalDots")
  }
  public enum Colors {
    public static let tangemBg = ColorAsset(name: "tangem_bg")
    public static let tangemBgGray = ColorAsset(name: "tangem_bg_gray")
    public static let tangemBgGray2 = ColorAsset(name: "tangem_bg_gray2")
    public static let tangemBgGray3 = ColorAsset(name: "tangem_bg_gray3")
    public static let tangemBlue = ColorAsset(name: "tangem_blue")
    public static let tangemBlue1 = ColorAsset(name: "tangem_blue1")
    public static let tangemBlue2 = ColorAsset(name: "tangem_blue2")
    public static let tangemBlue3 = ColorAsset(name: "tangem_blue3")
    public static let tangemBlueLight = ColorAsset(name: "tangem_blue_light")
    public static let tangemBlueLight2 = ColorAsset(name: "tangem_blue_light2")
    public static let tangemCritical = ColorAsset(name: "tangem_critical")
    public static let tangemGrayDark = ColorAsset(name: "tangem_gray_dark")
    public static let tangemGrayDark2 = ColorAsset(name: "tangem_gray_dark2")
    public static let tangemGrayDark3 = ColorAsset(name: "tangem_gray_dark3")
    public static let tangemGrayDark4 = ColorAsset(name: "tangem_gray_dark4")
    public static let tangemGrayDark5 = ColorAsset(name: "tangem_gray_dark5")
    public static let tangemGrayDark6 = ColorAsset(name: "tangem_gray_dark6")
    public static let tangemGrayLight4 = ColorAsset(name: "tangem_gray_light4")
    public static let tangemGrayLight5 = ColorAsset(name: "tangem_gray_light5")
    public static let tangemGrayLight6 = ColorAsset(name: "tangem_gray_light6")
    public static let tangemGreen = ColorAsset(name: "tangem_green")
    public static let tangemGreen1 = ColorAsset(name: "tangem_green1")
    public static let tangemGreen2 = ColorAsset(name: "tangem_green2")
    public static let tangemStoryBackground = ColorAsset(name: "tangem_story_background")
    public static let tangemTextGray = ColorAsset(name: "tangem_text_gray")
    public static let tangemWarning = ColorAsset(name: "tangem_warning")
    public static let underlyingCardBackground1 = ColorAsset(name: "underlying-card-background1")
    public static let underlyingCardBackground2 = ColorAsset(name: "underlying-card-background2")
  }
  public enum Tokens {
    public static let arbitrumFill = ImageAsset(name: "arbitrum.fill")
    public static let arbitrum = ImageAsset(name: "arbitrum")
    public static let avalancheFill = ImageAsset(name: "avalanche.fill")
    public static let avalanche = ImageAsset(name: "avalanche")
    public static let binanceFill = ImageAsset(name: "binance.fill")
    public static let binance = ImageAsset(name: "binance")
    public static let bitcoinFill = ImageAsset(name: "bitcoin.fill")
    public static let bitcoin = ImageAsset(name: "bitcoin")
    public static let bitcoincashFill = ImageAsset(name: "bitcoincash.fill")
    public static let bitcoincash = ImageAsset(name: "bitcoincash")
    public static let bscFill = ImageAsset(name: "bsc.fill")
    public static let bsc = ImageAsset(name: "bsc")
    public static let cardanoFill = ImageAsset(name: "cardano.fill")
    public static let cardano = ImageAsset(name: "cardano")
    public static let dogecoinFill = ImageAsset(name: "dogecoin.fill")
    public static let dogecoin = ImageAsset(name: "dogecoin")
    public static let ethereumFill = ImageAsset(name: "ethereum.fill")
    public static let ethereum = ImageAsset(name: "ethereum")
    public static let ethereumclassicFill = ImageAsset(name: "ethereumclassic.fill")
    public static let ethereumclassic = ImageAsset(name: "ethereumclassic")
    public static let fantomFill = ImageAsset(name: "fantom.fill")
    public static let fantom = ImageAsset(name: "fantom")
    public static let kusamaFill = ImageAsset(name: "kusama.fill")
    public static let kusama = ImageAsset(name: "kusama")
    public static let litecoinFill = ImageAsset(name: "litecoin.fill")
    public static let litecoin = ImageAsset(name: "litecoin")
    public static let polkadotFill = ImageAsset(name: "polkadot.fill")
    public static let polkadot = ImageAsset(name: "polkadot")
    public static let polygonFill = ImageAsset(name: "polygon.fill")
    public static let polygon = ImageAsset(name: "polygon")
    public static let rskFill = ImageAsset(name: "rsk.fill")
    public static let rsk = ImageAsset(name: "rsk")
    public static let solanaFill = ImageAsset(name: "solana.fill")
    public static let solana = ImageAsset(name: "solana")
    public static let stellarFill = ImageAsset(name: "stellar.fill")
    public static let stellar = ImageAsset(name: "stellar")
    public static let tezosFill = ImageAsset(name: "tezos.fill")
    public static let tezos = ImageAsset(name: "tezos")
    public static let tronFill = ImageAsset(name: "tron.fill")
    public static let tron = ImageAsset(name: "tron")
    public static let xrpFill = ImageAsset(name: "xrp.fill")
    public static let xrp = ImageAsset(name: "xrp")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class ColorAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  public func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

public struct ImageAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  public var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  public func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif
}

public extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

public struct SymbolAsset {
  public fileprivate(set) var name: String

  #if os(iOS) || os(tvOS) || os(watchOS)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  public typealias Configuration = UIImage.SymbolConfiguration
  public typealias Image = UIImage

  @available(iOS 12.0, tvOS 12.0, watchOS 5.0, *)
  public var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load symbol asset named \(name).")
    }
    return result
  }

  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  public func image(with configuration: Configuration) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, with: configuration) else {
      fatalError("Unable to load symbol asset named \(name).")
    }
    return result
  }
  #endif
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
