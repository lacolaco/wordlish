import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

pub type LetterResult {
  Correct
  Present
  Absent
}

pub fn judge(guess: String, answer: String) -> List(#(String, LetterResult)) {
  let guess_chars = string.to_graphemes(guess)
  let answer_chars = string.to_graphemes(answer)

  // Pass 1: Mark exact matches (Correct), consume from answer
  let #(pass1_results, remaining) = pass1(guess_chars, answer_chars)

  // Pass 2: Mark Present/Absent for remaining
  let final_results = pass2(guess_chars, pass1_results, remaining)

  list.zip(guess_chars, final_results)
}

fn count_letters(chars: List(String)) -> Dict(String, Int) {
  list.fold(chars, dict.new(), fn(acc, c) {
    let count = dict.get(acc, c) |> result.unwrap(0)
    dict.insert(acc, c, count + 1)
  })
}

fn pass1(
  guess_chars: List(String),
  answer_chars: List(String),
) -> #(List(Option(LetterResult)), Dict(String, Int)) {
  let initial_counts = count_letters(answer_chars)

  let #(results_rev, remaining) =
    list.zip(guess_chars, answer_chars)
    |> list.fold(#([], initial_counts), fn(acc, pair) {
      let #(results, remaining) = acc
      let #(g, a) = pair
      case g == a {
        True -> {
          let new_remaining = consume_letter(remaining, g)
          #([Some(Correct), ..results], new_remaining)
        }
        False -> #([None, ..results], remaining)
      }
    })

  #(list.reverse(results_rev), remaining)
}

fn pass2(
  guess_chars: List(String),
  pass1_results: List(Option(LetterResult)),
  remaining: Dict(String, Int),
) -> List(LetterResult) {
  let #(results_rev, _) =
    list.zip(guess_chars, pass1_results)
    |> list.fold(#([], remaining), fn(acc, pair) {
      let #(results, remaining) = acc
      let #(g, maybe_result) = pair
      case maybe_result {
        Some(result) -> #([result, ..results], remaining)
        None -> {
          case dict.has_key(remaining, g) {
            True -> {
              let new_remaining = consume_letter(remaining, g)
              #([Present, ..results], new_remaining)
            }
            False -> #([Absent, ..results], remaining)
          }
        }
      }
    })

  list.reverse(results_rev)
}

fn consume_letter(
  remaining: Dict(String, Int),
  letter: String,
) -> Dict(String, Int) {
  case dict.get(remaining, letter) {
    Ok(count) if count > 1 -> dict.insert(remaining, letter, count - 1)
    Ok(_) -> dict.delete(remaining, letter)
    Error(_) -> remaining
  }
}
