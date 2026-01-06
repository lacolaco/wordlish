import gleam/list
import gleam/result
import gleam/string
import wordlish/words_data

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
  words_data.answers
  |> list.shuffle
  |> list.first
  |> result.unwrap("crane")
  |> string.uppercase
}

fn is_in_dictionary(word: String) -> Bool {
  let lowercase = string.lowercase(word)
  list.contains(words_data.answers, lowercase)
  || list.contains(words_data.guesses, lowercase)
}
