/// The level of importance for the overall message (much like log level).
pub type Level {
  Success
  Error
  Warning
  Info
  Debug
}

/// The effect of a token used for semantic highligting.
pub type Effect {
  ///Positive outcomes of tests, etc.
  Positive
  /// Negative outcomes, such as test failures.
  Negative
  /// Imporant parts of a message, such as test or suite name.
  Important
  /// Adds additional emphasis to a piece of text
  Bold
}

/// The different types of tokens that can be used to construct a message.
pub type Token {
  /// Plain text string.
  Plain(text: String)
  /// A string with optional effects. Not all effects can be combined (such as combining colors).
  Enriched(text: String, effects: List(Effect))
}

/// A message that is part of a test report.
pub type Message {
  Message(level: Level, tokens: List(Token))
}
