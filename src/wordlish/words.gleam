import gleam/list
import gleam/string

/// Common 5-letter words for answers (subset for MVP)
const answer_words = [
  "CRANE", "SLATE", "TRACE", "CRATE", "STARE", "STEAM", "TRAIN", "PLANT",
  "STORM", "STONE", "STORE", "STORY", "STICK", "STOCK", "STOKE", "STYLE",
  "SUGAR", "SUPER", "SWEAR", "SWEET", "SWIFT", "TABLE", "TASTE", "TEACH",
  "TEARS", "TERMS", "THANK", "THEIR", "THEME", "THERE", "THESE", "THICK",
  "THINK", "THIRD", "THOSE", "THREE", "THROW", "TIGHT", "TIRED", "TITLE",
  "TODAY", "TOKEN", "TOTAL", "TOUCH", "TOUGH", "TOWER", "TRACK", "TRADE",
  "TRAIL", "TRASH", "TREAT", "TREND", "TRIAL", "TRIBE", "TRICK", "TRIED",
  "TRUCK", "TRULY", "TRUST", "TRUTH", "TWICE", "UNCLE", "UNDER", "UNION",
  "UNITE", "UNTIL", "UPPER", "UPSET", "URBAN", "USUAL", "VALID", "VALUE",
  "VIDEO", "VIRUS", "VISIT", "VITAL", "VOICE", "WASTE", "WATCH", "WATER",
  "WEIGH", "WEIRD", "WHALE", "WHEAT", "WHEEL", "WHERE", "WHICH", "WHILE",
  "WHITE", "WHOLE", "WHOSE", "WOMAN", "WORLD", "WORRY", "WORSE", "WORST",
  "WORTH", "WOULD", "WOUND", "WRITE", "WRONG", "WROTE", "YIELD", "YOUNG",
  "YOUTH", "ZEBRA", "APPLE", "BRAIN", "BREAD", "BREAK", "BRING", "BRUSH",
]

/// Valid guesses include answer words plus more common words
const valid_words = [
  "CRANE", "SLATE", "TRACE", "CRATE", "STARE", "STEAM", "TRAIN", "PLANT",
  "STORM", "STONE", "STORE", "STORY", "STICK", "STOCK", "STOKE", "STYLE",
  "SUGAR", "SUPER", "SWEAR", "SWEET", "SWIFT", "TABLE", "TASTE", "TEACH",
  "TEARS", "TERMS", "THANK", "THEIR", "THEME", "THERE", "THESE", "THICK",
  "THINK", "THIRD", "THOSE", "THREE", "THROW", "TIGHT", "TIRED", "TITLE",
  "TODAY", "TOKEN", "TOTAL", "TOUCH", "TOUGH", "TOWER", "TRACK", "TRADE",
  "TRAIL", "TRASH", "TREAT", "TREND", "TRIAL", "TRIBE", "TRICK", "TRIED",
  "TRUCK", "TRULY", "TRUST", "TRUTH", "TWICE", "UNCLE", "UNDER", "UNION",
  "UNITE", "UNTIL", "UPPER", "UPSET", "URBAN", "USUAL", "VALID", "VALUE",
  "VIDEO", "VIRUS", "VISIT", "VITAL", "VOICE", "WASTE", "WATCH", "WATER",
  "WEIGH", "WEIRD", "WHALE", "WHEAT", "WHEEL", "WHERE", "WHICH", "WHILE",
  "WHITE", "WHOLE", "WHOSE", "WOMAN", "WORLD", "WORRY", "WORSE", "WORST",
  "WORTH", "WOULD", "WOUND", "WRITE", "WRONG", "WROTE", "YIELD", "YOUNG",
  "YOUTH", "ZEBRA", "APPLE", "BRAIN", "BREAD", "BREAK", "BRING", "BRUSH",
  "ABORT", "ABOUT", "ABOVE", "ABUSE", "ACTOR", "ACUTE", "ADMIT", "ADOPT",
  "ADULT", "AFTER", "AGAIN", "AGENT", "AGREE", "AHEAD", "ALARM", "ALBUM",
  "ALERT", "ALIEN", "ALIGN", "ALIKE", "ALIVE", "ALLOW", "ALONE", "ALONG",
  "ALTER", "AMONG", "ANGEL", "ANGER", "ANGLE", "ANGRY", "APART", "ARENA",
  "ARGUE", "ARISE", "ARMOR", "ARRAY", "ASIDE", "ASSET", "AUDIO", "AUDIT",
  "AVOID", "AWARD", "AWARE", "BADLY", "BASIC", "BASIN", "BASIS", "BEACH",
  "BEGAN", "BEGIN", "BEGUN", "BEING", "BELLY", "BELOW", "BENCH", "BILLY",
  "BIRTH", "BLACK", "BLADE", "BLAME", "BLANK", "BLAST", "BLAZE", "BLEED",
  "BLEND", "BLESS", "BLIND", "BLOCK", "BLOOD", "BLOWN", "BOARD", "BOOST",
]

/// Normalize word to uppercase
pub fn normalize(word: String) -> String {
  string.uppercase(word)
}

/// Check if a word is a valid guess (5 letters and in dictionary)
pub fn is_valid_guess(word: String) -> Bool {
  let normalized = normalize(word)
  string.length(normalized) == 5 && is_in_dictionary(normalized)
}

/// Get a random answer word
pub fn get_random_answer() -> String {
  answer_words
  |> list.shuffle
  |> list.first
  |> fn(result) {
    case result {
      Ok(word) -> word
      Error(_) -> "CRANE"
    }
  }
}

fn is_in_dictionary(word: String) -> Bool {
  valid_words
  |> list.contains(word)
}
