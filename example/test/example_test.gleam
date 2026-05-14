import garanti.{type Suite, Suite, Test}
import garanti/expect
import garanti/runner
import gleam/option

pub fn main() -> Nil {
  runner.run(garanti.Debug)
}

// Each function ending in _suite returns suite which are run in parallel by Garanti.
pub fn hello_world_suite() -> Suite {
  Suite("Suite one", [
    Test("1 + 1 should equal 2", fn() { expect.to_be_equal(1 + 1, 2) }),
    Test("should also pass", fn() { expect.to_be_none(option.None) }),
  ])
}

pub fn second_suite() -> Suite {
  Suite("Suite 2", [
    Test("should pass", fn() { garanti.Pass }),
    Test("should fail", fn() { expect.to_be_none(option.Some("Sneaky")) }),
  ])
}
