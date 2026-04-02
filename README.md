# cmux-workspace

[cmux](https://github.com/manaflow-ai/cmux) 向けの、AIコーディングエージェント（Claude Code / Gemini / Codex）に最適化されたターミナルワークスペースです。

## レイアウト

```
┌─────────────────┬──────────────────────────────┐
│ [yazi | MD Prev] │                              │
│  surfaces切替    │      AIターミナル (メイン)      │
│                 │                              │
├─────────────────┤                              │
│                 ├──────────────────────────────┤
│    lazygit      │          シェル               │
│                 │                              │
└─────────────────┴──────────────────────────────┘
```

| ペイン | ツール | 用途 |
|--------|--------|------|
| 左上 (タブ 1) | yazi | ファイルツリーのナビゲーション |
| 左上 (タブ 2) | glow + watchexec | Markdownのライブプレビュー |
| 左下 | lazygit | Gitの状態確認・差分表示・ステージング |
| 右上 | zsh | AIターミナル（claude, gemini, codex） |
| 右下 | zsh | 補助シェル |

## セットアップ

```bash
git clone https://github.com/LattyCat/cmux-workspace.git ~/app/cmux-workspace
cd ~/app/cmux-workspace
chmod +x setup.sh
./setup.sh
```

## 使い方

`setup.sh` を実行すると、`cmux.json` が `~/.config/cmux/cmux.json` にリンクされ、コマンドパレットからすぐに使えます。

1. cmux を開き、`Cmd+J` を押して **AI Dev Workspace** を選択します

2. AIターミナルのペインで、使いたいエージェントを起動します：

```bash
claude              # Claude Code
claude --resume     # 前回のセッションを再開
gemini              # Gemini
codex               # Codex
```

## ファイル構成

```
cmux-workspace/
├── setup.sh                  # 依存ツールのインストールと設定のシンボリックリンク
├── cmux.json                 # ワークスペースのレイアウト定義
├── scripts/
│   └── md-preview.sh         # Markdownライブプレビューのラッパースクリプト
├── config/
│   ├── yazi.toml             # yazi の狭幅ペイン向け設定
│   └── ghostty-append.conf   # Ghostty のスクロールバック設定
├── .gitignore
└── README.md
```

## 依存ツール

`setup.sh` により自動でインストールされます：

- [cmux](https://github.com/manaflow-ai/cmux) - Ghostty ベースのターミナル
- [Claude Code](https://formulae.brew.sh/cask/claude-code) - AIコーディングエージェント
- [yazi](https://github.com/sxyazi/yazi) - ターミナルファイルマネージャー
- [lazygit](https://github.com/jesseduffield/lazygit) - Git の TUI クライアント
- [glow](https://github.com/charmbracelet/glow) - Markdown レンダラー
- [watchexec](https://github.com/watchexec/watchexec) - ファイル監視ツール

## ライセンス

MIT
