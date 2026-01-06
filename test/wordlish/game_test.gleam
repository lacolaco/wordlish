import gleam/dict
import gleeunit/should
import wordlish/game.{InProgress, Lost, Won}
import wordlish/judge.{Absent, Correct}

pub fn new_game_initial_state_test() {
  let state = game.new_game("CRANE")
  game.get_answer(state) |> should.equal("CRANE")
}

pub fn new_game_zero_attempts_test() {
  let state = game.new_game("CRANE")
  game.get_attempts(state) |> should.equal(0)
}

pub fn new_game_in_progress_test() {
  let state = game.new_game("CRANE")
  game.get_outcome(state) |> should.equal(InProgress)
}

pub fn make_guess_correct_test() {
  let state = game.new_game("CRANE")
  let #(new_state, outcome) = game.make_guess(state, "CRANE")
  outcome |> should.equal(Won(1))
  game.get_attempts(new_state) |> should.equal(1)
}

pub fn make_guess_wrong_test() {
  let state = game.new_game("CRANE")
  let #(new_state, outcome) = game.make_guess(state, "SLATE")
  outcome |> should.equal(InProgress)
  game.get_attempts(new_state) |> should.equal(1)
}

pub fn make_guess_lose_after_six_test() {
  let state = game.new_game("CRANE")
  let #(state, _) = game.make_guess(state, "SLATE")
  let #(state, _) = game.make_guess(state, "TRACE")
  let #(state, _) = game.make_guess(state, "BRAIN")
  let #(state, _) = game.make_guess(state, "PLANT")
  let #(state, _) = game.make_guess(state, "STEAM")
  let #(state, outcome) = game.make_guess(state, "STORM")
  outcome |> should.equal(Lost("CRANE"))
  game.get_attempts(state) |> should.equal(6)
}

pub fn get_last_result_test() {
  let state = game.new_game("CRANE")
  let #(state, _) = game.make_guess(state, "CRANE")
  let result = game.get_last_result(state)
  result |> should.be_ok
}

// --- keyboard state tests ---

pub fn keyboard_state_initial_empty_test() {
  let state = game.new_game("CRANE")
  game.get_keyboard_state(state)
  |> dict.size
  |> should.equal(0)
}

pub fn keyboard_state_after_correct_guess_test() {
  let state = game.new_game("CRANE")
  let #(state, _) = game.make_guess(state, "CRANE")
  let keyboard = game.get_keyboard_state(state)
  // C, R, A, N, E should all be Correct
  dict.get(keyboard, "C") |> should.equal(Ok(Correct))
  dict.get(keyboard, "R") |> should.equal(Ok(Correct))
  dict.get(keyboard, "A") |> should.equal(Ok(Correct))
  dict.get(keyboard, "N") |> should.equal(Ok(Correct))
  dict.get(keyboard, "E") |> should.equal(Ok(Correct))
}

pub fn keyboard_state_upgrade_absent_to_correct_test() {
  // Answer: CRANE
  // Guess 1: SIGHT -> all Absent (including no overlap)
  // Guess 2: CRANE -> C,R,A,N,E become Correct
  // S,I,G,H,T should remain Absent
  let state = game.new_game("CRANE")
  let #(state, _) = game.make_guess(state, "SIGHT")
  let #(state, _) = game.make_guess(state, "CRANE")
  let keyboard = game.get_keyboard_state(state)
  // Letters from CRANE should be Correct
  dict.get(keyboard, "C") |> should.equal(Ok(Correct))
  // Letters from SIGHT should be Absent
  dict.get(keyboard, "S") |> should.equal(Ok(Absent))
  dict.get(keyboard, "I") |> should.equal(Ok(Absent))
  dict.get(keyboard, "G") |> should.equal(Ok(Absent))
  dict.get(keyboard, "H") |> should.equal(Ok(Absent))
  dict.get(keyboard, "T") |> should.equal(Ok(Absent))
}

pub fn keyboard_state_keeps_best_result_test() {
  // Answer: CRANE
  // Guess 1: TRACE -> T=Absent, R=Present, A=Correct, C=Present, E=Correct
  // Guess 2: CLEAR -> C=Correct, L=Absent, E=Present, A=Present, R=Present
  // Best for each: C=Correct (upgraded), E=Correct (not downgraded), A=Correct (not downgraded)
  let state = game.new_game("CRANE")
  let #(state, _) = game.make_guess(state, "TRACE")
  let #(state, _) = game.make_guess(state, "CLEAR")
  let keyboard = game.get_keyboard_state(state)
  // A was Correct in TRACE, should stay Correct (not downgrade to Present from CLEAR)
  dict.get(keyboard, "A") |> should.equal(Ok(Correct))
  // E was Correct in TRACE, should stay Correct (not downgrade to Present from CLEAR)
  dict.get(keyboard, "E") |> should.equal(Ok(Correct))
  // C was Present in TRACE, upgraded to Correct in CLEAR
  dict.get(keyboard, "C") |> should.equal(Ok(Correct))
}

// --- suggestions tests ---

import gleam/list

pub fn suggestions_basic_test() {
  // Answer: NASTY, Guess: TASTY
  // T@0=Present, A@1=Correct, S@2=Correct, T@3=Correct, Y@4=Correct
  // Should suggest words matching ?ASTY where position 0 is not T
  // Valid: HASTY, NASTY (but NASTY is answer so excluded), PASTY
  let state = game.new_game("NASTY")
  let #(state, _) = game.make_guess(state, "TASTY")
  let suggestions = game.get_suggestions(state, 10)
  // Should have at least HASTY and PASTY
  list.length(suggestions) |> should.not_equal(0)
}

pub fn suggestions_includes_answer_test() {
  let state = game.new_game("NASTY")
  let #(state, _) = game.make_guess(state, "TASTY")
  let suggestions = game.get_suggestions(state, 100)
  // Answer should be included in suggestions
  list.contains(suggestions, "NASTY") |> should.equal(True)
}

pub fn suggestions_excludes_absent_letters_test() {
  // Answer: NASTY, Guess: PLATE then TASTY
  // P, L, E are absent. Should not suggest PASTY (has P)
  let state = game.new_game("NASTY")
  let #(state, _) = game.make_guess(state, "PLATE")
  let #(state, _) = game.make_guess(state, "TASTY")
  let suggestions = game.get_suggestions(state, 100)
  list.contains(suggestions, "PASTY") |> should.equal(False)
}

pub fn suggestions_screenshot_scenario_test() {
  // Exact scenario from user's screenshot
  // Answer appears to be something like CATTY or NATTY (pattern _ATTY)
  // Wait, looking at screenshot: TASTY has S green at position 2
  // So pattern is _ASTY
  // Let's assume answer is NASTY
  let state = game.new_game("NASTY")
  let #(state, _) = game.make_guess(state, "PLATE")
  let #(state, _) = game.make_guess(state, "TASTY")
  let #(state, _) = game.make_guess(state, "FATTY")
  let #(state, _) = game.make_guess(state, "BATTY")
  let #(state, _) = game.make_guess(state, "RATTY")
  let suggestions = game.get_suggestions(state, 10)
  // Should suggest HASTY (the only remaining valid candidate)
  // NASTY is answer (excluded), PASTY has P (absent), TASTY has T at position 0 (invalid)
  list.contains(suggestions, "HASTY") |> should.equal(True)
}
