// NOTE.
// The console reporter lacks unit-tests. It is tested by running "gleam test" from
// the `./example/` directory.

import garanti
import garanti/internal/console.{Info, Success, Warning, print}
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
      print(out, Info(describer.suite_results(suite_name, results)))

      State(state.number_suites - 1)
      |> are_we_done_yet(out)
    }

    garanti.SuiteCancelled(suite_name) -> {
      print(out, Warning("Suite " <> suite_name <> " was cancelled"))

      State(state.number_suites - 1)
      |> are_we_done_yet(out)
    }
  }
}

fn are_we_done_yet(new_state: State, out: console.Output) {
  case new_state.number_suites {
    0 -> {
      print(out, Success("All suites run!"))
      actor.stop()
    }

    _ -> actor.continue(new_state)
  }
}
