import gleeunit/should
import wordlish/words

// --- normalize tests ---

pub fn normalize_lowercase_test() {
  words.normalize("hello")
  |> should.equal("HELLO")
}

pub fn normalize_mixed_case_test() {
  words.normalize("HeLLo")
  |> should.equal("HELLO")
}

pub fn normalize_already_upper_test() {
  words.normalize("HELLO")
  |> should.equal("HELLO")
}

// --- is_valid_guess tests ---

pub fn valid_guess_test() {
  words.is_valid_guess("CRANE")
  |> should.be_true
}

pub fn invalid_guess_too_short_test() {
  words.is_valid_guess("CRAN")
  |> should.be_false
}

pub fn invalid_guess_too_long_test() {
  words.is_valid_guess("CRANES")
  |> should.be_false
}

pub fn invalid_guess_not_in_dictionary_test() {
  words.is_valid_guess("ZZZZZ")
  |> should.be_false
}

// --- get_random_answer tests ---

pub fn random_answer_is_valid_test() {
  let answer = words.get_random_answer()
  // Answer should be 5 characters
  answer
  |> words.is_valid_guess
  |> should.be_true
}
