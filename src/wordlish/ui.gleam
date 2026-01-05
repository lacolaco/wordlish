import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam_community/ansi
import wordlish/judge.{type LetterResult, Absent, Correct, Present}

/// Format a single letter with color based on result
pub fn format_letter(letter: String, result: LetterResult) -> String {
  let styled_letter = " " <> letter <> " "
  case result {
    Correct -> ansi.black(ansi.bg_green(styled_letter))
    Present -> ansi.black(ansi.bg_yellow(styled_letter))
    Absent -> ansi.white(ansi.bg_bright_black(styled_letter))
  }
}

/// Format a complete guess result with colors
pub fn format_guess_result(results: List(#(String, LetterResult))) -> String {
  results
  |> list.map(fn(pair) {
    let #(letter, result) = pair
    format_letter(letter, result)
  })
  |> string.join("")
}

/// Print welcome message
pub fn print_welcome() -> Nil {
  io.println("")
  io.println(ansi.bold("Wordlish") <> " - 5文字の単語を当てよ (6回まで)")
  io.println("")
}

/// Print the guess result
pub fn print_guess_result(results: List(#(String, LetterResult))) -> Nil {
  io.println(format_guess_result(results))
}

/// Print win message
pub fn print_win(attempts: Int) -> Nil {
  io.println("")
  io.println(
    ansi.green("正解！ ") <> ansi.bold(int.to_string(attempts) <> "回で当てた"),
  )
}

/// Print lose message
pub fn print_lose(answer: String) -> Nil {
  io.println("")
  io.println(ansi.red("残念！ ") <> "正解は " <> ansi.bold(answer) <> " でした")
}

/// Print prompt for input
pub fn print_prompt(attempt: Int) -> Nil {
  io.print(ansi.cyan(int.to_string(attempt) <> "> "))
}

/// Print invalid guess message
pub fn print_invalid_guess() -> Nil {
  io.println(ansi.yellow("無効な単語です。5文字の英単語を入力してください。"))
}
