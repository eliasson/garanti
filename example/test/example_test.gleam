import garanti.{type Suite, Suite, Test}
import garanti/runner

pub fn main() -> Nil {
  runner.run(garanti.Warning)
}

// Each function ending in _suite returns suite which are run in parallel by Garanti.
pub fn hello_world_suite() -> Suite {
  Suite("Suite 1", [
    Test("should pass", fn() { garanti.Pass }),
    Test("should also pass", fn() { garanti.Pass }),
  ])
}

pub fn second_suite() -> Suite {
  Suite("Suite 2", [
    Test("should pass", fn() { garanti.Pass }),
    Test("should also pass", fn() { garanti.Fail("I was set up to fail!") }),
    Test("should fail", fn() { garanti.Fail("I did fail") }),
  ])
}
