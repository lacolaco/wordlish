import gleeunit/should
import wordlish/game.{InProgress, Lost, Won}

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
