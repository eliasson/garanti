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
      report.Enriched("Suite", [report.Secondary]),
      report.Enriched(suite_name, [report.Name]),
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
    report.Enriched("completed with", [report.Secondary]),
    report.Enriched(
      int.to_string(pass_count) <> " of " <> int.to_string(total_count),
      [report.Name],
    ),
    report.Enriched("test(s) passed", [report.Secondary]),
  ]
}

fn failed_test(name: String, reason: String) -> List(report.Message) {
  [
    report.Message(report.Error, [
      report.Enriched(name, [report.Name]),
      report.Enriched("failed with:", [report.Negative, report.Bold]),
      report.Plain(reason),
    ]),
  ]
}
