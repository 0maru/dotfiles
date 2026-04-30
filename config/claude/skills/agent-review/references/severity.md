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
- 自動チェックに同じエラーが出ている場合は、findings ではなく `自動チェック結果` に寄せる。
- `nit` が多い場合は最大 3 件に絞り、残りは省略する。
- 最終 findings は原則 10 件以内にする。

## Cross-Agent Corroboration

複数の Agent が独立に同じ箇所・同じ原因を指摘した場合、それは強いシグナル。集約時は次のように扱う:

- **2 Agent 以上が独立に同じ問題を指摘**: confidence を `high` に格上げし、severity も保守的にせず採用する。merged finding に `corroborated_by: [agent-a, agent-b]` を残す。
- **1 Agent のみの指摘で `confidence: medium`**: 根拠が具体的（file:line、再現条件、修正案）なら採用、抽象的なら確認ポイントに移す。
- **1 Agent のみで `confidence: low`**: findings から除外する。

なぜ重要か: 単独 Agent の指摘は専門観点に強くバイアスがかかる（例: security Agent は何でも怪しく見る）。独立した別観点の Agent も同じ箇所を懸念したなら、それは観点バイアスではなく実体ある問題である可能性が高い。

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
