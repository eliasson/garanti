import garanti.{type Suite, Suite, Test}

pub fn another_suite() -> Suite {
  Suite("Suite 3", [
    Test("should pass", fn() { garanti.Pass }),
    Test("should also pass", fn() { garanti.Fail("I was set up to fail!") }),
  ])
}

pub fn duplicate_suite() -> Suite {
  Suite("Suite 3", [
    Test("should pass", fn() { garanti.Pass }),
  ])
}

// TODO Exclude empty suites from exected suite count.
// pub fn empty_suite() -> Suite {
//   Suite("Some forgotten suite", [])
// }

pub fn four_suite() -> Suite {
  Suite("Another dup", [
    Test("should pass", fn() { garanti.Pass }),
  ])
}

pub fn duplicate_four_suite() -> Suite {
  Suite("Another dup", [
    Test("should pass", fn() { garanti.Pass }),
    Test("will panic", fn() { panic }),
  ])
}
