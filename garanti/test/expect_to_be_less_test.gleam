import garanti.{Suite, Test}
import garanti/expect
import gleam/float
import gleam/int

pub fn to_be_less_suite() {
  Suite("When matching to_be_less", [
    Test("it should pass when integer value is less than the expected", fn() {
      expect.to_be_less(10, 11, int.compare)
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should pass when float value is less than the expected", fn() {
      expect.to_be_less(1.0, 1.1, float.compare)
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should fail when values are equal", fn() {
      expect.to_be_less(1, 1, int.compare)
      |> expect.to_be_equal(
        garanti.Fail("Expected 1 to be less than 1", [garanti.Actual("1")]),
      )
    }),

    Test("it should fail when actual value is greater", fn() {
      expect.to_be_less(3, 1, int.compare)
      |> expect.to_be_equal(
        garanti.Fail("Expected 3 to be less than 1", [garanti.Actual("3")]),
      )
    }),
  ])
}

pub fn to_be_less_or_equal_suite() {
  Suite("When matching to_be_less_or_equal", [
    Test("it should pass when integer value is less than the expected", fn() {
      expect.to_be_less_or_equal(10, 11, int.compare)
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should pass when float value is less than the expected", fn() {
      expect.to_be_less_or_equal(1.0, 1.1, float.compare)
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should pass when values are equal", fn() {
      expect.to_be_less_or_equal(1, 1, int.compare)
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should fail when actual value is greater", fn() {
      expect.to_be_less_or_equal(3, 1, int.compare)
      |> expect.to_be_equal(
        garanti.Fail("Expected 3 to be less than or equal to 1", [
          garanti.Actual("3"),
        ]),
      )
    }),
  ])
}
