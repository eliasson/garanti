import garanti
import garanti/internal/console.{Error, Info}
import garanti/internal/console_reporter
import garanti/internal/discovery
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
  let print = fn(m: console.Message) { console.print(output, m) }

  let suites = discovery.discover_all_suites()
  let number_of_suites = list.length(suites)

  let messages = perform_analysis(suites)
  console.print_all(output, messages)

  print(Info("Discovered " <> number_of_suites |> int.to_string <> " suite(s)."))

  // Start the actor that collects progress from each suite.
  case console_reporter.start(output, number_of_suites) {
    Ok(started) -> {
      print(Info(
        "Running " <> number_of_suites |> int.to_string <> " suites...",
      ))

      // Start a suite actor for each discovered suite.
      list.each(suites, fn(s) { suite.start(s, started.data) })
    }

    _ -> {
      print(Error("Failed to start the console reporter!"))
      Nil
    }
  }
  Nil
}

fn perform_analysis(suites: List(garanti.Suite)) -> List(console.Message) {
  case discovery.analyse_suites(suites) {
    [] -> [Info("Analysed suites: No problems found.")]
    results ->
      results
      |> list.map(discovery.describe_analysis_result)
      |> list.sort(string.compare)
      |> list.map(console.Warning)
  }
}
