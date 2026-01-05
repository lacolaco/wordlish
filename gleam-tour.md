# Gleam言語ツアー - Wordlishで学ぶ

このドキュメントは、Wordlish（Wordleクローン）のコードを題材にGleam言語の基本を学ぶツアーです。

## 目次

1. [プロジェクト構成](#1-プロジェクト構成)
2. [モジュールとインポート](#2-モジュールとインポート)
3. [関数定義](#3-関数定義)
4. [カスタム型](#4-カスタム型)
5. [パターンマッチング](#5-パターンマッチング)
6. [パイプ演算子](#6-パイプ演算子)
7. [コレクション操作](#7-コレクション操作)
8. [Result型とエラーハンドリング](#8-result型とエラーハンドリング)
9. [Option型](#9-option型)
10. [レコード更新構文](#10-レコード更新構文)
11. [副作用とIO](#11-副作用とio)
12. [テスト](#12-テスト)

---

## 1. プロジェクト構成

### ディレクトリ構造

```
wordlish/
├── gleam.toml          # プロジェクト設定
├── src/
│   ├── wordlish.gleam  # メインエントリポイント
│   └── wordlish/
│       ├── judge.gleam # 判定ロジック
│       ├── game.gleam  # ゲーム状態管理
│       ├── words.gleam # 単語リスト
│       └── ui.gleam    # 表示
├── test/
│   └── wordlish/       # テストファイル
└── priv/               # 静的ファイル（後述）
```

### privディレクトリ

`priv` = **"private"** の略。Erlang/Elixir/Gleamエコシステムで慣例的に使われる**静的ファイル用ディレクトリ**。

```
priv/
├── answers.txt   # 答え単語リスト（2,314語）
└── guesses.txt   # 推測可能単語リスト（10,656語）
```

**用途:**
- データファイル（単語リスト、設定ファイル）
- テンプレート
- 静的アセット（画像、CSS、JS）
- SQLマイグレーションファイル

**参照方法:**

```gleam
// src/wordlish/words.gleam
fn load_answers() -> List(String) {
  load_word_file("priv/answers.txt")  // 相対パスで参照
}
```

**注意:** 相対パス`"priv/..."`で参照しているため、実行時のカレントディレクトリがプロジェクトルートである必要がある。Erlangでは`code:priv_dir(app_name)`でパスを取得できるが、開発用CLIとしてはこの方法で問題ない。

### gleam.toml

```toml
name = "wordlish"
version = "1.0.0"

[dependencies]
gleam_stdlib = ">= 0.44.0 and < 2.0.0"
gleam_community_ansi = ">= 1.4.3 and < 2.0.0"
stdin = ">= 2.0.2 and < 3.0.0"
simplifile = ">= 2.3.2 and < 3.0.0"

[dev-dependencies]
gleeunit = ">= 1.0.0 and < 2.0.0"
```

**ポイント:**
- `[dependencies]`: 本番で使う依存関係
- `[dev-dependencies]`: テスト時のみ使う依存関係
- バージョン指定は `">= X and < Y"` 形式

---

## 2. モジュールとインポート

### 基本的なインポート

```gleam
// src/wordlish/judge.gleam
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
```

**構文:**
- `import モジュール名` - モジュール全体をインポート
- `import モジュール名.{item1, item2}` - 特定の項目を直接インポート
- `type 型名` - 型のみをインポート（値コンストラクタなし）

### 使い分け

```gleam
// モジュール修飾で使用
let count = dict.get(acc, c) |> result.unwrap(0)

// 直接インポートした場合
case maybe_result {
  Some(result) -> ...  // option.Some ではなく Some
  None -> ...          // option.None ではなく None
}
```

**ベストプラクティス:**
- 頻繁に使う型やコンストラクタは直接インポート
- 関数はモジュール修飾で呼び出す（可読性のため）

---

## 3. 関数定義

### パブリック関数

```gleam
// src/wordlish/judge.gleam
pub fn judge(guess: String, answer: String) -> List(#(String, LetterResult)) {
  // ...
}
```

**構文:**
- `pub fn` - 外部モジュールから呼び出し可能
- `fn` - 同一モジュール内でのみ使用可能
- 引数は `名前: 型` 形式
- 戻り値は `-> 型` で指定

### プライベート関数

```gleam
// src/wordlish/judge.gleam
fn count_letters(chars: List(String)) -> Dict(String, Int) {
  list.fold(chars, dict.new(), fn(acc, c) {
    let count = dict.get(acc, c) |> result.unwrap(0)
    dict.insert(acc, c, count + 1)
  })
}
```

### 無名関数（ラムダ）

```gleam
list.fold(chars, dict.new(), fn(acc, c) {
  // fn(引数) { 本体 }
})

list.map(alphabet, fn(letter) {
  // ...
})
```

---

## 4. カスタム型

### 列挙型（バリアント型）

```gleam
// src/wordlish/judge.gleam
pub type LetterResult {
  Correct   // 正しい位置
  Present   // 含まれるが位置が違う
  Absent    // 含まれない
}
```

**ポイント:**
- 各バリアントは大文字始まり
- データを持たない単純な列挙

### データを持つバリアント

```gleam
// src/wordlish/game.gleam
pub type GameOutcome {
  Won(attempts: Int)     // 勝利（試行回数を保持）
  Lost(answer: String)   // 敗北（正解を保持）
  InProgress             // ゲーム中
}
```

**ポイント:**
- バリアントごとに異なるデータを持てる
- フィールド名は省略可能（`Won(Int)`でも可）

### レコード型

```gleam
// src/wordlish/game.gleam
pub type GameState {
  GameState(answer: String, guesses: List(String))
}
```

**ポイント:**
- 単一バリアントの型はレコードとして使う
- フィールドアクセス: `state.answer`, `state.guesses`

---

## 5. パターンマッチング

### case式の基本

```gleam
// src/wordlish/ui.gleam
case result {
  Correct -> ansi.green(letter)
  Present -> ansi.yellow(letter)
  Absent -> ansi.dim(string.lowercase(letter))
}
```

### タプルのパターンマッチング

```gleam
// src/wordlish/judge.gleam
let #(g, a) = pair  // タプルを分解

case g == a {
  True -> ...
  False -> ...
}
```

### ガード条件（if）

```gleam
// src/wordlish/judge.gleam
fn consume_letter(remaining: Dict(String, Int), letter: String) -> Dict(String, Int) {
  case dict.get(remaining, letter) {
    Ok(count) if count > 1 -> dict.insert(remaining, letter, count - 1)
    Ok(_) -> dict.delete(remaining, letter)
    Error(_) -> remaining
  }
}
```

**構文:** `パターン if 条件 -> 式`

### 複数条件のマッチング

```gleam
// src/wordlish/game.gleam
case guess == state.answer, attempts >= max_attempts {
  True, _ -> #(new_state, Won(attempts))
  _, True -> #(new_state, Lost(state.answer))
  _, _ -> #(new_state, InProgress)
}
```

**ポイント:**
- カンマ区切りで複数の値を同時にマッチ
- `_` はワイルドカード（任意の値にマッチ）

### let assert

```gleam
// src/wordlish.gleam
let assert Ok(result) = game.get_last_result(new_state)
```

**注意:**
- マッチしない場合はクラッシュする
- 「必ず成功する」ことが保証されている場合のみ使用

---

## 6. パイプ演算子

### 基本構文

```gleam
// src/wordlish/words.gleam
content
|> string.split("\n")
|> list.filter(fn(w) { string.length(w) == 5 })
```

**等価なコード:**
```gleam
list.filter(string.split(content, "\n"), fn(w) { string.length(w) == 5 })
```

### 連続したパイプ

```gleam
// src/wordlish/ui.gleam
alphabet
|> list.map(fn(letter) {
  case dict.get(keyboard, letter) {
    Ok(Correct) -> ansi.green(letter)
    Ok(Present) -> ansi.yellow(letter)
    Ok(Absent) -> ansi.dim(string.lowercase(letter))
    Error(Nil) -> letter
  }
})
|> string.join(" ")
```

**ポイント:**
- 左の値が次の関数の**第1引数**として渡される
- データの変換フローが読みやすくなる

---

## 7. コレクション操作

### List

```gleam
// リストリテラル
let alphabet = ["A", "B", "C", "D", "E", ...]

// 先頭に追加（O(1)）
[new_item, ..existing_list]

// 末尾に追加（O(n)）
list.append(existing_list, [new_item])

// 逆順
list.reverse(my_list)
```

### list.fold - 畳み込み

```gleam
// src/wordlish/judge.gleam
list.fold(chars, dict.new(), fn(acc, c) {
  let count = dict.get(acc, c) |> result.unwrap(0)
  dict.insert(acc, c, count + 1)
})
```

**引数:**
1. `chars` - 処理するリスト
2. `dict.new()` - 初期値（アキュムレータ）
3. `fn(acc, c)` - 各要素を処理する関数

**ポイント:**
- `acc`（アキュムレータ）に結果を蓄積
- リストを1つの値に集約するときに使う

### list.map - 変換

```gleam
// src/wordlish/ui.gleam
results
|> list.map(fn(pair) {
  let #(letter, result) = pair
  format_letter(letter, result)
})
```

**ポイント:**
- 各要素を変換して新しいリストを作成
- 要素数は変わらない

### list.filter - 絞り込み

```gleam
// src/wordlish/words.gleam
content
|> string.split("\n")
|> list.filter(fn(w) { string.length(w) == 5 })
```

### list.zip - 結合

```gleam
// src/wordlish/judge.gleam
list.zip(guess_chars, answer_chars)
// ["C", "R", "A", "N", "E"], ["C", "R", "A", "T", "E"]
// → [#("C", "C"), #("R", "R"), #("A", "A"), #("N", "T"), #("E", "E")]
```

### list.flat_map - 平坦化マップ

```gleam
// src/wordlish/game.gleam
state.guesses
|> list.flat_map(fn(guess) { judge.judge(guess, state.answer) })
```

**ポイント:**
- 各要素をリストに変換し、結果を1つのリストに平坦化
- `map` + `flatten` の組み合わせ

### Dict（辞書）

```gleam
// 新規作成
dict.new()

// 挿入
dict.insert(acc, key, value)

// 取得（Result型を返す）
dict.get(acc, key)  // Ok(value) または Error(Nil)

// キーの存在確認
dict.has_key(remaining, letter)

// 削除
dict.delete(remaining, letter)
```

---

## 8. Result型とエラーハンドリング

### Result型の定義

```gleam
// 標準ライブラリで定義済み
pub type Result(value, error) {
  Ok(value)
  Error(error)
}
```

### 使用例

```gleam
// src/wordlish/game.gleam
pub fn get_last_result(state: GameState) -> Result(List(#(String, LetterResult)), Nil) {
  case list.last(state.guesses) {
    Ok(last_guess) -> Ok(judge.judge(last_guess, state.answer))
    Error(_) -> Error(Nil)
  }
}
```

### result.unwrap - デフォルト値付きアンラップ

```gleam
// src/wordlish/judge.gleam
let count = dict.get(acc, c) |> result.unwrap(0)
// Ok(n) → n
// Error(_) → 0（デフォルト値）
```

### result.map - 成功値の変換

```gleam
// src/wordlish/game.gleam
list.last(state.guesses)
|> result.map(fn(g) { g == state.answer })
|> result.unwrap(False)
```

---

## 9. Option型

### Option型の定義

```gleam
// 標準ライブラリで定義済み
pub type Option(value) {
  Some(value)
  None
}
```

### 使用例 - 2パスアルゴリズム

```gleam
// src/wordlish/judge.gleam
fn pass1(...) -> #(List(Option(LetterResult)), Dict(String, Int)) {
  // ...
  case g == a {
    True -> {
      let new_remaining = consume_letter(remaining, g)
      #([Some(Correct), ..results], new_remaining)  // 確定した結果
    }
    False -> #([None, ..results], remaining)  // 未確定
  }
}

fn pass2(...) -> List(LetterResult) {
  // ...
  case maybe_result {
    Some(result) -> #([result, ..results], remaining)  // Pass1で確定済み
    None -> {
      // Pass2で判定
      case dict.has_key(remaining, g) {
        True -> #([Present, ..results], new_remaining)
        False -> #([Absent, ..results], remaining)
      }
    }
  }
}
```

**Result vs Option:**
- `Result(value, error)` - 失敗の理由がある場合
- `Option(value)` - 値があるかないかだけ

---

## 10. レコード更新構文

### スプレッド構文

```gleam
// src/wordlish/game.gleam
let new_state = GameState(..state, guesses: new_guesses)
```

**構文:** `型名(..既存の値, フィールド名: 新しい値)`

**ポイント:**
- 既存のレコードをコピーして一部だけ更新
- Gleamの値はイミュータブルなので、新しいレコードが作られる

---

## 11. 副作用とIO

### io.print / io.println

```gleam
// src/wordlish/ui.gleam
import gleam/io

pub fn print_welcome() -> Nil {
  io.println("")
  io.println(ansi.bold("Wordlish") <> " - 5文字の単語を当てよ (6回まで)")
  io.println("")
}

pub fn print_prompt(attempt: Int) -> Nil {
  io.print(ansi.cyan(int.to_string(attempt) <> "> "))  // 改行なし
}
```

### 文字列結合

```gleam
// <> 演算子で文字列を結合
ansi.bold("Wordlish") <> " - 5文字の単語を当てよ"
```

### ファイル読み込み

```gleam
// src/wordlish/words.gleam
import simplifile

fn load_word_file(path: String) -> List(String) {
  case simplifile.read(path) {
    Ok(content) ->
      content
      |> string.split("\n")
      |> list.filter(fn(w) { string.length(w) == 5 })
    Error(_) -> []
  }
}
```

### 標準入力

```gleam
// src/wordlish.gleam
import gleam/yielder
import stdin.{read_lines}

fn read_line() -> Result(String, Nil) {
  read_lines()
  |> yielder.first
  |> result.map(string.trim)
}
```

---

## 12. テスト

### テストファイルの配置

```
test/
└── wordlish/
    ├── judge_test.gleam
    ├── game_test.gleam
    └── ui_test.gleam
```

### テスト関数の定義

```gleam
// test/wordlish/judge_test.gleam
import gleeunit/should
import wordlish/judge.{Absent, Correct, Present, judge}

pub fn all_correct_test() {
  judge("HELLO", "HELLO")
  |> should.equal([
    #("H", Correct),
    #("E", Correct),
    #("L", Correct),
    #("L", Correct),
    #("O", Correct),
  ])
}
```

**ポイント:**
- 関数名は `_test` で終わる
- `pub fn` で公開する
- `should.equal(期待値)` で検証

### アサーションの種類

```gleam
// 等価性
result |> should.equal(expected)

// 真偽値
result |> should.be_true
result |> should.be_false

// Result型
result |> should.be_ok
result |> should.be_error
```

### テスト実行

```bash
gleam test
```

---

## まとめ

### Gleamの特徴（このプロジェクトから学べること）

1. **静的型付け** - コンパイル時に型エラーを検出
2. **イミュータブル** - 値は変更できない、新しい値を作成
3. **パターンマッチング** - case式で網羅的な分岐
4. **Result/Option** - nullやexceptionの代わりに明示的なエラー表現
5. **パイプ演算子** - データ変換フローの可読性向上
6. **モジュールシステム** - 明示的なインポート/エクスポート

### コマンドリファレンス

```bash
gleam build    # ビルド
gleam test     # テスト実行
gleam run      # 実行
gleam format   # コードフォーマット
gleam add pkg  # 依存関係追加
```

### 参考リンク

- [Gleam公式ドキュメント](https://gleam.run/documentation/)
- [Gleam言語ツアー](https://tour.gleam.run/)
- [Hex.pm（パッケージリポジトリ）](https://hex.pm/)
