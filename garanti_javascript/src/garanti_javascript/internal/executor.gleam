import garanti

/// The result of a single test execution.
/// This is a subset of the Erlang runner ExecutionResult. There is no timeout as the JavaScript runner is
/// synchrounous and cannot preempt a running test.
pub type ExecutionResult {
  /// The test was successfully executed (the test may have passer or failed, but the execution was OK).
  Executed(garanti.AssertionResult)
  /// The test could not successfully be executed.
  ExecutionFailure(String)
}

// Declared here rather than a separate ffi module since it is only used below.
// Maps to executor_ffi.mjs which wraps the call in an JavaScript try/catch.
@external(javascript, "./executor_ffi.mjs", "run_catching")
fn run_catching(
  f: fn() -> garanti.AssertionResult,
) -> Result(garanti.AssertionResult, Nil)

/// Execute the given test in isolation and return the result.
pub fn run(test_fn: fn() -> garanti.AssertionResult) -> ExecutionResult {
  case run_catching(test_fn) {
    Ok(r) -> Executed(r)
    Error(Nil) -> ExecutionFailure("Unknown test failure")
  }
}
