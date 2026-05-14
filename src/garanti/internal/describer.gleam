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
  let #(pass, total) =
    list.fold(results, #(0, 0), fn(acc, tr) {
      let p = case tr {
        garanti.TestResult(result: garanti.Pass, ..) -> acc.0 + 1
        _ -> acc.0
      }
      #(p, acc.1 + 1)
    })

  let overall =
    "Suite "
    <> suite_name
    <> " completed"
    <> " ("
    <> int.to_string(pass)
    <> " of "
    <> int.to_string(total)
    <> " passed)"

  [overall]
}
