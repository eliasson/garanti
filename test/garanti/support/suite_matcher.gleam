import garanti
import gleam/int
import gleam/list
import gleam/string

pub fn have_suite_name(
  result: garanti.SuiteResult,
  expected: String,
) -> garanti.SuiteResult {
  let actual = case result {
    garanti.SuiteComplete(name, ..) -> name
    garanti.SuiteCancelled(name) -> name
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
    _ -> 0
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

pub fn have_been_cancelled(result: garanti.SuiteResult) -> garanti.SuiteResult {
  case result {
    garanti.SuiteComplete(name, ..) ->
      panic as string.concat(["Test suite ", name, " was not cancelled"])
    garanti.SuiteCancelled(..) -> result
  }
}

pub fn have_passing_tests(
  result: garanti.SuiteResult,
  expected: Int,
) -> garanti.SuiteResult {
  let actual = case result {
    garanti.SuiteComplete(results:, ..) -> {
      results
      |> list.count(fn(r) {
        case r.result {
          garanti.Pass -> True
          garanti.Fail(_) -> False
        }
      })
    }
    _ -> panic as string.concat(["Suite did not complete"])
  }

  case actual == expected {
    True -> result
    _ ->
      panic as string.concat([
          "Expected suite to have ",
          string.inspect(expected),
          " passing tests (was: ",
          string.inspect(actual),
          ").",
        ])
  }

  result
}

pub fn have_failing_tests(
  result: garanti.SuiteResult,
  expected: Int,
) -> garanti.SuiteResult {
  let actual = case result {
    garanti.SuiteComplete(results:, ..) -> {
      results
      |> list.count(fn(r) {
        case r.result {
          garanti.Pass -> False
          garanti.Fail(_) -> True
        }
      })
    }
    _ -> panic as string.concat(["Suite did not complete"])
  }

  case actual == expected {
    True -> result
    _ ->
      panic as string.concat([
          "Expected suite to have ",
          string.inspect(expected),
          " failing tests (was: ",
          string.inspect(actual),
          ").",
        ])
  }

  result
}
