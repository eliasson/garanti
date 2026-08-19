import garanti.{type Suite, FocusedSuite}
import gleam/list

/// Filter the given suites so that only focused suites remain.
///
/// When no suites are focused, all suites are returned.
pub fn filter_focused(suites: List(Suite)) -> List(Suite) {
  case list.filter(suites, is_focused) {
    [] -> suites
    focused -> focused
  }
}

fn is_focused(suite: Suite) -> Bool {
  case suite {
    FocusedSuite(..) -> True
    _ -> False
  }
}
