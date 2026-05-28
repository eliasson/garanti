import garanti.{Suite, Test}
import garanti/expect

type Foo {
  Foo(a: Int, b: Int)
}

pub fn to_be_contain_suite() {
  Suite("Matching to_contain", [
    Test("it should pass when list contains element", fn() {
      expect.to_contain([1, 2, 3], 2)
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should fail for list with no elements", fn() {
      expect.to_contain([], 2)
      |> expect.to_be_equal(garanti.Fail("Expected empty list to contain 2"))
    }),

    Test("it should fail for list with missing element", fn() {
      expect.to_contain([1, 3, 5, 7], 2)
      |> expect.to_be_equal(garanti.Fail(
        "Expected list to contain 2 but contained [1] and 3 more element(s)",
      ))
    }),

    Test("it should fail for list with missing object", fn() {
      expect.to_contain([Foo(1, 2), Foo(3, 4)], Foo(2, 4))
      |> expect.to_be_equal(garanti.Fail(
        "Expected list to contain Foo(2, 4) but contained [Foo(1, 2)] and 1 more element(s)",
      ))
    }),
  ])
}
