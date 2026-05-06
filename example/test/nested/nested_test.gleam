import garanti.{type Suite, Suite, Test}

pub fn nested_suite() -> Suite {
  Suite("Suite 3", [
    Test("should pass", fn() { garanti.Pass }),
  ])
}
