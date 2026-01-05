import gleam/result
import gleam/string
import gleam/yielder
import stdin.{read_lines}
import wordlish/game.{type GameState, InProgress, Lost, Won}
import wordlish/ui
import wordlish/words

pub fn main() -> Nil {
  // Initialize game with random answer
  let answer = words.get_random_answer()
  let state = game.new_game(answer)

  // Show welcome message
  ui.print_welcome()

  // Start game loop
  game_loop(state)
}

fn game_loop(state: GameState) -> Nil {
  let attempt = game.get_attempts(state) + 1
  ui.print_prompt(attempt)

  // Read user input
  case read_line() {
    Ok(input) -> {
      let guess = words.normalize(input)
      case words.is_valid_guess(guess) {
        True -> {
          // Make guess and get result
          let #(new_state, outcome) = game.make_guess(state, guess)

          // Show result (assert: guaranteed to exist after make_guess)
          let assert Ok(result) = game.get_last_result(new_state)
          ui.print_guess_result(result)

          // Show keyboard state
          let keyboard = game.get_keyboard_state(new_state)
          ui.print_keyboard_state(keyboard)

          // Check outcome
          case outcome {
            Won(attempts) -> ui.print_win(attempts)
            Lost(answer) -> ui.print_lose(answer)
            InProgress -> game_loop(new_state)
          }
        }
        False -> {
          ui.print_invalid_guess()
          game_loop(state)
        }
      }
    }
    Error(_) -> {
      // EOF or error - exit gracefully
      Nil
    }
  }
}

fn read_line() -> Result(String, Nil) {
  read_lines()
  |> yielder.first
  |> result.map(string.trim)
}
