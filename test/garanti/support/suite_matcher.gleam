import garanti
import gleam/list
import gleam/string

pub fn have_suite_name(
  result: garanti.SuiteResult,
  expected: String,
) -> garanti.SuiteResult {
  let actual = case result {
    garanti.SuiteComplete(name, ..) -> name
  }

  case actual == expected {
    True -> result
    _ ->
      panic as string.concat([
          "Expected suite to have name ",
          string.inspect(expected),
          " (was: ",
          string.inspect(actual),
          ").",
        ])
  }
}

pub fn have_completed_tests(
  result: garanti.SuiteResult,
  expected: Int,
) -> garanti.SuiteResult {
  let actual = case result {
    garanti.SuiteComplete(results:, ..) -> list.length(results)
  }

  case actual == expected {
    True -> result
    _ ->
      panic as string.concat([
          "Expected suite to have ",
          string.inspect(expected),
          " completed tests (was: ",
          string.inspect(actual),
          ").",
        ])
  }
}
