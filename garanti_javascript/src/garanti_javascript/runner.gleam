import garanti
import garanti/shared/analysis
import garanti/shared/console
import garanti/shared/report
import garanti_javascript/internal/discovery
import garanti_javascript/internal/suite
import garanti_javascript/internal/reporter
import gleam/int
import gleam/javascript/promise.{type Promise}
import gleam/list

pub fn run(level: garanti.LogLevel) -> Promise(Nil) {
  let output = console.Output(level)
  let print = fn(m: report.Message) { console.print(output, m) }

  // Discovery is async in JS so we have to map the promise of suites.
  // everything below this point will be synchronous though.
  use suites <- promise.map(discovery.discover_all_suites())

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
    _ -> {
        suites
        |> list.map(suite.run)
        |> reporter.report(output, _)
      Nil
    }
  }
}
