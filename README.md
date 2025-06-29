# B-Trainer Log Viewer

スマートスポーツギア「[B-Trainer](https://www.sony.jp/b-trainer/)」で記録したトレーニングログをPCやスマートフォンで可視化・分析するための、**Flutter**で構築されたクロスプラットフォームアプリケーションです。

[![Built with Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)

![アプリケーションのスクリーンショット](https://raw.githubusercontent.com/mistakemrk/btrainer_log_viewer/main/btrainer_log_viewer.png)

## 概要

B-Trainerは素晴らしいデバイスですが、公式のスマートフォンアプリでのデータ閲覧にはいくつかの制約がありました。このアプリケーションは、B-Trainerが生成するログファイル（`.log`）を直接読み込み、より詳細なデータを様々なデバイスで確認することを目的として開発されています。

Flutterフレームワークを採用することで、Windows, macOS, Linux, Android, iOSの各プラットフォームで同じ体験を提供します。

## 主な機能

- **トレーニングデータの可視化**:
  - 走行ルートを地図上に表示
  - 速度、ペース、ピッチ、ストライド、心拍数、高度、消費カロリーなどの各種センサーデータをグラフで表示
- **ログファイルの簡単読み込み**:
  - ファイルピッカーから `.log` ファイルを選択するだけでデータを表示
- **クロスプラットフォーム**:
  - Flutterにより、単一のコードベースでマルチプラットフォームに対応

## 開発者向けセットアップ

このアプリケーションをソースコードからビルド・実行したい場合は、以下の手順に従ってください。

**前提条件:**
- Flutter SDK がインストールされていること。
- Git がインストールされていること。

**手順:**
```bash
# 1. このリポジトリをクローンします
git clone https://github.com/mistakemrk/btrainer_log_viewer.git
cd btrainer_log_viewer

# 2. 必要なパッケージをインストールします
flutter pub get

# 3. アプリケーションを実行します
# (接続されているデバイスやエミュレータでアプリが起動します)
flutter run
```

## 使い方

1.  アプリケーションを起動します。
2.  画面上の「ログファイルを開く」ボタンをタップ（クリック）します。
3.  ファイルピッカーが表示されたら、B-Trainerから転送した `.log` ファイルを選択します。
4.  データが読み込まれ、地図、グラフ、サマリー情報が画面に表示されます。

## ライセンス

このプロジェクトは MITライセンス の下で公開されています。

---
*B-Trainerはソニー株式会社の商標または登録商標です。このプロジェクトはソニー株式会社とは一切関係ありません。*
