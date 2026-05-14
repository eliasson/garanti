import garanti
import garanti/internal/console
import garanti/internal/console_reporter
import garanti/internal/discovery
import garanti/internal/report
import garanti/internal/suite
import gleam/int
import gleam/list
import gleam/string

/// Start a test run.
/// - Discovery phase that identifies all available test suites.
/// - Run each suite in parallel.
/// - Report progress and test result.
pub fn run(level: garanti.LogLevel) -> Nil {
  let output = console.Output(level)
  let print = fn(m: report.Message) { console.print(output, m) }

  let suites = discovery.discover_all_suites()

  print(
    report.Message(report.Info, [
      report.Plain(
        "Discovered " <> list.length(suites) |> int.to_string <> " suite(s).",
      ),
    ]),
  )

  let messages = perform_analysis(suites)
  console.print_all(output, messages)

  // Skip running empty suites
  let tests_to_run = list.filter(suites, fn(s) { !list.is_empty(s.tests) })
  let nr_tests_to_run = list.length(tests_to_run)

  // Start the actor that collects progress from each suite.
  case console_reporter.start(output, nr_tests_to_run) {
    Ok(started) -> {
      print(
        report.Message(report.Info, [
          report.Plain(
            "Running " <> nr_tests_to_run |> int.to_string <> " suites...",
          ),
        ]),
      )

      // Start a suite actor for each discovered suite.
      list.each(suites, fn(s) { suite.start(s, started.data) })
    }

    _ -> {
      print(
        report.Message(report.Error, [
          report.Plain("Failed to start the console reporter!"),
        ]),
      )
      Nil
    }
  }
  Nil
}

fn perform_analysis(suites: List(garanti.Suite)) -> List(report.Message) {
  case discovery.analyse_suites(suites) {
    [] -> [
      report.Message(report.Info, [
        report.Plain("Analysed suites: No problems found."),
      ]),
    ]
    results ->
      results
      |> list.map(discovery.describe_analysis_result)
      |> list.sort(string.compare)
      |> list.map(fn(msg) {
        report.Message(report.Warning, [report.Plain(msg)])
      })
  }
}
