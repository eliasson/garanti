//// The test executor is responsible for running a single test in isolation and report back the
//// result of the test.

import garanti
import gleam/erlang/process
import logging.{Debug, log}

/// The result of a single test execution.
pub type ExecutionResult {
  /// The test was successfully executed (the test may have passer or failed, but the execution was OK).
  Executed(garanti.AssertionResult)
  /// The test could not successfully be executed.
  ExecutionFailure(String)
}

// TODO We should add some sort of TestContext that can carry things like:
// - Timeout limit

/// Execute the given test in isolation and return the result
pub fn run(test_fn: fn() -> garanti.AssertionResult) -> ExecutionResult {
  log(Debug, "Preparing test for execution")

  let test_subject = process.new_subject()

  // Create an unlinked process to allow for it to crash without us going down.
  let pid =
    process.spawn_unlinked(fn() {
      // TODO Disable the erlang kernel loggning for this process so that crashes are not printed to std out.
      log(Debug, "Executing tests")
      // Execute the test function and send the result to the subject
      process.send(test_subject, test_fn())
    })

  // Monitor the test execution for when the process terminates.
  let monitor = process.monitor(pid)

  // Subscribe to messages from the proces
  let selector =
    process.new_selector()
    |> process.select_map(test_subject, Executed)
    |> process.select_monitors(fn(down) {
      log(Debug, "Test could not be executed")
      case down {
        // TODO Identify if the test timed out, crached or whatever.
        _ -> ExecutionFailure("Unknown test failure")
      }
    })

  // Wait for the test to execute for up to 1 second (this should be made configurable)
  let result = process.selector_receive(selector, within: 1000)

  // Stop the monitor now that we have a result (or timeout, which is also a result).
  process.demonitor_process(monitor)

  case result {
    Ok(execution_result) -> {
      log(Debug, "Test executed successfully")
      execution_result
    }

    Error(Nil) -> {
      log(Debug, "Test timed out")
      ExecutionFailure("Test execution timed out")
    }
  }
}
