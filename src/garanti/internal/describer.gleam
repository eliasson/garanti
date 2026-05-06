import garanti
import gleam/int
import gleam/list

pub fn suite_results(
  suite_name: String,
  results: List(garanti.TestResult),
) -> String {
  let #(pass, total) =
    list.fold(results, #(0, 0), fn(acc, tr) {
      let p = case tr {
        garanti.TestResult(result: garanti.Pass, ..) -> acc.0 + 1
        _ -> acc.0
      }
      #(p, acc.1 + 1)
    })

  "Suite "
  <> suite_name
  <> " completed"
  <> " ("
  <> int.to_string(pass)
  <> " of "
  <> int.to_string(total)
  <> " passed)"
}
