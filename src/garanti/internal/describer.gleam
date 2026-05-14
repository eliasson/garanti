import garanti
import garanti/internal/report
import gleam/int
import gleam/list

/// Describe the test suite results where the first element in the returned list
/// is the suite's overall results. The remaining lines are the results for each
/// _failing_ test.
pub fn suite_results(
  suite_name: String,
  results: List(garanti.TestResult),
) -> List(report.Message) {
  let #(failures, total_count) =
    list.fold(results, #([], 0), fn(acc, tr) {
      case tr {
        garanti.TestResult(result: garanti.Pass, ..) -> {
          #(acc.0, acc.1 + 1)
        }
        garanti.TestResult(name:, result: garanti.Fail(reason)) -> {
          #(list.append(acc.0, failed_test(name, reason)), acc.1 + 1)
        }
      }
    })

  let overall =
    report.Message(report.Info, [
      report.Plain("Suite"),
      report.important(suite_name),
      ..suite_completion(total_count, failures)
    ])

  [overall, ..failures]
}

fn suite_completion(total_count: Int, failures: List(report.Message)) {
  let pass_count = total_count - list.length(failures)

  // TODO Word things differently based on any failures:
  //   completed successfully with 3 tests
  //   completed with 3 failures
  [
    report.Plain("comleted with"),
    report.important(
      int.to_string(pass_count) <> " of " <> int.to_string(total_count),
    ),
    report.Plain("test(s) passed"),
  ]
}

fn failed_test(name: String, reason: String) -> List(report.Message) {
  [
    report.Message(report.Error, [
      report.important(name),
      report.negative("failed with:"),
      report.Plain(reason),
    ]),
  ]
}
