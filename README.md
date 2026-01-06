# Wordlish

GleamによるWordleクローン。CLI版とWeb版の両方で動作。

## Play

**Web版**: https://lacolaco.github.io/wordlish/

**CLI版**:
```sh
gleam run
```

## Features

- 5文字の英単語を6回以内に当てるゲーム
- 約2,300の正解候補 + 約10,600の有効な推測単語
- ヒント機能: 残りの候補を表示
- ランダム入力ボタン: 候補からランダムに選択

## Development

```sh
make run        # CLI版を実行
make test       # テスト実行
make serve-web  # Web版をローカルで起動 (http://localhost:8080)
make gen-words  # 単語リストを再生成
```

## Tech Stack

- [Gleam](https://gleam.run/) - 型安全な関数型言語
- [Lustre](https://hexdocs.pm/lustre/) - Elm ArchitectureベースのWebフレームワーク
