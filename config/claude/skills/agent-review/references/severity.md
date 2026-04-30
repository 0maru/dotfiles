# Agent Review Severity

集約時は Agent の出力をそのまま採用しない。重複、低信頼度、好みの指摘、自動チェックとの重複を落としてから判定する。

## Severity

| Severity | 基準 | 総合判定への影響 |
|---|---|---|
| `blocker` | セキュリティ事故、データ破壊、確実な本番障害、CI が必ず落ちる問題 | `BLOCK` |
| `major` | 実行時バグ、ユーザー影響のある欠陥、重要なテスト不足、互換性破壊 | `REVISE` |
| `minor` | 小さなバグリスク、保守上の明確な悪化、限定的な edge case 漏れ | `PASS_WITH_NOTES` または `REVISE` |
| `nit` | 直す価値はあるがマージ判断を左右しないもの | `PASS_WITH_NOTES` |

## Confidence

| Confidence | 採用基準 |
|---|---|
| `high` | diff と周辺文脈から問題が再現可能または強く推定できる |
| `medium` | 問題の可能性が高く、確認すべき具体箇所と修正案がある |
| `low` | 仕様依存、文脈不足、推測が強い |

`low` は findings から除外し、必要なら `確認ポイント` に移す。

## 総合判定

| 条件 | 判定 |
|---|---|
| `blocker` が 1 件以上 | `BLOCK` |
| 自動チェック失敗、または `major` が 1 件以上 | `REVISE` |
| `minor` または `nit` のみ | `PASS_WITH_NOTES` |
| findings なし、自動チェックも問題なし | `PASS` |

自動チェックが実行できなかっただけでは `REVISE` にしない。`SKIPPED` として理由を明記する。

## 集約ルール

- 同一ファイル・同一原因の指摘は 1 件に統合する。
- severity が割れた場合は、根拠が具体的な Agent の severity を採用する。
- 自動チェックに同じエラーが出ている場合は、findings ではなく `自動チェック結果` に寄せる。**ただし** reviewer の指摘が自動チェックと根本原因は同じでも、修正案が型設計・スキーマ設計などより上位レイヤに踏み込んでいる場合は findings に残し、`note: 自動チェックと同根` を併記する（自動チェック側では表現できない設計レイヤの指摘を捨てない）。
- `nit` が多い場合は最大 3 件に絞り、残りは省略する。
- 最終 findings は原則 10 件以内にする。

## Cross-Agent Corroboration

複数の reviewer が独立に同じ箇所を指摘した場合、観点バイアスが分離されたうえで一致したシグナルなので「**確からしさ（confidence）**」が高い。一方で **severity（影響度）は impact 基準（上記 Severity 表）から動かさない**。合意の有無で BLOCK/REVISE が変わるのは impact-based モデルと矛盾するため、severity を機械的に昇格させない（例: 2 reviewer が独立に major と判断しても、impact が major のままなら blocker にしない）。

なぜ重要か: 単独 reviewer の指摘は専門観点に強くバイアスがかかる（例: security reviewer は何でも怪しく見る）。独立した別観点の reviewer も同じ箇所を懸念したなら、それは観点バイアスではなく実体ある問題である可能性が高い。だから confidence の格上げに使う。

- **confidence の固定**: 異なる reviewer-id（観点）が 2 個以上、独立に同箇所を指摘した場合、`confidence: high` に固定する（元が low/medium でも上げてよい）。同一 reviewer-id の重複は数えない（観点が分離されていない）。
- **severity の採用**: 各 reviewer が同じ severity を付けた場合 → そのまま採用。割れた場合は「集約ルール」に従い、**根拠が具体的な reviewer の severity** を採用する（最高 severity を機械的に採るのではなく、impact 表に整合する severity を選ぶ）。
- **`why` の統合**: 各 reviewer の根拠（why）を箇条書きで統合し、どの観点から問題視されたかを残す。
- **メタ情報**: `corroborated_by: [reviewer-a, reviewer-b]` を併記して、合意した reviewer を明示する。
- **single-reviewer の medium 指摘**: 1 reviewer のみで `confidence: medium` の場合、根拠が具体的（file:line + 再現条件 + 修正案）なら採用、抽象的なら `確認ポイント` に移す。
- **single-reviewer の low 指摘**: findings から除外する（観点バイアスの可能性が高い）。

## 自動チェック結果との関連表示

自動チェック失敗と同根の finding を残した場合（前述「集約ルール」末尾の例外）、二重カウント感を消すために以下を遵守する:

- finding 側に `note: 自動チェックと同根（{command} @ {file}:{line}）` を併記する。
- 自動チェック結果テーブルの `Notes` 列にも `関連 finding: {finding 短いタイトル}` を追記する。
- 総合判定はどちらか一方で REVISE/BLOCK にカウントする（自動チェック失敗の REVISE トリガーが優先。同根 finding の severity でさらに格上げするのは可）。

## False Positive 抑制

次は findings に載せない:

- 「より良いかもしれない」だけの設計提案
- formatter/linter が直すだけのスタイル
- 既存コードにもともと存在し、今回悪化していない問題
- 仕様が分からないと判断できない問題
- file/line または具体的 hunk を示せない問題
- 修正案が「考慮してください」だけで具体性がない問題

## 人間レビューに回すもの

AI が断定しづらいが重要なものは `人間レビューで見るとよい点` に分離する:

- 仕様判断
- UX コピーやデザイン判断
- product tradeoff
- 互換性を壊してよいか
- migration の実行タイミングや運用判断
