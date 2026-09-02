import garanti
import garanti/shared/console.{type Output, print}
import garanti/shared/describer
import gleam/list

pub fn report(out: Output, results: List(garanti.SuiteResult)) -> Nil {
  let totals =
    list.fold(results, describer.ReportTotals(0, 0, []), fn(acc, suite_result) {
      let #(messages, new_acc) =
        describer.suite_result_report(acc, suite_result)
      list.each(messages, fn(m) { print(out, m) })
      new_acc
    })

  // Repeat all failures after all test have been reported.
  list.each(describer.failures_summary(totals.failures), fn(m) { print(out, m) })

  // End the report with a short summary.
  print(out, describer.run_summary(totals.total_tests, totals.total_failures))

  Nil
}
