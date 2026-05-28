import garanti.{Suite, Test}
import garanti/expect
import garanti/internal/list_ext

pub fn list_extensions_suite() {
  Suite("List extensions", [
    Test("it should describe an empty list", fn() {
      list_ext.describe([], 10)
      |> expect.to_be_equal("empty")
    }),

    Test("it should describe an short list of integers", fn() {
      list_ext.describe([1, 2, 3], 10)
      |> expect.to_be_equal("[1, 2, 3]")
    }),

    Test("it should describe an short list of strings", fn() {
      list_ext.describe(["a", "b", "c"], 10)
      |> expect.to_be_equal("[\"a\", \"b\", \"c\"]")
    }),

    Test("it should describe an long list of integers", fn() {
      list_ext.describe([1, 2, 3], 2)
      |> expect.to_be_equal("[1, 2, ...] with a total of 3 element(s)")
    }),

    Test("it should describe using zero limit", fn() {
      list_ext.describe([1, 2, 3], 0)
      |> expect.to_be_equal("[...] with a total of 3 element(s)")
    }),

    Test("it should describe using negative limit", fn() {
      list_ext.describe([1, 2, 3], -2)
      |> expect.to_be_equal("[...] with a total of 3 element(s)")
    }),
  ])
}
