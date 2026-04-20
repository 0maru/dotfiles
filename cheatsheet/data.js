// Neovim Cheatsheet data
// level: 1 = 初級, 2 = 中級, 3 = 上級, 4 = さらに上
// mode: N / I / V / C / O / NV / OV / "" (mode-less, e.g. pure vim motions)

window.CHEATSHEET = {
  meta: {
    leader: "Space",
    theme: "github_dark_dimmed",
    pluginMgr: "lazy.nvim",
    pluginCount: 40,
  },

  tabs: [
    {
      id: "daily",
      label: "Daily",
      sublabel: "毎日の起点 / 移動 / バッファ",
      sections: [
        {
          title: "起動直後",
          items: [
            { mode: "N", keys: ["Space", "w"], desc: "保存", lv: 1 },
            { mode: "N", keys: ["Space", "q"], desc: "現在ウィンドウを閉じる", lv: 1 },
            { mode: "N", keys: ["Esc"], desc: "検索ハイライトを消す", lv: 1 },
            { mode: "N", keys: ["Space", "?"], desc: "バッファのキーマップ一覧", lv: 2 },
            { mode: "C", keys: [":wq"], desc: "保存して終了", lv: 1 },
            { mode: "C", keys: [":q!"], desc: "保存せず終了", lv: 1 },
          ],
        },
        {
          title: "検索 / ファイル移動 (snacks picker)",
          items: [
            { mode: "N", keys: ["Space", "ff"], desc: "ファイル検索", lv: 1 },
            { mode: "N", keys: ["Space", "fr"], desc: "最近開いたファイル", lv: 1 },
            { mode: "N", keys: ["Space", "fb"], desc: "バッファ一覧", lv: 1 },
            { mode: "N", keys: ["Space", "fg"], desc: "全文検索", lv: 1 },
            { mode: "N", keys: ["Space", "fw"], desc: "カーソル語で grep", lv: 2 },
            { mode: "N", keys: ["Space", ":"], desc: "コマンド履歴", lv: 2 },
            { mode: "N", keys: ["Space", "sh"], desc: "ヘルプ検索", lv: 2 },
          ],
        },
        {
          title: "バッファ / 分割 / ファイラー",
          items: [
            { mode: "N", keys: ["Shift+h"], desc: "前のバッファ", lv: 1 },
            { mode: "N", keys: ["Shift+l"], desc: "次のバッファ", lv: 1 },
            { mode: "N", keys: ["Space", "bd"], desc: "バッファを閉じる", lv: 1 },
            { mode: "N", keys: ["Ctrl+h"], desc: "左ペインへ", lv: 1 },
            { mode: "N", keys: ["Ctrl+j"], desc: "下ペインへ", lv: 1 },
            { mode: "N", keys: ["Ctrl+k"], desc: "上ペインへ", lv: 1 },
            { mode: "N", keys: ["Ctrl+l"], desc: "右ペインへ (WezTermまたぐ)", lv: 1 },
            { mode: "N", keys: ["Space", "e"], desc: "Oil で親ディレクトリ", lv: 2 },
            { mode: "N", keys: ["Space", "E"], desc: "Neo-tree トグル", lv: 2 },
            { mode: "N", keys: ["Space", "tt"], desc: "ターミナル開閉", lv: 2 },
          ],
        },
        {
          title: "素の Vim 基本動作",
          items: [
            { keys: ["h"], desc: "左", lv: 1 },
            { keys: ["j"], desc: "下 (折り返し追従 / no-count時)", lv: 1 },
            { keys: ["k"], desc: "上 (折り返し追従 / no-count時)", lv: 1 },
            { keys: ["l"], desc: "右", lv: 1 },
            { keys: ["w"], desc: "次の単語の先頭", lv: 1 },
            { keys: ["b"], desc: "前の単語の先頭", lv: 1 },
            { keys: ["e"], desc: "単語の末尾", lv: 1 },
            { keys: ["0"], desc: "行頭 (列0)", lv: 1 },
            { keys: ["^"], desc: "行の最初の非空白", lv: 1 },
            { keys: ["$"], desc: "行末", lv: 1 },
            { keys: ["/", "pat"], desc: "前方検索", lv: 1 },
            { keys: ["n"], desc: "次のマッチ", lv: 1 },
            { keys: ["N"], desc: "前のマッチ", lv: 1 },
            { keys: ["u"], desc: "Undo", lv: 1 },
            { keys: ["Ctrl+r"], desc: "Redo", lv: 1 },
            { keys: ["."], desc: "直前の変更を繰り返す", lv: 2 },
          ],
        },
      ],
    },

    {
      id: "code",
      label: "Code",
      sublabel: "LSP / 構文 / 整形",
      sections: [
        {
          title: "LSP と診断",
          items: [
            { mode: "N", keys: ["gd"], desc: "定義へジャンプ", lv: 1 },
            { mode: "N", keys: ["Space", "k"], desc: "hover を開く", lv: 1 },
            { mode: "N", keys: ["Space", "la"], desc: "コードアクション", lv: 2 },
            { mode: "N", keys: ["[d"], desc: "前の診断", lv: 1 },
            { mode: "N", keys: ["]d"], desc: "次の診断", lv: 1 },
            { mode: "N", keys: ["Space", "ld"], desc: "行の診断をフロート", lv: 2 },
            { mode: "I", keys: ["Tab"], desc: "inline completion 確定", lv: 2 },
          ],
        },
        {
          title: "整形 / 編集補助",
          items: [
            { mode: "NV", keys: ["Space", "cf"], desc: "Conform で明示フォーマット", lv: 2 },
            { mode: "N", keys: ["保存"], desc: "JS/TS/JSON/CSS は biome 整形", lv: 1, static: true },
            { mode: "N", keys: ["LSP fmt"], desc: "Conform対象は fallback させない", lv: 3, static: true },
            { mode: "I", keys: ["入力"], desc: "blink.cmp の補完 / signature", lv: 2, static: true },
            { mode: "I", keys: ["入力"], desc: "nvim-autopairs が括弧 / 引用符", lv: 1, static: true },
            { mode: "I", keys: ["HTML"], desc: "nvim-ts-autotag 閉じタグ補完", lv: 2, static: true },
          ],
        },
        {
          title: "シンボル / Flash ジャンプ",
          items: [
            { mode: "N", keys: ["Space", "ss"], desc: "バッファの LSP シンボル", lv: 2 },
            { mode: "N", keys: ["Space", "sw"], desc: "ワークスペースシンボル", lv: 2 },
            { mode: "N", keys: ["Space", ";"], desc: "dropbar で文脈を選ぶ", lv: 3 },
            { mode: "N", keys: ["[;"], desc: "文脈の先頭へ", lv: 3 },
            { mode: "N", keys: ["];"], desc: "次の文脈へ", lv: 3 },
            { mode: "N", keys: ["s"], desc: "Flash 画面内ジャンプ", lv: 2 },
            { mode: "N", keys: ["S"], desc: "Flash Treesitter ジャンプ", lv: 3 },
            { mode: "OV", keys: ["r"], desc: "Flash remote (operator/visual)", lv: 4 },
            { mode: "OV", keys: ["R"], desc: "Flash treesitter search", lv: 4 },
            { mode: "C", keys: ["Ctrl+s"], desc: "検索中に Flash search 切替", lv: 4 },
          ],
        },
        {
          title: "Treesitter テキストオブジェクト",
          items: [
            { keys: ["]f"], desc: "次の関数先頭", lv: 3 },
            { keys: ["[f"], desc: "前の関数先頭", lv: 3 },
            { keys: ["]F"], desc: "次の関数末尾", lv: 3 },
            { keys: ["[F"], desc: "前の関数末尾", lv: 3 },
            { keys: ["]c"], desc: "次のクラス先頭", lv: 3 },
            { keys: ["[c"], desc: "前のクラス先頭", lv: 3 },
            { keys: ["]a"], desc: "次の引数", lv: 3 },
            { keys: ["[a"], desc: "前の引数", lv: 3 },
            { keys: ["af"], desc: "関数 outer", lv: 3 },
            { keys: ["if"], desc: "関数 inner", lv: 3 },
            { keys: ["ac"], desc: "クラス outer", lv: 3 },
            { keys: ["ic"], desc: "クラス inner", lv: 3 },
            { keys: ["aa"], desc: "引数 outer", lv: 3 },
            { keys: ["ia"], desc: "引数 inner", lv: 3 },
            { mode: "N", keys: ["Space", "tc"], desc: "Treesitter Context トグル", lv: 2 },
          ],
        },
        {
          title: "ビジュアル編集 / マクロ",
          items: [
            { mode: "V", keys: ["<"], desc: "選択維持で左インデント", lv: 1 },
            { mode: "V", keys: [">"], desc: "選択維持で右インデント", lv: 1 },
            { mode: "V", keys: ["J"], desc: "選択行を下へ移動", lv: 2 },
            { mode: "V", keys: ["K"], desc: "選択行を上へ移動", lv: 2 },
            { keys: ["Ctrl+v"], desc: "矩形選択", lv: 2 },
            { keys: ["q", "reg"], desc: "マクロ録画開始", lv: 3 },
            { keys: ["q"], desc: "録画終了", lv: 3 },
            { keys: ["@", "reg"], desc: "マクロ再生", lv: 3 },
            { keys: ["@@"], desc: "直前マクロを再生", lv: 3 },
            { keys: ["*", "→", "cgn", "→", "."], desc: "同一単語を順に置換", lv: 4, combo: true },
          ],
        },
      ],
    },

    {
      id: "git",
      label: "Git",
      sublabel: "操作 / 差分 / ハンク",
      sections: [
        {
          title: "Git 操作の起点",
          items: [
            { mode: "N", keys: ["Space", "gg"], desc: "Lazygit を開く", lv: 1 },
            { mode: "N", keys: ["Space", "gs"], desc: "Git status picker", lv: 2 },
            { mode: "N", keys: ["Space", "gl"], desc: "Git log picker", lv: 2 },
            { mode: "C", keys: [":DiffviewOpen"], desc: "差分ビューを開く", lv: 2 },
            { mode: "C", keys: [":DiffviewClose"], desc: "差分ビューを閉じる", lv: 2 },
            { mode: "C", keys: [":DiffviewFileHistory %"], desc: "現在ファイルの履歴", lv: 3 },
          ],
        },
        {
          title: "Gitsigns ハンク",
          items: [
            { mode: "N", keys: ["]h"], desc: "次のハンク", lv: 2 },
            { mode: "N", keys: ["[h"], desc: "前のハンク", lv: 2 },
            { mode: "NV", keys: ["Space", "hs"], desc: "ハンクを stage", lv: 2 },
            { mode: "NV", keys: ["Space", "hr"], desc: "ハンクを reset", lv: 2 },
            { mode: "N", keys: ["Space", "hS"], desc: "バッファ全体を stage", lv: 3 },
            { mode: "N", keys: ["Space", "hR"], desc: "バッファ全体を reset", lv: 3 },
            { mode: "N", keys: ["Space", "hu"], desc: "stage 済みを戻す", lv: 3 },
            { mode: "N", keys: ["Space", "hP"], desc: "ハンクを preview", lv: 2 },
            { mode: "N", keys: ["Space", "hb"], desc: "行の blame を開く", lv: 2 },
            { mode: "N", keys: ["Space", "tb"], desc: "行末 blame トグル", lv: 2 },
            { mode: "N", keys: ["Space", "td"], desc: "削除行の表示トグル", lv: 3 },
            { mode: "N", keys: ["Space", "hd"], desc: "index との差分", lv: 3 },
            { mode: "N", keys: ["Space", "hD"], desc: "HEAD との差分", lv: 3 },
            { mode: "OV", keys: ["ih"], desc: "ハンクをテキストオブジェクトに", lv: 4 },
          ],
        },
      ],
    },

    {
      id: "docs",
      label: "Docs",
      sublabel: "Markdown / 画像 / CSV",
      sections: [
        {
          title: "Markdown / 画像貼り付け",
          items: [
            { mode: "N", keys: ["Space", "p"], desc: "クリップボード画像を貼る", lv: 2 },
            { mode: "N", keys: ["assets/"], desc: "画像保存先", lv: 1, static: true },
            { mode: "N", keys: [".md"], desc: "相対パスの画像リンクを挿入", lv: 2, static: true },
            { mode: "N", keys: [".mdx"], desc: "mdx.nvim 用 filetype", lv: 3, static: true },
            { mode: "N", keys: ["view"], desc: "Markview で表示補助", lv: 2, static: true },
          ],
        },
        {
          title: "CSV と一時ビュー",
          items: [
            { mode: "C", keys: [":CsvViewToggle"], desc: "CSV 表示切替", lv: 2 },
            { mode: "NV", keys: ["Tab"], desc: "次のフィールド", lv: 2 },
            { mode: "NV", keys: ["Shift+Tab"], desc: "前のフィールド", lv: 2 },
            { mode: "NV", keys: ["Enter"], desc: "次の行", lv: 2 },
            { mode: "NV", keys: ["Shift+Enter"], desc: "前の行", lv: 2 },
            { mode: "V", keys: ["if"], desc: "CSV フィールド inner", lv: 3 },
            { mode: "V", keys: ["af"], desc: "CSV フィールド outer", lv: 3 },
            { mode: "N", keys: ["q"], desc: "help/man/qf/checkhealth を閉じる", lv: 1 },
          ],
        },
      ],
    },

    {
      id: "setup",
      label: "Setup",
      sublabel: "自動動作 / 見た目 / プラグイン",
      sections: [
        {
          title: "自動動作",
          notes: [
            "FocusGained / BufEnter / CursorHold で checktime → 外部変更を自動反映",
            "ヤンク時は 200ms ハイライト",
            "前回閉じた位置にカーソルを復元",
            "Markdown / MDX 以外では保存時に末尾空白を削除",
            "FocusLost / BufLeave で自動保存",
            "q で閉じる専用バッファを用意 (help / man / qf / checkhealth など)",
          ],
        },
        {
          title: "見た目 / 操作感",
          notes: [
            "テーマ: github_dark_dimmed",
            "相対行番号 / カーソル行ハイライト / signcolumn 常時表示",
            "2 スペースインデント / 折り返し無効 / colorcolumn=100",
            "clipboard = unnamedplus",
            "listchars 表示",
            "lualine.nvim (statusline) + bufferline.nvim",
            "hlchunk.nvim でインデント / チャンク補助",
            "nvim-scrollbar + dropbar.nvim",
          ],
        },
        {
          title: "プラグイン (40)",
          groups: [
            {
              label: "検索 / 起動",
              plugins: ["snacks.nvim", "which-key.nvim", "dashboard-nvim"],
            },
            {
              label: "ファイラー",
              plugins: ["oil.nvim", "neo-tree.nvim", "smart-splits.nvim"],
            },
            {
              label: "編集",
              plugins: [
                "blink.cmp",
                "conform.nvim",
                "flash.nvim",
                "nvim-treesitter",
                "csvview.nvim",
                "dial.nvim",
                "nvim-autopairs",
                "nvim-ts-autotag",
              ],
            },
            {
              label: "LSP",
              plugins: [
                "nvim-lspconfig",
                "typescript-tools.nvim",
                "rustaceanvim",
                "namu.nvim",
                "tiny-inline-diagnostic.nvim",
              ],
            },
            {
              label: "Git / 文書",
              plugins: [
                "gitsigns.nvim",
                "diffview.nvim",
                "img-clip.nvim",
                "markview.nvim",
                "grug-far.nvim",
                "glance.nvim",
                "nvim-ufo",
              ],
            },
            {
              label: "見た目",
              plugins: [
                "lualine.nvim",
                "bufferline.nvim",
                "hlchunk.nvim",
                "nvim-scrollbar",
                "dropbar.nvim",
              ],
            },
          ],
        },
      ],
    },
  ],
};
