import garanti.{Suite, Test}
import garanti/expect

pub fn to_be_equivalent_suite() {
  Suite("When matching to_be_equivalent", [
    Test("it should pass given ordered lists of integers", fn() {
      expect.to_be_equivalent([1, 2, 3], [1, 2, 3])
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should pass given unordered list of intergers", fn() {
      expect.to_be_equivalent([3, 1, 2], [2, 3, 1])
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should fail when actual is empty and expected is not", fn() {
      expect.to_be_equivalent([], [1, 2])
      |> expect.to_be_equal(garanti.Fail(
        "Actual value is missing element(s) [1, 2]",
      ))
    }),

    Test("it should fail when expected is empty and actual is not", fn() {
      expect.to_be_equivalent([1, 2], [])
      |> expect.to_be_equal(garanti.Fail(
        "Actual value has extra element(s) [1, 2]",
      ))
    }),

    Test("it should fail when actual is missing a value", fn() {
      expect.to_be_equivalent([1], [1, 2])
      |> expect.to_be_equal(garanti.Fail(
        "Actual value is missing element(s) [2]",
      ))
    }),

    Test("it should fial when actual has extra value", fn() {
      expect.to_be_equivalent([1, 2, 3], [1, 3])
      |> expect.to_be_equal(garanti.Fail(
        "Actual value has extra element(s) [2]",
      ))
    }),

    Test("it should fail when actual as duplicate value", fn() {
      expect.to_be_equivalent([1, 1, 1], [1, 1])
      |> expect.to_be_equal(garanti.Fail(
        "Actual value has extra element(s) [1]",
      ))
    }),

    Test("it should pass when given lists of matching strings", fn() {
      expect.to_be_equivalent(["Boys Don't Cry", "A Forest"], [
        "A Forest",
        "Boys Don't Cry",
      ])
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should fail when list of strings are not equivalent", fn() {
      expect.to_be_equivalent(["Boys Don't Cry", "A Forest"], [
        "A Forest",
        "Atmosphere",
      ])
      |> expect.to_be_equal(garanti.Fail(
        "Actual value is missing element(s) [\"Atmosphere\"] and has extra element(s) [\"Boys Don't Cry\"]",
      ))
    }),
  ])
}
