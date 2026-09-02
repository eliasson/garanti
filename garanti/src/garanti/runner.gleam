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
}

@target(javascript)
pub fn run(level: garanti.LogLevel) -> Promise(Nil) {
  let output = console.Output(level)

  // Discovery is async in JS so we have to map the promise of suites.
  // everything below this point will be synchronous though.
  use discovered <- promise.map(discovery.discover_all_suites())
  run_with_discovered(output, discovered, execute_suites)
}

fn execute_suites(
  output: console.Output,
  suites: List(garanti.Suite),
  _nr_tests_to_run: Int,
) -> Nil {
  suites
  |> list.map(suite.run)
  |> reporter.report(output, _)
  Nil
}

/// Run the discovered suites (delegated to the injected `execute` function).
///
/// Analyse, filter (focused), execute.
pub fn run_with_discovered(
  output: console.Output,
  discovered: List(garanti.Suite),
  execute: fn(console.Output, List(garanti.Suite), Int) -> Nil,
) -> Nil {
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

  case nr_tests_to_run {
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
      Nil
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
}
