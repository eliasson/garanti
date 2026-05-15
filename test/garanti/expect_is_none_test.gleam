import garanti.{Suite, Test}
import garanti/expect
import gleam/option

pub fn to_be_none_suite() {
  Suite("When matching to_be_none", [
    Test("it should fail when actual is Some", fn() {
      expect.to_be_none(option.Some(12))
      |> expect.to_be_equal(garanti.Fail("Expected 12 to be None."))
    }),

    Test("it should pass when actual is None", fn() {
      expect.to_be_none(option.None)
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should fail when actual is Some of a string", fn() {
      expect.to_be_none(option.Some("two"))
      |> expect.to_be_equal(garanti.Fail("Expected \"two\" to be None."))
    }),
  ])
}
