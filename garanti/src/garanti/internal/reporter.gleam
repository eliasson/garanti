import garanti
import garanti/shared/console.{type Output, print}
import garanti/shared/describer
import gleam/list

/// Report the given results and return whether the run was successful.
pub fn report(out: Output, results: List(garanti.SuiteResult)) -> Bool {
  let totals =
    list.fold(
      results,
      describer.ReportTotals(0, 0, [], 0),
      fn(acc, suite_result) {
        let #(messages, new_acc) =
          describer.suite_result_report(acc, suite_result)
        list.each(messages, fn(m) { print(out, m) })
        new_acc
      },
    )

  // Repeat all failures after all test have been reported.
  list.each(describer.failures_summary(totals.failures), fn(m) { print(out, m) })

  // End the report with a short summary.
  print(out, describer.run_summary(totals.total_tests, totals.total_failures))

  describer.is_successful(totals)
}
