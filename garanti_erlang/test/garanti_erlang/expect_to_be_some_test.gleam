import garanti.{Suite, Test}
import garanti/expect
import gleam/option

pub fn to_be_some_suite() {
  Suite("When matching to_be_some", [
    Test("it should pass when actual is Some of expected", fn() {
      expect.to_be_some(option.Some(12), 12)
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should fail when actual is None", fn() {
      expect.to_be_some(option.None, 12)
      |> expect.to_be_equal(garanti.Fail("Expected None to be 12.", []))
    }),

    Test("it should fail when when actual is different than expected", fn() {
      expect.to_be_some(option.Some("one"), "two")
      |> expect.to_be_equal(garanti.Fail("Expected \"one\" to be \"two\".", []))
    }),
  ])
}
