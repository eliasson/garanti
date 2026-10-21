import garanti
import garanti/discovery
import garanti/internal/reporter
import garanti/internal/suite
import garanti/shared/analysis
import garanti/shared/console
import garanti/shared/focus
import garanti/shared/report
import gleam/int
import gleam/list

@target(javascript)
import gleam/javascript/promise.{type Promise}

@target(erlang)
/// Start a test run.
/// - Discovery phase that identifies all available test suites.
/// - Run each suite's tests.
/// - Report progress and test result.
pub fn run(level: garanti.LogLevel) -> Nil {
  let output = console.Output(level)
  run_with_discovered(output, discovery.discover_all_suites(), execute_suites)
  |> exit_with_status
}

@target(javascript)
pub fn run(level: garanti.LogLevel) -> Promise(Nil) {
  let output = console.Output(level)

  // Discovery is async in JS so we have to map the promise of suites.
  // everything below this point will be synchronous though.
  use discovered <- promise.map(discovery.discover_all_suites())
  run_with_discovered(output, discovered, execute_suites)
  |> exit_with_status
}

/// Signal the outcome of a run through the process exit status.
pub fn exit_with_status(successful: Bool) -> Nil {
  case successful {
    // Just let the runner fall through to the default exit code (0).
    True -> Nil
    False -> exit_failure()
  }
}

@external(erlang, "garanti_runner_ffi", "exit_failure")
@external(javascript, "./garanti_runner_ffi.mjs", "exit_failure")
fn exit_failure() -> Nil

fn execute_suites(
  output: console.Output,
  suites: List(garanti.Suite),
  _nr_tests_to_run: Int,
) -> Bool {
  suites
  |> list.map(suite.run)
  |> reporter.report(output, _)
}

/// Run the discovered suites (delegated to the injected `execute` function).
///
/// Analyse, filter (focused), execute.
///
/// Returns whether the run was successful, a run without any tests to run is not.
pub fn run_with_discovered(
  output: console.Output,
  discovered: List(garanti.Suite),
  execute: fn(console.Output, List(garanti.Suite), Int) -> Bool,
) -> Bool {
  let print = fn(m: report.Message) { console.print(output, m) }

  let suites = focus.filter_focused(discovered)

  print(
    report.Message(report.Info, [
      report.Plain(
        "Discovered " <> list.length(suites) |> int.to_string <> " suite(s).",
      ),
    ]),
  )

  let messages = analysis.perform_analysis(suites)
  console.print_all(output, messages)

  // Skip running empty suites
  let tests_to_run = list.filter(suites, fn(s) { !list.is_empty(s.tests) })
  let nr_tests_to_run = list.length(tests_to_run)

  let successful = case nr_tests_to_run {
    0 -> {
      console.print(
        output,
        report.Message(report.Error, [
          report.Enriched("No test suites to run!", [
            report.Negative,
            report.Bold,
          ]),
        ]),
      )
      False
    }
    _ -> execute(output, suites, nr_tests_to_run)
  }

  case focus.is_focused_run(suites) {
    True -> {
      print(
        report.Message(report.Warning, [
          report.Enriched("Focused mode is active!", [
            report.Important,
            report.Bold,
          ]),
        ]),
      )
      Nil
    }
    False -> Nil
  }

  successful
}
