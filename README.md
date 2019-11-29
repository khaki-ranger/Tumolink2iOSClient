# TumolinkiOSClient
iOS版ツモリンク

## 特徴

## 利用イメージ

## 機能一覧

| 内容 | 実現方法 |
----|----
|ユーザー認証 |Firebase Authentication |
|匿名ユーザー |Firebase Authentication |
|パスワード再設定 |Firebase Authentication |
|外部認証（Facebook認証） |FBSDKLoginKit |

## 開発環境・使用言語

- Xcode10.3 / Swift5.0.1

## 対応OS（デプロイターゲット）

- iOS10.0

## 使用技術一覧

| 内容 | 実現方法 |
----|----
|サーバー |Firebase |
|データベース（データ永続化）|Firebase Firestore |
|画像ストレージ |Firebase Firestorage |
|ユーザー、セッション管理 |Firebase Authentication |
|外部認証 |FBSDKLoginKit |
|外部API通信 |Firebase CloudFunctions |
|画像キャッシュ |Kingfisher |

## 設計・デザインパターン

- MVC

## UI作成方法

- Interface Builder（ストーリーボード）

## 使用ライブラリ

#### Firebase関連
- Firebase/Core 6.1.0
- Firebase/Auth 6.1.0
- Firebase/Firestore 6.1.0
- Firebase/Storage 6.1.0
- Firebase/Functions 6.1.0

#### その他

- [FBSDKLoginKit](https://developers.facebook.com/docs/facebook-login/ios/v2.2)
- [IQKeyboardManagerSwift 6.3.0](https://github.com/hackiftekhar/IQKeyboardManager)
- [Kingfisher 4.0](https://github.com/onevcat/Kingfisher)

## 使用API

## 自動テスト
