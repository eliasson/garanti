import garanti
import garanti/expect
import gleam/list
import gleam/string

pub fn have_completed_tests(
  result: garanti.SuiteResult,
  expected: Int,
) -> garanti.AssertionResult {
  let actual = case result {
    garanti.SuiteComplete(results:, ..) -> list.length(results)
    _ -> 0
  }

  expect.to_be_equal(actual, expected)
}

pub fn have_been_cancelled(
  result: garanti.SuiteResult,
) -> garanti.AssertionResult {
  case result {
    garanti.SuiteComplete(name, ..) ->
      garanti.Fail(
        string.concat(["Test suite ", name, " was not cancelled"]),
        [],
      )
    garanti.SuiteCancelled(..) -> garanti.Pass
  }
}

pub fn have_passing_tests(
  result: garanti.SuiteResult,
  expected: Int,
) -> garanti.AssertionResult {
  let actual = case result {
    garanti.SuiteComplete(results:, ..) -> {
      results
      |> list.count(fn(r) {
        case r.result {
          garanti.Pass -> True
          garanti.Fail(_, _) -> False
          garanti.Timeout -> False
        }
      })
    }
    _ -> panic as string.concat(["Suite did not complete"])
  }

  expect.to_be_equal(actual, expected)
}

pub fn have_failing_tests(
  result: garanti.SuiteResult,
  expected: Int,
) -> garanti.AssertionResult {
  let actual = case result {
    garanti.SuiteComplete(results:, ..) -> {
      results
      |> list.count(fn(r) {
        case r.result {
          garanti.Pass -> False
          garanti.Fail(_, _) -> True
          garanti.Timeout -> True
        }
      })
    }
    _ -> panic as string.concat(["Suite did not complete"])
  }

  expect.to_be_equal(actual, expected)
}
