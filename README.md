# turnie App

ESP32ベースのデバイスとBluetooth Low Energy (BLE) で通信し、テキストや画像、ピクセルアートを送信するためのiOSアプリケーションです。

## プロジェクト構造

- `turnie/`
    - アプリケーションのメインソースコード
    - `turnieApp.swift`
        - アプリの進入口。BLEManagerの初期化と環境設定。
    - `ContentView.swift`
        - メインダッシュボード。各入力画面への遷移と接続状態の表示。
    - `BLEManager.swift`
        - Bluetooth通信の管理クラス。スキャン、接続、データ送信を担当。
    - `ImageProcessor.swift`
        - 画像処理ロジック。画像を8x8にリサイズしRGB配列に変換。
    - `DeviceListView.swift`
        - BLEデバイスの検索および選択画面。
    - `TextInputView.swift`
        - テキスト入力・送信画面。
    - `ImageInputView.swift`
        - 写真の選択・撮影および送信画面。
    - `PixelArtInputView.swift`
        - 8x8のピクセルアート作成・送信画面。
    - `InteractiveMosaicPreview.swift`
        - ピクセルアート作成用のインタラクティブなプレビューコンポーネント。
    - `MosaicPreview.swift`
        - 画像送信前の確認用プレビューコンポーネント。
    - `AccentProminentButtonStyle.swift`
        - アプリ内で使用される強調ボタンのスタイル定義。
    - `DashboardButtonStyle.swift`
        - メイン画面のカード型ボタンのスタイル定義。
    - `Info.plist`
        - アプリの権限設定（Bluetooth利用権限など）。
    - `Assets.xcassets/`
        - 画像、カラー、アイコンなどのアセット。
    - `en.lproj/`
        - 英語のローカライズリソース。
    - `ja.lproj/`
        - 日本語のローカライズリソース。
- `turnie.xcodeproj/`
    - Xcodeプロジェクトファイル。
- `turnieTests/`
    - ユニットテスト。
- `turnieUITests/`
    - UIテスト。

## 主な機能

- **BLE接続**: ESP32デバイスを検索し、自動または手動で接続します。
- **テキスト送信**: 任意のテキストをJSON形式でデバイスに送信します。
- **画像送信**: カメラやフォトライブラリから取得した画像を、デバイスで表示可能な8x8のモザイク画像に変換して送信します。
- **ピクセルアート作成**: アプリ上で1ピクセルずつ色を塗り、オリジナルの8x8ピクセルアートを作成して送信できます。
- **設定送信**: デバイスの色相や明るさ、プロフィール情報などの設定をJSON形式で送信します。

## BLEデータ通信形式

デバイスへはJSON形式のテキストデータが送信されます。

### テキスト形式 (`flag: "text"`)
```json
{
  "id": "p001",
  "flag": "text",
  "text": "送信テキスト"
}
```

### 画像形式 (`flag: "image"`)
8x8ピクセルのRGBデータ（192バイト）が配列として送信されます。
```json
{
  "id": "p002",
  "flag": "image",
  "rgb": [R, G, B, ...]
}
```

### 設定形式 (`flag: "settings"`)
```json
{
  "flag": "settings",
  "hue": 90,
  "brightness": 50,
  "name": "turnie_1",
  "hometown": "Osaka"
}
```

## 技術スタック

- **Language**: Swift
- **Framework**: SwiftUI
- **Database**: SwiftData (設定のみ、現在は主にUserDefaultsを使用)
- **Communication**: Core Bluetooth
