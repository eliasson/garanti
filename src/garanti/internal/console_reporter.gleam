// NOTE.
// The console reporter lacks unit-tests. It is tested by running "gleam test" from
// the `./example/` directory.

import garanti
import garanti/internal/console.{print}
import garanti/internal/describer
import garanti/internal/report
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
  actor.new(State(number_suites, 0, 0))
  |> actor.on_message(fn(s, m) { handle_message(out, s, m, done_sub) })
  |> actor.start()
}

type State {
  State(number_suites: Int, total_tests: Int, total_failures: Int)
}

fn handle_message(
  out: console.Output,
  state: State,
  msg: garanti.SuiteResult,
  done_sub: Subject(Nil),
) {
  case msg {
    garanti.SuiteComplete(suite_name:, results:) -> {
      let suite_tests = list.length(results)
      let suite_failures =
        list.count(results, fn(tr) {
          case tr {
            garanti.TestResult(_, garanti.Pass) -> False
            _ -> True
          }
        })

      case describer.suite_results(suite_name, results) {
        [] -> {
          // This should not happen due to emtpy suite (since these are not run), when
          // will this occur? Timeouts?
          print(
            out,
            report.Message(report.Warning, [
              report.Plain("Suite"),
              report.Enriched(suite_name, [report.Name, report.Bold]),
              report.Plain("contained no result!"),
            ]),
          )
        }

        all -> {
          list.each(all, fn(message) { print(out, message) })
          out
        }
      }

      State(
        state.number_suites - 1,
        state.total_tests + suite_tests,
        state.total_failures + suite_failures,
      )
      |> are_we_done_yet(out, done_sub)
    }

    garanti.SuiteCancelled(suite_name) -> {
      print(
        out,
        report.Message(report.Warning, [
          report.Plain("Suite"),
          report.Enriched(suite_name, [report.Name, report.Bold]),
          report.Plain("was cancelled"),
        ]),
      )

      State(state.number_suites - 1, state.total_tests, state.total_failures)
      |> are_we_done_yet(out, done_sub)
    }
  }
}

fn are_we_done_yet(
  new_state: State,
  out: console.Output,
  done_sub: Subject(Nil),
) {
  case new_state.number_suites {
    0 -> {
      print(out, describer.run_summary(new_state.total_tests, new_state.total_failures))
      //Send a message to the done subject to indicate that all suites are run.
      process.send(done_sub, Nil)
      actor.stop()
    }

    _ -> actor.continue(new_state)
  }
}
