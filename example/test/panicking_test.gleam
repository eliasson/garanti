import garanti.{type Suite, Suite, Test}
import garanti/expect

pub fn panicking_suite() -> Suite {
  // When I used garanti in another project we made some setup in the suite.
  // This is run during discovery phase, which caused the test execution to a halt.
  let assert Ok(_) = will_fail()

  Suite("When the suite panics during setup", [
    Test("should pass", fn() { expect.to_be_equal(4, 4) }),
  ])
}

fn will_fail() -> Result(Nil, Nil) {
  Error(Nil)
}
