import garanti
import garanti/shared/report
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
        garanti.TestResult(name:, result: garanti.Fail(summary, expectation)) -> {
          #(failed_test(name, summary, expectation), 1)
        }
        garanti.TestResult(name:, result: garanti.Timeout) -> {
          #(timeout_test(name), 1)
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
  case failure_count {
    0 -> [
      report.Enriched("completed", [report.Secondary]),
      report.Enriched("successfully", [report.Positive, report.Bold]),
      report.Enriched("with", [report.Secondary]),
      report.Enriched(int.to_string(total_count), [report.Name]),
      report.Enriched("test(s)", [report.Secondary]),
    ]
    _ -> [
      report.Enriched("completed with", [report.Secondary]),
      report.Enriched(int.to_string(failure_count), [report.Name]),
      report.Enriched("failure(s)", [report.Negative, report.Bold]),
    ]
  }
}

fn failed_test(
  name: String,
  summary: String,
  expectations: List(garanti.Expectation),
) -> List(report.Message) {
  let message = [
    report.Indent,
    report.Enriched("Test", [report.Secondary]),
    report.Enriched(name, [report.Name]),
    report.Enriched("failed with:", [report.Negative, report.Bold]),
    report.NewLine,
    report.Indent,
    report.Indent,
    report.Enriched(summary, [report.Name]),
  ]

  // Describe all expectations (one per line).
  let exp =
    expectations
    |> list.map(fn(e) { describe(0, e) })
    |> list.flatten
    |> list.append([report.NewLine])

  // End the message with a newline to make the failure easy to spot.
  let tokens = list.append(message, exp)

  // Now produce the entire message
  [
    report.Message(report.Error, tokens),
  ]
}

fn describe(
  level: Int,
  expectation: garanti.Expectation,
) -> List(report.Token) {
  // The number of identations is 2 for level 0.
  // Which is the normal suite -> test -> expectation
  let start = [
    report.NewLine,
    report.Indent,
    report.Indent,
    ..list.repeat(report.Indent, level)
  ]

  // Produce one indented line per expectation
  let rest = case expectation {
    garanti.Actual(a) -> [
      report.Enriched("Actual: ", [report.Bold]),
      report.Enriched(a, [report.Negative, report.Bold]),
    ]

    garanti.Expected(e) -> [
      report.Enriched("Expected: ", [report.Bold]),
      report.Enriched(e, [report.Positive, report.Bold]),
    ]

    garanti.NotExpected(v) -> [
      report.Enriched("NOT expected: ", [report.Bold]),
      report.Enriched(v, [report.Negative, report.Bold]),
    ]

    garanti.Missing(v) -> [
      report.Enriched("Missing: ", [report.Bold]),
      report.Enriched(v, [report.Negative, report.Bold]),
    ]

    garanti.Extra(v) -> [
      report.Enriched("Extra: ", [report.Bold]),
      report.Enriched(v, [report.Negative, report.Bold]),
    ]

    garanti.NestedTestFailure(nested_summary, nested_expectations) -> {
      list.append(
        // The acting header for the combined failure repeating the matcher summary.
        [
          report.Indent,
          report.Enriched(nested_summary, [report.Bold]),
        ],
        // Recurse to describe the nexted expectations with 2 added levels (one for the test summary
        // and one for the nested test summary).
        list.flat_map(nested_expectations, fn(e) { describe(level + 2, e) }),
      )
    }
  }

  // Now, return the entire result
  start
  |> list.append(rest)
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

pub fn run_summary(total_tests: Int, total_failures: Int) -> report.Message {
  case total_failures {
    0 ->
      report.Message(report.Success, [
        report.Enriched("All", [report.Secondary]),
        report.Enriched(int.to_string(total_tests), [report.Name]),
        report.Enriched("test(s) passed!", [report.Positive, report.Bold]),
      ])
    _ ->
      report.Message(report.Error, [
        report.Enriched(int.to_string(total_failures), [report.Name]),
        report.Enriched("of", [report.Secondary]),
        report.Enriched(int.to_string(total_tests), [report.Name]),
        report.Enriched("test(s) failed.", [report.Negative, report.Bold]),
      ])
  }
}

fn timeout_test(name: String) -> List(report.Message) {
  [
    report.Message(report.Info, [
      report.Indent,
      report.Enriched("Test", [report.Secondary]),
      report.Enriched(name, [report.Name]),
      report.Enriched("timed out", [report.Negative, report.Bold]),
    ]),
  ]
}
