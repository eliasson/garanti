import garanti.{Suite, Test}
import garanti/expect
import gleam/float
import gleam/int

pub fn to_be_greater_suite() {
  Suite("When matching to_be_greater", [
    Test("it should pass when integer value is greater than the expected", fn() {
      expect.to_be_greater(11, 10, int.compare)
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should pass when float valuee is greater than the expected", fn() {
      expect.to_be_greater(1.1, 1.0, float.compare)
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should fail when values are equal", fn() {
      expect.to_be_greater(1, 1, int.compare)
      |> expect.to_be_equal(garanti.Fail("Expected 1 to be greater than 1"))
    }),

    Test("it should fail when actual value is smaller", fn() {
      expect.to_be_greater(1, 3, int.compare)
      |> expect.to_be_equal(garanti.Fail("Expected 1 to be greater than 3"))
    }),
  ])
}

pub fn to_be_greater_than_suite() {
  Suite("When matching to_be_greater_or_equal", [
    Test("it should pass when integer value is greater than the expected", fn() {
      expect.to_be_greater_or_equal(11, 10, int.compare)
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should pass when float valuee is greater than the expected", fn() {
      expect.to_be_greater_or_equal(1.1, 1.0, float.compare)
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should pass when values are equal", fn() {
      expect.to_be_greater_or_equal(1, 1, int.compare)
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should fail when actual value is smaller", fn() {
      expect.to_be_greater_or_equal(1, 3, int.compare)
      |> expect.to_be_equal(garanti.Fail(
        "Expected 1 to be greater or equal to 3",
      ))
    }),
  ])
}
