import garanti
import garanti_javascript/internal/executor
import gleam/list

/// Executes all tests in the given suite and returns the result.
pub fn run(suite: garanti.Suite) -> garanti.SuiteResult {
  let results =
    list.map(suite.tests, fn(t) {
      executor.run(t.run)
      |> execution_result_to_test_result(t)
    })

  garanti.SuiteComplete(suite.name, results)
}

fn execution_result_to_test_result(
  er: executor.ExecutionResult,
  t: garanti.Test,
) -> garanti.TestResult {
  let result = case er {
    executor.Executed(garanti.Pass) -> garanti.Pass
    executor.Executed(garanti.Fail(reason)) -> garanti.Fail(reason)
    executor.Executed(garanti.Timeout) -> garanti.Timeout
    // Unreachable in practice.
    executor.ExecutionFailure(msg) -> garanti.Fail(msg)
  }

  garanti.TestResult(t.name, result)
}
