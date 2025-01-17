# P2P Wallet

P2P Wallet on Solana blockchain

## Features

- [x] Create new wallet
- [x] Restore existing wallet using seed phrases
- [x] Decentralized identification (name service)
- [x] Send SOL, SPL tokens and renBTC via name or address
- [x] Receive SOL, SPL tokens and renBTC
- [x] Swap SOL and SPL tokens (powered by Orca)
- [x] Buy tokens (moonpay)

## Requirements

- iOS 13.0+
- Xcode 12
- SwiftFormat

## Installation

- Clone project and retrieve all submodules
```zsh
git clone git@github.com:p2p-org/p2p-wallet-ios.git
cd p2p-wallet-ios
git submodule update --init --recursive
```
- Override `githook` directory:
```zsh
git config core.hooksPath .githooks
chmod -R +x .githooks
```
- Run `pod install`
- Run `swiftgen` for the first time
```zsh
Pods/swiftgen/bin/swiftgen config run --config swiftgen.yml
```
- Add `Config.xconfig` to `p2p-wallet-ios/p2p-wallet` contains following content
```
// MARK: - Transak
TRANSAK_STAGING_API_KEY = fake_api_key
TRANSAK_PRODUCTION_API_KEY = fake_api_key
TRANSAK_HOST_URL = p2p.org

// Mark: - Moonpay
MOONPAY_STAGING_API_KEY = fake_api_key
MOONPAY_PRODUCTION_API_KEY = fake_api_key

// MARK: - Amplitude
AMPLITUDE_API_KEY = fake_api_key

// MARK: - FeeRelayer
FEE_RELAYER_ENDPOINT = fee-relayer.solana.p2p.org
TEST_ACCOUNT_SEED_PHRASE = account-test-seed-phrase-separated-by-hyphens
```

## Localization

- Download [LocalizationHelper app](https://github.com/bigearsenal/XCodeLocalizationHelper/raw/main/release/LocalizationHelper.zip)
- Copy `LocalizationHelper` to `Applications`
- Open `.xcproj` file from `LocalizationHelper`
- Add key and setup automation

## CI/CD

- `Swiftgen` for automatically generating strings, assets.
- `Swiftlint`, SwiftFormat for linting, automatically formating code
- `Periphery` for detecting dead code (use Detect Unused Code target and run)
- `CircleCI` or `GithubAction`: implementing...

## Code style

- Space indent: 4
- NSAttributedString 
Example:
```swift
label.attributedText = 
   NSMutableAttributedString()
      .text(
          "0.00203928 SOL",
          size: 15,
          color: .textBlack
      )
      .text(
          " (~$0.93)",
          size: 15,
          color: .textSecondary
      )
```
Result
<img width="113" alt="image" src="https://user-images.githubusercontent.com/6975538/160050828-f1231cbb-070b-4dba-bb83-c4a284cf3d2d.png">


## UI Templates

- Copy template `BEScene.xctemplate` that is located under `Templates` folder to  `~/Library/Developer/Xcode/Templates/File\ Templates/Templates/BEScene.xctemplate`
```zsh
mkdir -p ~/Library/Developer/Xcode/Templates/File\ Templates/BEScene.xctemplate
cp -R Templates/BEScene.xctemplate ~/Library/Developer/Xcode/Templates/File\ Templates/BEScene.xctemplate
```

## Dependency Injection

- Resolver

## Contribute

We would love you for the contribution to **P2P Wallet**, check the ``LICENSE`` file for more info.
