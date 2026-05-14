import garanti
import gleam/int
import gleam/list

/// Describe the test suite results where the first element in the returned list
/// is the suite's overall results. The remaining lines are the results for each
/// _failing_ test.
pub fn suite_results(
  suite_name: String,
  results: List(garanti.TestResult),
) -> List(String) {
  let #(failures, total_count) =
    list.fold(results, #([], 0), fn(acc, tr) {
      case tr {
        garanti.TestResult(result: garanti.Pass, ..) -> {
          #(acc.0, acc.1 + 1)
        }
        garanti.TestResult(name:, result: garanti.Fail(failure)) -> {
          #(
            list.append(acc.0, [name <> " failed with: " <> failure]),
            acc.1 + 1,
          )
        }
      }
    })

  let pass_count = total_count - list.length(failures)
  let overall =
    "Suite "
    <> suite_name
    <> " completed"
    <> " ("
    <> int.to_string(pass_count)
    <> " of "
    <> int.to_string(total_count)
    <> " passed)"

  [overall, ..failures]
}
