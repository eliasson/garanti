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

/// Summarize the failing tests by listing the suite, test and failures. No passing tests
/// is included in the summary.
pub fn failures_summary(
  failures: List(#(String, garanti.TestResult)),
) -> List(report.Message) {
  let items =
    list.flat_map(failures, fn(item) {
      let #(suite_name, tr) = item
      case tr {
        garanti.TestResult(name:, result: garanti.Fail(summary, expectations)) ->
          failed_test_recap(suite_name, name, summary, expectations)
        garanti.TestResult(name:, result: garanti.Timeout) ->
          timeout_test_recap(suite_name, name)
        garanti.TestResult(_, garanti.Pass) -> []
      }
    })

  case items {
    [] -> []
    _ -> [
      report.Message(report.Error, [
        report.NewLine,
        report.Enriched("Failures:", [report.Negative, report.Bold]),
      ]),
      ..items
    ]
  }
}

fn failed_test_recap(
  suite_name: String,
  name: String,
  summary: String,
  expectations: List(garanti.Expectation),
) -> List(report.Message) {
  let message = [
    report.Indent,
    report.Enriched("Suite", [report.Secondary]),
    report.Enriched(suite_name, [report.Name]),
    report.NewLine,
    report.Indent,
    report.Indent,
    report.Enriched("Test", [report.Secondary]),
    report.Enriched(name, [report.Name]),
    report.Enriched("failed with:", [report.Negative, report.Bold]),
    report.NewLine,
    report.Indent,
    report.Indent,
    report.Indent,
    report.Enriched(summary, [report.Name]),
  ]

  let exp =
    expectations
    |> list.map(fn(e) { describe(2, e) })
    |> list.flatten
    |> list.append([report.NewLine])

  [report.Message(report.Error, list.append(message, exp))]
}

fn timeout_test_recap(
  suite_name: String,
  name: String,
) -> List(report.Message) {
  [
    report.Message(report.Info, [
      report.Indent,
      report.Enriched("Suite", [report.Secondary]),
      report.Enriched(suite_name, [report.Name]),
      report.Enriched("Test", [report.Secondary]),
      report.Enriched(name, [report.Name]),
      report.Enriched("timed out", [report.Negative, report.Bold]),
    ]),
  ]
}

/// The running totals accumulated while reporting a sequence of suite results.
pub type ReportTotals {
  ReportTotals(
    /// The total number of tests processed (so far).
    total_tests: Int,
    /// The total number of failures processed (so far).
    total_failures: Int,
    /// All failures colleted (so far).
    failures: List(#(String, garanti.TestResult)),
  )
}

/// Get the messages to report for the given suite result as well as an updated accumulator
/// that tracks the total number of tests and failures.
pub fn suite_result_report(
  acc: ReportTotals,
  suite_result: garanti.SuiteResult,
) -> #(List(report.Message), ReportTotals) {
  case suite_result {
    garanti.SuiteComplete(suite_name:, results:) -> {
      let suite_tests = list.length(results)

      // An empty suite result shouldn't happen in practice (empty suites are
      // skipped before running), but is reported rather than silently dropped.
      let messages = case suite_results(suite_name, results) {
        [] -> [
          report.Message(report.Warning, [
            report.Plain("Suite"),
            report.Enriched(suite_name, [report.Name, report.Bold]),
            report.Plain("contained no result!"),
          ]),
        ]
        messages -> messages
      }

      let suite_failing_results = failing_tests(results)
      let suite_failures = list.length(suite_failing_results)

      let new_acc =
        ReportTotals(
          total_tests: acc.total_tests + suite_tests,
          total_failures: acc.total_failures + suite_failures,
          failures: list.append(
            acc.failures,
            list.map(suite_failing_results, fn(tr) { #(suite_name, tr) }),
          ),
        )

      #(messages, new_acc)
    }

    garanti.SuiteCancelled(suite_name) -> {
      let messages = [
        report.Message(report.Warning, [
          report.Plain("Suite"),
          report.Enriched(suite_name, [report.Name, report.Bold]),
          report.Plain("was cancelled"),
        ]),
      ]
      #(messages, acc)
    }
  }
}

fn failing_tests(
  results: List(garanti.TestResult),
) -> List(garanti.TestResult) {
  list.filter(results, fn(tr) {
    case tr {
      garanti.TestResult(_, garanti.Pass) -> False
      _ -> True
    }
  })
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
