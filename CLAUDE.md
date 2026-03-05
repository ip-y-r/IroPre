# CLAUDE.md — IroPre プロジェクト指示書

## プロジェクト概要

IroPreは、数独の数字を「色」に置き換えたiOSパズルゲームアプリです。
詳細な仕様は `docs/PRD.md` を参照してください。

## 技術スタック

- **言語:** Swift 6
- **UI:** SwiftUI (iOS 18+)
- **アーキテクチャ:** MVVM + Clean Architecture
- **データ永続化:** SwiftData
- **フォント:** SF Pro Rounded（英語）+ Noto Sans JP（日本語）
- **画面回転:** ポートレート固定

## 開発ルール

### コーディング規約

- Swift API Design Guidelinesに準拠
- SwiftLintを使用（プロジェクトルートに`.swiftlint.yml`を配置）
- 各ファイル先頭に`// MARK: - [概要]`コメントを記載
- ViewとViewModelは必ずペアで作成
- 依存注入はProtocolベースで行う（テスト容易性のため）
- エラーハンドリングはResult型で統一

### ファイル命名規則

- View: `[Feature]View.swift`
- ViewModel: `[Feature]ViewModel.swift`
- Model: `[ModelName].swift`
- Repository: `[Domain]Repository.swift`

### コミットメッセージ

```
[Phase X] feat: 機能の説明
[Phase X] fix: バグ修正の説明
[Phase X] refactor: リファクタリングの説明
[Phase X] test: テスト追加の説明
```

## ディレクトリ構造

```
IroPre/
├── App/
│   ├── IroPreApp.swift
│   └── ContentView.swift
├── Core/
│   ├── Models/       (Puzzle, Cell, GameState, Move, Achievement)
│   ├── Engine/       (PuzzleGenerator, PuzzleValidator, HintEngine)
│   └── Theme/        (ColorPalette, AccessibilityMode, FontManager)
├── Features/
│   ├── Home/         (HomeView, HomeViewModel)
│   ├── Game/         (GameView, GameViewModel, BoardView, PaletteView, PauseOverlayView)
│   ├── LevelSelect/  (LevelSelectView, LevelSelectViewModel)
│   ├── Tutorial/     (TutorialView, TutorialViewModel)
│   ├── Achievements/ (AchievementsView, AchievementsViewModel)
│   └── Settings/     (SettingsView, SettingsViewModel)
├── Data/
│   ├── Repository/   (GameRepository, AchievementRepository)
│   ├── Storage/      (SwiftDataManager, GameProgress, ClearRecord, AchievementRecord, UserSettings)
│   └── Presets/      (PuzzlePresets.json)
├── Resources/
│   ├── Assets.xcassets/
│   ├── Fonts/        (NotoSansJP-*.ttf)
│   ├── Sounds/
│   └── Haptics/
└── Utilities/
    ├── Extensions/
    └── Constants.swift
```

## 開発フェーズ

各フェーズ完了時にビルドが通る状態を維持してください。

### Phase 1: 基盤（現在）
1. Xcodeプロジェクト作成（iOS 18+, SwiftUI）
2. ディレクトリ構造のセットアップ
3. SwiftDataモデル定義（4モデル: GameProgress, ClearRecord, AchievementRecord, UserSettings）
4. パズルエンジン実装（PuzzleGenerator, PuzzleValidator）
5. カラーパレット定義（ライト9色 + ダーク9色）
6. SwiftLint設定

### Phase 2: コアUI
1. ゲーム画面（BoardView + PaletteView）
2. カラーファースト操作フロー（色選択→マスタップ、連続配置モード）
3. レベル選択画面（4×4/6×6/9×9タブ切り替え）
4. undo機能（全手戻し対応）
5. ホーム画面

### Phase 3: 機能
1. チュートリアル（4ステップ、再アクセス対応）
2. ヒント機能（マスヒント/エラーチェック/ブロックヒント）
3. 実績システム
4. ダークモード（ゲーム中ロック）
5. ポーズ画面（盤面非表示）
6. 設定画面

### Phase 4: 演出
1. アニメーション（色配置スプリング、クリアパーティクル）
2. ハプティクス
3. サウンドエフェクト
4. スプラッシュ画面
5. Noto Sans JP統合（FontManager）

### Phase 5: QA
1. Unit Test
2. パフォーマンス最適化（60fps, 起動1.5秒以内）
3. アクセシビリティ（VoiceOver、色覚モード）
4. バグ修正

## 重要な仕様メモ

- **操作フロー:** 先に色を選ぶ → マスをタップ（カラーファースト方式）
- **連続配置:** パレットの色は配置後も維持。同じ色を再タップで解除
- **6×6ブロック:** 横長（2行×3列）
- **9×9タップ:** セル約34ptだがそのまま使用。ハプティクスで補助
- **ダークモード:** ゲーム中は切替ロック。ホーム/設定でのみ変更可
- **ポーズ:** 盤面を非表示にする（タイマー不正防止）
- **undo:** 全手戻し対応（操作履歴を配列で保持）
- **チュートリアル:** ホーム「遊び方」+ 設定「チュートリアル再表示」から再アクセス可
- **アイコン:** SF Symbols準拠。絵文字は使用しない
- **フォント:** 英語=SF Pro Rounded、日本語=Noto Sans JP (Regular, SemiBold, Bold)
- **画面回転:** ポートレート固定
