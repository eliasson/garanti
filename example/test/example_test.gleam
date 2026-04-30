import garanti.{type Suite, Suite, Test}
import garanti/runner

pub fn main() -> Nil {
  runner.run()
}

// Each function ending in _suite returns suite which are run in parallel by Garanti.
pub fn hello_world_suite() -> Suite {
  Suite("Hello world", [
    Test("should pass", fn() { garanti.Pass }),
    Test("should also pass", fn() { garanti.Pass }),
  ])
}
