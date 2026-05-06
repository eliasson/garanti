// NOTE.
// The console reporter lacks unit-tests. It is tested by running "gleam test" from
// the `./example/` directory.

import garanti
import garanti/internal/console
import garanti/internal/describer
import gleam/erlang/process.{type Subject}

import gleam/otp/actor

/// Start a new reporter and return the subject the suite actors should publish to
/// regarding their progress.
pub fn start(
  out: console.Output,
  number_suites: Int,
) -> Result(actor.Started(Subject(garanti.SuiteResult)), actor.StartError) {
  actor.new(State(number_suites))
  |> actor.on_message(fn(s, m) { handle_message(out, s, m) })
  |> actor.start()
}

type State {
  State(number_suites: Int)
}

fn handle_message(out: console.Output, state: State, msg: garanti.SuiteResult) {
  case msg {
    garanti.SuiteComplete(suite_name:, results:) -> {
      console.info(out, describer.suite_results(suite_name, results))

      let new_state = State(state.number_suites - 1)
      case new_state.number_suites {
        0 -> actor.stop()
        _ -> actor.continue(new_state)
      }
    }

    garanti.SuiteCancelled(suite_name) -> {
      console.warning(out, "Suite " <> suite_name <> " was cancelled")

      let new_state = State(state.number_suites - 1)
      case new_state.number_suites {
        0 -> actor.stop()
        _ -> actor.continue(new_state)
      }
    }
  }
}
