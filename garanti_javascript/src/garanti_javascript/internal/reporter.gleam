import garanti
import garanti/shared/console.{type Output, print}
import garanti/shared/describer
import garanti/shared/report
import gleam/list

pub fn report(out: Output, results: List(garanti.SuiteResult)) -> Nil {
  let #(total_tests, total_failures, failures) =
    list.fold(results, #(0, 0, []), fn(acc, suite_result) {
      report_suite(out, acc, suite_result)
    })

  // Repeat all failures after all test have been reported.
  list.each(describer.failures_summary(failures), fn(m) { print(out, m) })

  // End the report with a short summary.
  print(out, describer.run_summary(total_tests, total_failures))

  Nil
}

fn report_suite(
  out: Output,
  acc: #(Int, Int, List(#(String, garanti.TestResult))),
  suite_result: garanti.SuiteResult,
) -> #(Int, Int, List(#(String, garanti.TestResult))) {
  case suite_result {
    garanti.SuiteComplete(suite_name:, results:) -> {
      let suite_tests = list.length(results)

      case describer.suite_results(suite_name, results) {
        [] ->
          print(
            out,
            report.Message(report.Warning, [
              report.Plain("Suite"),
              report.Enriched(suite_name, [report.Name, report.Bold]),
              report.Plain("contained no result!"),
            ]),
          )
        messages -> {
          // Maybe this should be a reduce instead.
          list.each(messages, fn(m) { print(out, m) })
          out
        }
      }

      // Collect the failing tests so these can be reported again.
      let suite_failing_results = failing_tests(results)
      let suite_failures = list.length(suite_failing_results)

      #(
        acc.0 + suite_tests,
        acc.1 + suite_failures,
        list.append(
          acc.2,
          list.map(suite_failing_results, fn(tr) { #(suite_name, tr) }),
        ),
      )
    }

    garanti.SuiteCancelled(suite_name) -> {
      print(
        out,
        report.Message(report.Warning, [
          report.Plain("Suite"),
          report.Enriched(suite_name, [report.Name, report.Bold]),
          report.Plain("was cancelled"),
        ]),
      )
      acc
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
