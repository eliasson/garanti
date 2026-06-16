import garanti.{type Suite}

import gleam/list
import gleam/set
import gleam/string

/// Represents the different issues found during suite analysis.
pub type AnalysisResult {
  /// When more than one suite share the same name (case-insensitive).
  DuplicateSuiteName(suite_name: String)
  /// A suite that contains no tests.
  EmptySuite(suite_name: String)
}

/// Process the list of suites that was discovered and identify any potential problems with
/// the prospects. This will not block any suites. As long as a suite compiles it will run,
/// even when there are issues found.
///
/// Such as:
/// - Non-unique suite name.
/// - Empty suites.
pub fn analyse_suites(suites: List(Suite)) -> List(AnalysisResult) {
  analyse_suites_loop(suites, set.new())
}

/// Describe the analysis result as a String.
pub fn describe_analysis_result(result: AnalysisResult) -> String {
  case result {
    DuplicateSuiteName(suite_name:) ->
      "Multiple suite are named \"" <> suite_name <> "\"."
    EmptySuite(suite_name:) -> "Suite \"" <> suite_name <> " has no tests."
  }
}

fn analyse_suites_loop(
  suites: List(Suite),
  names: set.Set(String),
) -> List(AnalysisResult) {
  case suites {
    [] -> []
    [head, ..tail] -> {
      // First check, have we seen this name before?
      let suite_name = string.lowercase(head.name)
      let duplicates = case set.contains(names, suite_name) {
        True -> [DuplicateSuiteName(head.name)]
        False -> []
      }

      let empties = case head.tests {
        [] -> [EmptySuite(head.name)]
        _ -> []
      }

      duplicates
      |> list.append(empties)
      |> list.append(analyse_suites_loop(tail, set.insert(names, suite_name)))
    }
  }
}
