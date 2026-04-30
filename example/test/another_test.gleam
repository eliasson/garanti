import garanti.{type Suite, Suite, Test}

pub fn another_suite() -> Suite {
  Suite("Suite 3", [
    Test("should pass", fn() { garanti.Pass }),
    Test("should also pass", fn() { garanti.Fail("I was set up to fail!") }),
  ])
}
