import garanti.{type Suite, Suite, Test}
import garanti/expect

// The goal is to have this example exhaustive on both passing and failing tests for
// each matcher.
//
// This is useful when working on the matcher test result messages. The Garanti unit-test
// asserts on structure, and since the matcher will describe the expected descibe structure
// it becomes a bit too meta to be easy to visually scan / review.

pub fn to_be_equal_suite() -> Suite {
  Suite("to_be_equal", [
    Test("should pass", fn() { expect.to_be_equal(1, 1) }),
    Test("should fail", fn() { expect.to_be_equal(1, 2) }),
  ])
}

pub fn to_not_be_equal_suite() -> Suite {
  Suite("to_not_be_equal", [
    Test("should pass", fn() { expect.to_not_be_equal(1, 2) }),
    Test("should fail", fn() { expect.to_not_be_equal(1, 1) }),
  ])
}

pub fn to_be_equivalent_suite() -> Suite {
  Suite("to_be_equivalent", [
    Test("should pass", fn() { expect.to_be_equivalent([1, 2, 3], [3, 1, 2]) }),
    Test("should fail due to missing", fn() {
      expect.to_be_equivalent([1, 2], [1, 2, 3])
    }),
    Test("should fail due to extra", fn() {
      expect.to_be_equivalent([1, 2, 3], [1, 2])
    }),
    Test("should fail due to both missing and extra", fn() {
      expect.to_be_equivalent([1, 4], [1, 2, 3])
    }),
  ])
}
