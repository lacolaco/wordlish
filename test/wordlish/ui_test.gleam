import gleam/dict
import gleam/string
import gleam_community/ansi
import gleeunit/should
import wordlish/judge.{Absent, Correct, Present}
import wordlish/ui

pub fn format_letter_correct_test() {
  ui.format_letter("A", Correct)
  |> ansi.strip
  |> should.equal(" A ")
}

pub fn format_letter_present_test() {
  ui.format_letter("B", Present)
  |> ansi.strip
  |> should.equal(" B ")
}

pub fn format_letter_absent_test() {
  ui.format_letter("C", Absent)
  |> ansi.strip
  |> should.equal(" C ")
}

pub fn format_guess_result_test() {
  let result = [
    #("C", Correct),
    #("R", Correct),
    #("A", Correct),
    #("N", Absent),
    #("E", Correct),
  ]
  ui.format_guess_result(result)
  |> ansi.strip
  |> string.contains(" C ")
  |> should.be_true
}

pub fn format_guess_result_contains_all_letters_test() {
  let result = [
    #("H", Correct),
    #("E", Present),
    #("L", Absent),
    #("L", Absent),
    #("O", Correct),
  ]
  let formatted = ui.format_guess_result(result) |> ansi.strip
  formatted |> string.contains("H") |> should.be_true
  formatted |> string.contains("E") |> should.be_true
  formatted |> string.contains("L") |> should.be_true
  formatted |> string.contains("O") |> should.be_true
}

// --- keyboard state display tests ---

pub fn format_keyboard_state_contains_all_letters_test() {
  let keyboard = dict.new()
  let formatted = ui.format_keyboard_state(keyboard) |> ansi.strip
  // Should contain all 26 letters A-Z
  formatted |> string.contains("A") |> should.be_true
  formatted |> string.contains("Z") |> should.be_true
}

pub fn format_keyboard_state_shows_correct_test() {
  let keyboard =
    dict.new()
    |> dict.insert("A", Correct)
    |> dict.insert("B", Present)
    |> dict.insert("C", Absent)
  let formatted = ui.format_keyboard_state(keyboard) |> ansi.strip
  formatted |> string.contains("A") |> should.be_true
  formatted |> string.contains("B") |> should.be_true
  // Absent letters are displayed as lowercase
  formatted |> string.contains("c") |> should.be_true
}
