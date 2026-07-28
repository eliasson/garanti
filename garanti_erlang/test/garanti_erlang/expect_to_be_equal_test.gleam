import garanti.{Suite, Test}
import garanti/expect

pub fn to_be_equal_suite() {
  Suite("When matching to_be_equal", [
    Test("it should pass when integers are equal", fn() {
      expect.to_be_equal(12, 12)
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should pass when strings are equal", fn() {
      expect.to_be_equal("abrakadabra", "abrakadabra")
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should fail when intergers are NOT equal", fn() {
      expect.to_be_equal(12, 22)
      |> expect.to_be_equal(
        garanti.Fail("Expected 12 to equal 22.", [
          garanti.Actual("12"),
          garanti.Expected("22"),
        ]),
      )
    }),

    Test("it should fail when strings are NOT equal", fn() {
      expect.to_be_equal("abrakadabra", "simsalabim")
      |> expect.to_be_equal(
        garanti.Fail("Expected \"abrakadabra\" to equal \"simsalabim\".", [
          garanti.Actual("\"abrakadabra\""),
          garanti.Expected("\"simsalabim\""),
        ]),
      )
    }),
  ])
}

pub fn to_not_be_equal_suite() {
  Suite("When matching to_not_be_equal", [
    Test("it should pass when integers are NOT equal", fn() {
      expect.to_not_be_equal(12, 44)
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should pass when strings are NOT equal", fn() {
      expect.to_not_be_equal("Abba", "Queen")
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should fail when integers are equal", fn() {
      expect.to_not_be_equal(12, 12)
      |> expect.to_be_equal(
        garanti.Fail("Expected 12 to NOT equal 12.", [
          garanti.Actual("12"),
          garanti.NotExpected("12"),
        ]),
      )
    }),

    Test("it should fail when strings are equal", fn() {
      expect.to_not_be_equal("Abba", "Abba")
      |> expect.to_be_equal(
        garanti.Fail("Expected \"Abba\" to NOT equal \"Abba\".", [
          garanti.Actual("\"Abba\""),
          garanti.NotExpected("\"Abba\""),
        ]),
      )
    }),
  ])
}
