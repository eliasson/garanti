import garanti.{type Suite, Suite, Test}
import garanti/expect
import gleam/int
import gleam/option

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

pub fn to_be_some_suite() -> Suite {
  Suite("to_be_some", [
    Test("should pass", fn() { expect.to_be_some(option.Some(1), 1) }),
    Test("should fail due to actual is not expected", fn() {
      expect.to_be_some(option.Some(1), 2)
    }),
    Test("should fail due to actual is None", fn() {
      expect.to_be_some(option.None, "world")
    }),
  ])
}

pub fn to_be_none_suite() -> Suite {
  Suite("to_be_none", [
    Test("should pass", fn() { expect.to_be_none(option.None) }),
    Test("should fail due to actual is Some", fn() {
      expect.to_be_none(option.Some(1))
    }),
  ])
}

pub fn to_be_ok_then_suite() -> Suite {
  Suite("to_be_ok_then", [
    Test("should pass", fn() {
      expect.to_be_ok_then(Ok(42), fn(n) { expect.to_be_equal(n, 42) })
    }),
    Test("should fail due to actual is not OK", fn() {
      expect.to_be_ok_then(Error(1), fn(n) { expect.to_be_equal(n, 42) })
    }),
  ])
}

pub fn to_be_ok_suite() -> Suite {
  Suite("to_be_ok", [
    Test("should pass", fn() { expect.to_be_ok(Ok(42)) }),
    Test("should fail due to actual is not OK", fn() {
      expect.to_be_ok(Error(1))
    }),
  ])
}

pub fn to_be_error_then_suite() -> Suite {
  Suite("to_be_error_then", [
    Test("should pass", fn() {
      expect.to_be_error_then(Error(42), fn(n) { expect.to_be_equal(n, 42) })
    }),
    Test("should fail due to actual is not Error", fn() {
      expect.to_be_error_then(Ok(1), fn(n) { expect.to_be_equal(n, 42) })
    }),
  ])
}

pub fn to_be_error_suite() -> Suite {
  Suite("to_be_error", [
    Test("should pass", fn() { expect.to_be_error(Error(42)) }),
    Test("should fail due to actual is not Error", fn() {
      expect.to_be_error(Ok(1))
    }),
  ])
}

pub fn to_be_empty_suite() -> Suite {
  Suite("to_be_empty", [
    Test("should pass", fn() { expect.to_be_empty([]) }),
    Test("should fail due to not empty", fn() { expect.to_be_empty([1]) }),
  ])
}

pub fn to_contain_suite() -> Suite {
  Suite("to_contain", [
    Test("should pass", fn() { expect.to_contain([1, 2, 3], 2) }),
    Test("should fail due to not containing", fn() {
      expect.to_contain([1, 2, 3], 4)
    }),
  ])
}

pub fn to_be_greater_suite() -> Suite {
  Suite("to_be_greater", [
    Test("should pass", fn() { expect.to_be_greater(3, 2, int.compare) }),
    Test("should fail due to not greater than", fn() {
      expect.to_be_greater(2, 3, int.compare)
    }),
  ])
}

pub fn to_be_greater_or_equal_suite() -> Suite {
  Suite("to_be_greater_or_equal", [
    Test("should pass", fn() {
      expect.to_be_greater_or_equal(3, 3, int.compare)
    }),
    Test("should fail due to not greater than or equal toy", fn() {
      expect.to_be_greater_or_equal(2, 3, int.compare)
    }),
  ])
}
