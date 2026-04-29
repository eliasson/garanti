import garanti
import gleam/erlang/process.{type Subject}
import gleam/otp/actor

pub type SuiteMessages {
  /// Message sent when a test within the suite has completed.
  TestComplete
}

/// The state this actor keeps:
/// - The name of the suite.
/// - The collected results of the run tests.
/// - The subject to report progress to
type State {
  State(
    suite_name: String,
    results: List(garanti.TestResult),
    reporter: process.Subject(garanti.SuiteResult),
  )
}

/// The maximum time in ms the suite actor is allowed to run during initialisation
/// to spawn all the test processes. Arbitrary number, 2 seconds feels pretty long.
const suite_test_spawn_timeout = 2000

pub fn start(
  suite: garanti.Suite,
  reporter: process.Subject(garanti.SuiteResult),
) -> Result(actor.Started(Subject(SuiteMessages)), actor.StartError) {
  actor.new_with_initialiser(
    suite_test_spawn_timeout,
    fn(self: process.Subject(SuiteMessages)) {
      // TODO Fan out and spawn one process per test in the suite at once.
      // Just send one TestComplete message to stop the actor again
      process.send(self, TestComplete)

      // Set the inital actor state.
      State(suite.name, [], reporter)
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
    TestComplete -> {
      // For now complete the suite on first test
      process.send(
        state.reporter,
        garanti.SuiteComplete(state.suite_name, state.results),
      )
      actor.stop()
    }
  }
}
