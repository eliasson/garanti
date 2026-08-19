//// Table-driven tests, where you specify a sequence of test data inputs and generate
//// one tests for each of the input. Each test is reported as any other test.

import garanti
import gleam/list

/// Create a sequence of tests based on the given sequence of inputs.
///
/// Each input will construct a `Test` that is named by calling the `name` function
/// and the test body will be the `run` function.
pub fn table(
  inputs: List(a),
  name: fn(a) -> String,
  run: fn(a) -> garanti.AssertionResult,
) -> List(garanti.Test) {
  inputs
  |> list.map(fn(td) { garanti.Test(name(td), fn() { run(td) }) })
}
