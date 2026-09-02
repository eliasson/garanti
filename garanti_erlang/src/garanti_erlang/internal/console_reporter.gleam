// NOTE.
// The console reporter lacks unit-tests. It is tested by running "gleam test" from
// the `./example/` directory.

import garanti
import garanti/shared/console.{print}
import garanti/shared/describer
import gleam/erlang/process.{type Subject}
import gleam/list
import gleam/otp/actor

/// Start a new reporter and return the subject the suite actors should publish to
/// regarding their progress.
pub fn start(
  done_sub: Subject(Nil),
  out: console.Output,
  number_suites: Int,
) -> Result(actor.Started(Subject(garanti.SuiteResult)), actor.StartError) {
  actor.new(State(number_suites, 0, 0, []))
  |> actor.on_message(fn(s, m) { handle_message(out, s, m, done_sub) })
  |> actor.start()
}

type State {
  State(
    number_suites: Int,
    total_tests: Int,
    total_failures: Int,
    failures: List(#(String, garanti.TestResult)),
  )
}

fn handle_message(
  out: console.Output,
  state: State,
  msg: garanti.SuiteResult,
  done_sub: Subject(Nil),
) {
  let #(messages, #(total_tests, total_failures, failures)) =
    describer.suite_result_report(
      #(state.total_tests, state.total_failures, state.failures),
      msg,
    )

  list.each(messages, fn(m) { print(out, m) })

  State(state.number_suites - 1, total_tests, total_failures, failures)
  |> are_we_done_yet(out, done_sub)
}

fn are_we_done_yet(
  new_state: State,
  out: console.Output,
  done_sub: Subject(Nil),
) {
  case new_state.number_suites {
    0 -> {
      list.each(describer.failures_summary(new_state.failures), fn(message) {
        print(out, message)
      })
      print(
        out,
        describer.run_summary(new_state.total_tests, new_state.total_failures),
      )
      //Send a message to the done subject to indicate that all suites are run.
      process.send(done_sub, Nil)
      actor.stop()
    }

    _ -> actor.continue(new_state)
  }
}
