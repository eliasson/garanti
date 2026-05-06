import garanti
import garanti/internal/discovery
import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub fn run() -> Nil {
  // Discover all tests
  // Create main reported
  // Spawn Suite actors
  // Wait until all suites have completed
  // Print result
  let suites = discovery.discover_all_suites()

  perform_analysis(suites)

  io.println(
    "Discovered " <> list.length(suites) |> int.to_string <> " suite(s).",
  )
}

// Analyse suites and display any warnings for the user
fn perform_analysis(suites: List(garanti.Suite)) {
  case discovery.analyse_suites(suites) {
    [] -> ["Analysed suites: No problems found."]
    results ->
      results
      |> list.map(discovery.describe_analysis_result)
      |> list.map(fn(msg) { string.append("[WARNING] ", msg) })
      |> list.sort(string.compare)
  }
  |> list.each(io.println)
}
