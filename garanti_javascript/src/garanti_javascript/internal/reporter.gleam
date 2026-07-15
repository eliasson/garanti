import garanti
import garanti/shared/console.{type Output, print}
import garanti/shared/describer
import garanti/shared/report
import gleam/list

pub fn report(out: Output, results: List(garanti.SuiteResult)) -> Nil {
  let #(total_tests, total_failures) =
    list.fold(results, #(0, 0), fn(acc, suite_result) {
      report_suite(out, acc, suite_result)
    })

  print(out, describer.run_summary(total_tests, total_failures))

  Nil
}

fn report_suite(
  out: Output,
  acc: #(Int, Int),
  suite_result: garanti.SuiteResult,
) -> #(Int, Int) {
  case suite_result {
    garanti.SuiteComplete(suite_name:, results:) -> {
      let suite_tests = list.length(results)
      let suite_failures =
        list.count(results, fn(tr) {
          case tr {
            garanti.TestResult(_, garanti.Pass) -> False
            _ -> True
          }
        })

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

      #(acc.0 + suite_tests, acc.1 + suite_failures)
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
