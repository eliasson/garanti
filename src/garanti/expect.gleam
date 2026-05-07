import garanti
import gleam/string

/// Match two values of the same type to be equal.
pub fn to_be_equal(actual: a, expected: a) -> garanti.AssertionResult {
  case actual == expected {
    True -> garanti.Pass
    False ->
      garanti.Fail(
        string.concat([
          "Expected ",
          string.inspect(actual),
          " to equal ",
          string.inspect(expected),
          ".",
        ]),
      )
  }
}

/// Match two values of the same type to NOT be equal.
pub fn to_not_be_equal(actual: a, expected: a) -> garanti.AssertionResult {
  case actual == expected {
    False -> garanti.Pass
    True ->
      garanti.Fail(
        string.concat([
          "Expected ",
          string.inspect(actual),
          " to NOT equal ",
          string.inspect(expected),
          ".",
        ]),
      )
  }
}
