import garanti/internal/discovery
import gleam/io
import gleam/list

pub fn run() -> Nil {
  // Discover all tests
  // Create main reported
  // Spawn Suite actors
  // Wait until all suites have completed
  // Print result
  let suites = discovery.discover_all_suites()

  list.each(suites, fn(s) { io.println("Discovered suite: " <> s.name) })
}
