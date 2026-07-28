import example
import garanti.{type Suite, Suite, Test}
import garanti/expect

pub fn math_suite() -> Suite {
  Suite("math", [
    Test("should add two numbers", fn() {
      example.add(2, 2)
      |> expect.to_be_equal(4)
    }),

    Test("should divide by two", fn() {
      use result <- expect.to_be_ok_then(example.divide(4, 2))
      expect.to_be_equal(result, 2)
    }),

    Test("should not divide by zero", fn() {
      use result <- expect.to_be_error_then(example.divide(4, 0))
      expect.to_be_equal(result, Nil)
    }),
  ])
}
