import garanti.{Suite, Test}
import garanti/expect

pub fn to_be_empty_suite() {
  Suite("Matching to_be_empty", [
    Test("it should pass for empty list", fn() {
      expect.to_be_empty([])
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should fail for list with elements", fn() {
      expect.to_be_empty(["bummer"])
      |> expect.to_be_equal(garanti.Fail(
        "Expected list to be empty but was [\"bummer\"]",
      ))
    }),

    Test("it should fail for list with elements", fn() {
      expect.to_be_empty(["bummer", "not", "empty"])
      |> expect.to_be_equal(garanti.Fail(
        "Expected list to be empty but was [\"bummer\", \"not\", \"empty\"]",
      ))
    }),
  ])
}
