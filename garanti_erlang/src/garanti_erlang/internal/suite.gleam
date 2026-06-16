import garanti
import garanti_erlang/internal/executor
import gleam/erlang/process.{type Subject}
import gleam/int
import gleam/list
import gleam/otp/actor
import logging.{Debug, log}

pub type SuiteMessages {
  /// Message sent when a test within the suite has completed.
  TestComplete(result: garanti.TestResult)
  /// Message sent to abort the suite and ignore collecting any test results.
  CancelSuite
}

/// The state this actor keeps:
/// - The name of the suite.
/// - The collected results of the run tests.
/// - The subject to report progress to.
/// - The number of tests pending to be completed.
type State {
  State(
    suite_name: String,
    results: List(garanti.TestResult),
    reporter: process.Subject(garanti.SuiteResult),
    pending: Int,
  )
}

/// The maximum time in ms the suite actor is allowed to run during initialisation
/// to spawn all the test processes. Arbitrary number, 2 seconds feels pretty long.
const suite_test_spawn_timeout = 2000

pub fn start(
  suite: garanti.Suite,
  reporter: process.Subject(garanti.SuiteResult),
) -> Result(actor.Started(Subject(SuiteMessages)), actor.StartError) {
  // logging.configure()
  // logging.set_level(logging.Debug)

  actor.new_with_initialiser(
    suite_test_spawn_timeout,
    fn(self: process.Subject(SuiteMessages)) {
      let initial_test_count = list.length(suite.tests)

      log(
        Debug,
        "Initialising Suite with "
          <> int.to_string(initial_test_count)
          <> " tests",
      )

      // Fan out and start each test in the suite at once.
      list.each(suite.tests, fn(t) {
        // Spawn a new process for the executor to run in.
        process.spawn_unlinked(fn() {
          log(Debug, "Spawning test " <> t.name)
          // Execute the test and grab the result.
          let result = executor.run(t.run)

          // Send the result to the suite actor for progress keeping.
          process.send(
            self,
            TestComplete(execution_result_to_test_result(t, result)),
          )
        })
      })

      // Set the inital actor state.
      State(suite.name, [], reporter, initial_test_count)
      |> actor.initialised()
      |> actor.returning(self)
      |> Ok
    },
  )
  |> actor.on_message(handle_message)
  |> actor.start()
}

fn handle_message(state: State, msg: SuiteMessages) {
  case msg {
    TestComplete(result) -> {
      log(Debug, "Test completed")

      let results = [result, ..state.results]
      let pending = state.pending - 1

      case pending {
        0 -> {
          // We are done with this suite
          process.send(
            state.reporter,
            garanti.SuiteComplete(state.suite_name, results),
          )
          actor.stop()
        }
        _ -> {
          // There are still tests to collect result for.
          let new_state = State(..state, results:, pending:)
          actor.continue(new_state)
        }
      }
    }

    CancelSuite -> {
      // This will just stop the suite from listening for completions from the test.
      // The tests are still run in their processes. Can / should be send them something?
      process.send(state.reporter, garanti.SuiteCancelled(state.suite_name))
      actor.stop()
    }
  }
}

fn execution_result_to_test_result(
  t: garanti.Test,
  er: executor.ExecutionResult,
) -> garanti.TestResult {
  let result = case er {
    executor.Executed(garanti.Pass) -> garanti.Pass
    executor.Executed(garanti.Fail(reason)) -> garanti.Fail(reason)
    executor.Executed(garanti.Timeout) -> garanti.Timeout
    executor.ExecutionTimeout -> garanti.Timeout
    executor.ExecutionFailure(msg) -> garanti.Fail(msg)
  }

  garanti.TestResult(t.name, result)
}
