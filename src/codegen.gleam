import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  case generate_words_data() {
    Ok(stats) -> {
      io.println("Generated: src/wordlish/words_data.gleam")
      io.println("  answers: " <> stats.answers <> " words")
      io.println("  guesses: " <> stats.guesses <> " words")
    }
    Error(err) -> {
      io.println("Error: " <> err)
    }
  }
}

type Stats {
  Stats(answers: String, guesses: String)
}

fn generate_words_data() -> Result(Stats, String) {
  use answers <- result.try(read_word_list("priv/answers.txt"))
  use guesses <- result.try(read_word_list("priv/guesses.txt"))

  let content = generate_gleam_code(answers, guesses)

  case simplifile.write("src/wordlish/words_data.gleam", content) {
    Ok(_) ->
      Ok(Stats(
        answers: int_to_string(list.length(answers)),
        guesses: int_to_string(list.length(guesses)),
      ))
    Error(_) -> Error("Failed to write src/wordlish/words_data.gleam")
  }
}

fn read_word_list(path: String) -> Result(List(String), String) {
  case simplifile.read(path) {
    Ok(content) -> {
      let words =
        content
        |> string.split("\n")
        |> list.filter(fn(w) { string.length(w) == 5 })
      Ok(words)
    }
    Error(_) -> Error("Failed to read " <> path)
  }
}

fn generate_gleam_code(answers: List(String), guesses: List(String)) -> String {
  let header =
    "// AUTO-GENERATED FILE - DO NOT EDIT
// Generated from priv/answers.txt and priv/guesses.txt
// Run: gleam run -m codegen

"

  let answers_code = generate_list_code("answers", answers)
  let guesses_code = generate_list_code("guesses", guesses)

  header <> answers_code <> "\n" <> guesses_code
}

fn generate_list_code(name: String, words: List(String)) -> String {
  let items =
    words
    |> list.map(fn(w) { "  \"" <> w <> "\"," })
    |> string.join("\n")

  "pub const " <> name <> " = [\n" <> items <> "\n]\n"
}

fn int_to_string(n: Int) -> String {
  case n {
    0 -> "0"
    _ -> do_int_to_string(n, "")
  }
}

fn do_int_to_string(n: Int, acc: String) -> String {
  case n {
    0 -> acc
    _ -> {
      let digit = n % 10
      let char = case digit {
        0 -> "0"
        1 -> "1"
        2 -> "2"
        3 -> "3"
        4 -> "4"
        5 -> "5"
        6 -> "6"
        7 -> "7"
        8 -> "8"
        _ -> "9"
      }
      do_int_to_string(n / 10, char <> acc)
    }
  }
}
