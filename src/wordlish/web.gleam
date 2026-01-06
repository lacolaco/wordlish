import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string
import lustre
import lustre/attribute.{class}
import lustre/element.{type Element, text}
import lustre/element/html
import lustre/event
import wordlish/game.{type GameOutcome, type GameState, InProgress, Lost, Won}
import wordlish/judge.{type LetterResult, Absent, Correct, Present}
import wordlish/words

// MAIN

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

// MODEL

type Model {
  Model(
    game: GameState,
    input: String,
    results: List(List(#(String, LetterResult))),
    outcome: GameOutcome,
    keyboard: Dict(String, LetterResult),
    suggestions: List(String),
  )
}

fn init(_) -> Model {
  let answer = words.get_random_answer()
  Model(
    game: game.new_game(answer),
    input: "",
    results: [],
    outcome: InProgress,
    keyboard: dict.new(),
    suggestions: [],
  )
}

// UPDATE

type Msg {
  UserUpdatedInput(String)
  UserSubmittedGuess
  UserClickedNewGame
  UserClickedSuggestion(String)
  UserClickedRandom
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserUpdatedInput(value) -> {
      let normalized = string.uppercase(value)
      let limited = string.slice(normalized, 0, 5)
      Model(..model, input: limited)
    }

    UserSubmittedGuess -> {
      case model.outcome {
        InProgress -> try_guess(model)
        _ -> model
      }
    }

    UserClickedNewGame -> init(Nil)

    UserClickedSuggestion(word) -> {
      Model(..model, input: word)
    }

    UserClickedRandom -> {
      case game.get_suggestions(model.game, 1) {
        [word] -> Model(..model, input: word)
        _ -> model
      }
    }
  }
}

fn try_guess(model: Model) -> Model {
  let guess = model.input
  case words.is_valid_guess(guess) {
    False -> model
    True -> {
      let #(new_game, outcome) = game.make_guess(model.game, guess)
      let assert Ok(result) = game.get_last_result(new_game)
      let new_keyboard = game.get_keyboard_state(new_game)
      let new_suggestions = game.get_suggestions(new_game, 5)
      Model(
        game: new_game,
        input: "",
        results: list.append(model.results, [result]),
        outcome: outcome,
        keyboard: new_keyboard,
        suggestions: new_suggestions,
      )
    }
  }
}

// VIEW

fn view(model: Model) -> Element(Msg) {
  html.div([class("container")], [
    view_header(),
    view_board(model.results),
    view_input(model),
    view_hints(model),
    view_keyboard(model.keyboard),
    view_outcome(model.outcome),
  ])
}

fn view_header() -> Element(Msg) {
  html.header([class("header")], [
    html.h1([], [text("Wordlish")]),
    html.p([], [text("5文字の単語を当てよ（6回まで）")]),
  ])
}

fn view_board(results: List(List(#(String, LetterResult)))) -> Element(Msg) {
  let rows = list.map(results, view_row)
  let empty_rows = list.repeat(view_empty_row(), 6 - list.length(results))
  html.div([class("board")], list.append(rows, empty_rows))
}

fn view_row(result: List(#(String, LetterResult))) -> Element(Msg) {
  html.div(
    [class("row")],
    list.map(result, fn(pair) {
      let #(letter, status) = pair
      view_tile(letter, status)
    }),
  )
}

fn view_tile(letter: String, status: LetterResult) -> Element(Msg) {
  let status_class = case status {
    Correct -> "correct"
    Present -> "present"
    Absent -> "absent"
  }
  html.div([class("tile " <> status_class)], [text(letter)])
}

fn view_empty_row() -> Element(Msg) {
  html.div([class("row")], list.repeat(html.div([class("tile empty")], []), 5))
}

fn view_input(model: Model) -> Element(Msg) {
  case model.outcome {
    InProgress ->
      html.div([class("input-area")], [
        html.input([
          attribute.type_("text"),
          attribute.value(model.input),
          attribute.placeholder("5文字を入力"),
          attribute.autofocus(True),
          event.on_input(UserUpdatedInput),
          event.on_keydown(fn(key) {
            case key {
              "Enter" -> UserSubmittedGuess
              _ -> UserUpdatedInput(model.input)
            }
          }),
        ]),
        html.button([event.on_click(UserSubmittedGuess)], [text("推測")]),
        html.button(
          [class("random-button"), event.on_click(UserClickedRandom)],
          [text("🎲")],
        ),
      ])
    _ ->
      html.div([class("input-area")], [
        html.button([event.on_click(UserClickedNewGame)], [text("新しいゲーム")]),
      ])
  }
}

fn view_hints(model: Model) -> Element(Msg) {
  case model.outcome, model.results != [] {
    InProgress, True ->
      html.div([class("hints-area")], [
        html.div([class("hints-label")], [text("候補:")]),
        html.div([class("suggestions")], [
          case model.suggestions {
            [] -> text("なし")
            _ ->
              html.ul(
                [],
                list.map(model.suggestions, fn(word) {
                  html.li(
                    [
                      class("clickable"),
                      event.on_click(UserClickedSuggestion(word)),
                    ],
                    [text(word)],
                  )
                }),
              )
          },
        ]),
      ])
    _, _ -> html.div([], [])
  }
}

fn view_keyboard(keyboard: Dict(String, LetterResult)) -> Element(Msg) {
  let rows = [
    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
    ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
    ["Z", "X", "C", "V", "B", "N", "M"],
  ]
  html.div(
    [class("keyboard")],
    list.map(rows, fn(row) {
      html.div(
        [class("keyboard-row")],
        list.map(row, fn(letter) { view_key(letter, keyboard) }),
      )
    }),
  )
}

fn view_key(
  letter: String,
  keyboard: Dict(String, LetterResult),
) -> Element(Msg) {
  let status_class = case dict.get(keyboard, letter) {
    Ok(Correct) -> "correct"
    Ok(Present) -> "present"
    Ok(Absent) -> "absent"
    Error(Nil) -> "unused"
  }
  html.div([class("key " <> status_class)], [text(letter)])
}

fn view_outcome(outcome: GameOutcome) -> Element(Msg) {
  case outcome {
    Won(attempts) ->
      html.div([class("outcome win")], [
        text("正解！ " <> int.to_string(attempts) <> "回で当てた"),
      ])
    Lost(answer) ->
      html.div([class("outcome lose")], [
        text("残念！正解は " <> answer <> " でした"),
      ])
    InProgress -> html.div([], [])
  }
}
