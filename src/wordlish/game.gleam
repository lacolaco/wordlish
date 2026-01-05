import gleam/dict.{type Dict}
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

pub fn get_keyboard_state(state: GameState) -> Dict(String, LetterResult) {
  state.guesses
  |> list.flat_map(fn(guess) { judge.judge(guess, state.answer) })
  |> list.fold(dict.new(), fn(acc, pair) {
    let #(letter, new_result) = pair
    case dict.get(acc, letter) {
      Error(Nil) -> dict.insert(acc, letter, new_result)
      Ok(existing) -> {
        let best = better_result(existing, new_result)
        dict.insert(acc, letter, best)
      }
    }
  })
}

fn better_result(a: LetterResult, b: LetterResult) -> LetterResult {
  // Correct > Present > Absent
  case a, b {
    judge.Correct, _ -> judge.Correct
    _, judge.Correct -> judge.Correct
    judge.Present, _ -> judge.Present
    _, judge.Present -> judge.Present
    _, _ -> judge.Absent
  }
}
