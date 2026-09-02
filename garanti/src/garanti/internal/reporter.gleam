import garanti
import garanti/shared/console.{type Output, print}
import garanti/shared/describer
import gleam/list

pub fn report(out: Output, results: List(garanti.SuiteResult)) -> Nil {
  let #(total_tests, total_failures, failures) =
    list.fold(results, #(0, 0, []), fn(acc, suite_result) {
      let #(messages, new_acc) =
        describer.suite_result_report(acc, suite_result)
      list.each(messages, fn(m) { print(out, m) })
      new_acc
    })

  // Repeat all failures after all test have been reported.
  list.each(describer.failures_summary(failures), fn(m) { print(out, m) })

  // End the report with a short summary.
  print(out, describer.run_summary(total_tests, total_failures))

  Nil
}
