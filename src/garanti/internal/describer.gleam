import garanti
import garanti/internal/report
import gleam/int
import gleam/list

/// Describe the test suite results where the first element in the returned list
/// is the suite's overall results. The remaining lines are the results for each
/// test.
pub fn suite_results(
  suite_name: String,
  results: List(garanti.TestResult),
) -> List(report.Message) {
  let #(failures, total_count, failure_count) =
    list.fold(results, #([], 0, 0), fn(acc, tr) {
      let #(msg, fail) = case tr {
        garanti.TestResult(name, result: garanti.Pass) -> {
          #(successful_test(name), 0)
        }
        garanti.TestResult(name:, result: garanti.Fail(reason)) -> {
          #(failed_test(name, reason), 1)
        }
      }

      #(list.append(acc.0, msg), acc.1 + 1, acc.2 + fail)
    })

  let overall =
    report.Message(report.Info, [
      report.Enriched("Suite", [report.Secondary]),
      report.Enriched(suite_name, [report.Name]),
      ..suite_completion(total_count, failure_count)
    ])

  [overall, ..failures]
}

fn suite_completion(total_count: Int, failure_count: Int) {
  let pass_count = total_count - failure_count

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
      report.Indent,
      report.Enriched("Test", [report.Secondary]),
      report.Enriched(name, [report.Name]),
      report.Enriched("failed with:", [report.Negative, report.Bold]),
      report.Plain(reason),
    ]),
  ]
}

fn successful_test(name: String) -> List(report.Message) {
  [
    report.Message(report.Info, [
      report.Indent,
      report.Enriched("Test", [report.Secondary]),
      report.Enriched(name, [report.Name]),
      report.Enriched("completed", [report.Secondary]),
      report.Enriched("successfully", [report.Positive, report.Bold]),
    ]),
  ]
}
