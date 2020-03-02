# ツモリンク

「いついつ、どこどこに行くツモリだよ」という想いを発信したり、共有することで、その場所に行くキッカケをつくるアプリです。

## 特徴
1. スポット（場所）をつくると、自動的にそのスポットのオーナーになります。
2. メンバーに入りたいスポットがあったら、オーナーに申請することができます。
2. スポットのオーナーが申請を許可すれば、そのスポットのメンバーになれます。
3. オーナーとメンバーだけが、ツモリを見ることができます。部外者は見ることができません。
4. 指定した日付に行く可能性と時間帯でツモリを表現することができます。
5. 自分だけが自分のツモリの履歴を見ることができます。

## 利用イメージ

![利用イメージ](https://github.com/khaki-ranger/Assets/blob/master/Tumolink/image.jpg?raw=true "利用イメージ")

## 機能一覧

| 内容 | 実現方法 |
----|----
|ユーザー認証 |Firebase Authentication |
|外部認証（Facebook認証） |FBSDKLoginKit |
|パスワード再設定 |Firebase Authentication |

## 開発環境・使用言語

- Xcode10.3 / Swift5.0.1

## 対応OS（デプロイターゲット）

- iOS10.0

## 使用技術一覧

| 内容 | 実現方法 |
----|----
|サーバー |Firebase |
|データベース |Firebase Firestore |
|画像ストレージ |Firebase Firestorage |
|ユーザー認証 |Firebase Authentication |
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
