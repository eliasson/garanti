import garanti
import garanti/discovery
import garanti/runner
import garanti/shared/console
import garanti/shared/report
import garanti_erlang/internal/console_reporter
import garanti_erlang/internal/suite
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list

/// Start a test run.
/// - Discovery phase that identifies all available test suites.
/// - Run each suite in parallel.
/// - Report progress and test result.
pub fn run(level: garanti.LogLevel) -> Nil {
  let output = console.Output(level)
  runner.run_with_discovered(output, discovery.discover_all_suites(), run_tests)
}

fn run_tests(
  output: console.Output,
  suites: List(garanti.Suite),
  nr_tests_to_run: Int,
) -> Nil {
  let print = fn(m: report.Message) { console.print(output, m) }

  // Create a subject to be notified when all suits have run.
  let done_sub = process.new_subject()

  // Start the actor that collects progress from each suite.
  case console_reporter.start(done_sub, output, nr_tests_to_run) {
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

  // Wait for all suites to be run until terminating
  case process.receive(done_sub, within: 10 * 60 * 1000) {
    Ok(_) -> Nil
    _ -> {
      io.println("Test runner timed out!")
      Nil
    }
  }
}
