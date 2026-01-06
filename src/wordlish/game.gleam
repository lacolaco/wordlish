import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import wordlish/judge.{type LetterResult}
import wordlish/words_data

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

/// Get suggested words based on current game state
pub fn get_suggestions(state: GameState, max: Int) -> List(String) {
  let constraints = build_constraints(state)

  list.append(words_data.answers, words_data.guesses)
  |> list.map(string.uppercase)
  |> list.filter(fn(word) { matches_constraints(word, constraints) })
  |> list.shuffle
  |> list.take(max)
}

type Constraints {
  Constraints(
    correct: List(#(Int, String)),
    present: List(#(Int, String)),
    absent: Set(String),
  )
}

fn build_constraints(state: GameState) -> Constraints {
  let all_results =
    state.guesses
    |> list.map(fn(guess) { judge.judge(guess, state.answer) })

  let correct =
    all_results
    |> list.flat_map(fn(result) {
      result
      |> list.index_map(fn(pair, idx) { #(idx, pair) })
      |> list.filter_map(fn(item) {
        let #(idx, #(letter, status)) = item
        case status {
          judge.Correct -> Ok(#(idx, letter))
          _ -> Error(Nil)
        }
      })
    })

  let present =
    all_results
    |> list.flat_map(fn(result) {
      result
      |> list.index_map(fn(pair, idx) { #(idx, pair) })
      |> list.filter_map(fn(item) {
        let #(idx, #(letter, status)) = item
        case status {
          judge.Present -> Ok(#(idx, letter))
          _ -> Error(Nil)
        }
      })
    })

  // Absent letters that are never Correct or Present
  let known_letters =
    list.append(
      list.map(correct, fn(p) { p.1 }),
      list.map(present, fn(p) { p.1 }),
    )
    |> set.from_list

  let absent =
    all_results
    |> list.flat_map(fn(result) {
      result
      |> list.filter_map(fn(pair) {
        let #(letter, status) = pair
        case status {
          judge.Absent -> Ok(letter)
          _ -> Error(Nil)
        }
      })
    })
    |> list.filter(fn(letter) { !set.contains(known_letters, letter) })
    |> set.from_list

  Constraints(correct: correct, present: present, absent: absent)
}

fn matches_constraints(word: String, constraints: Constraints) -> Bool {
  let chars = string.to_graphemes(word)

  // Check Correct: letter at position must match
  let correct_ok =
    list.all(constraints.correct, fn(constraint) {
      let #(pos, letter) = constraint
      case list_at(chars, pos) {
        Ok(c) -> c == letter
        Error(_) -> False
      }
    })

  // Check Present: letter must exist AND not at that position
  let present_ok =
    list.all(constraints.present, fn(constraint) {
      let #(pos, letter) = constraint
      let in_word = list.contains(chars, letter)
      let not_at_pos = case list_at(chars, pos) {
        Ok(c) -> c != letter
        Error(_) -> True
      }
      in_word && not_at_pos
    })

  // Check Absent: letter must not be in word
  let absent_ok =
    set.to_list(constraints.absent)
    |> list.all(fn(letter) { !list.contains(chars, letter) })

  correct_ok && present_ok && absent_ok
}

fn list_at(lst: List(a), index: Int) -> Result(a, Nil) {
  lst
  |> list.drop(index)
  |> list.first
}
