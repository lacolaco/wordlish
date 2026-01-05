import gleam/list
import gleam/result
import wordlish/judge.{type LetterResult}

pub type GameState {
  GameState(answer: String, guesses: List(String))
}

pub type GameOutcome {
  Won(attempts: Int)
  Lost(answer: String)
  InProgress
}

pub fn new_game(answer: String) -> GameState {
  GameState(answer: answer, guesses: [])
}

pub fn get_answer(state: GameState) -> String {
  state.answer
}

pub fn get_attempts(state: GameState) -> Int {
  list.length(state.guesses)
}

const max_attempts = 6

pub fn get_outcome(state: GameState) -> GameOutcome {
  let attempts = list.length(state.guesses)
  let last_guess_correct =
    list.last(state.guesses)
    |> result.map(fn(g) { g == state.answer })
    |> result.unwrap(False)

  case last_guess_correct, attempts >= max_attempts {
    True, _ -> Won(attempts)
    _, True -> Lost(state.answer)
    _, _ -> InProgress
  }
}

pub fn get_last_result(
  state: GameState,
) -> Result(List(#(String, LetterResult)), Nil) {
  case list.last(state.guesses) {
    Ok(last_guess) -> Ok(judge.judge(last_guess, state.answer))
    Error(_) -> Error(Nil)
  }
}

pub fn make_guess(state: GameState, guess: String) -> #(GameState, GameOutcome) {
  let new_guesses = list.append(state.guesses, [guess])
  let new_state = GameState(..state, guesses: new_guesses)
  let attempts = list.length(new_guesses)
  case guess == state.answer, attempts >= max_attempts {
    True, _ -> #(new_state, Won(attempts))
    _, True -> #(new_state, Lost(state.answer))
    _, _ -> #(new_state, InProgress)
  }
}
