import gleam/list
import gleam/result
import gleam/string
import simplifile

/// Normalize word to uppercase
pub fn normalize(word: String) -> String {
  string.uppercase(word)
}

/// Check if a word is a valid guess (5 letters and in dictionary)
pub fn is_valid_guess(word: String) -> Bool {
  let normalized = normalize(word)
  string.length(normalized) == 5 && is_in_dictionary(normalized)
}

/// Get a random answer word
pub fn get_random_answer() -> String {
  load_answers()
  |> list.shuffle
  |> list.first
  |> result.unwrap("CRANE")
  |> string.uppercase
}

fn is_in_dictionary(word: String) -> Bool {
  let lowercase = string.lowercase(word)
  let answers = load_answers()
  let guesses = load_guesses()
  list.contains(answers, lowercase) || list.contains(guesses, lowercase)
}

fn load_answers() -> List(String) {
  load_word_file("priv/answers.txt")
}

fn load_guesses() -> List(String) {
  load_word_file("priv/guesses.txt")
}

fn load_word_file(path: String) -> List(String) {
  case simplifile.read(path) {
    Ok(content) ->
      content
      |> string.split("\n")
      |> list.filter(fn(w) { string.length(w) == 5 })
    Error(_) -> []
  }
}
