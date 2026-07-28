import garanti.{Suite, Test}
import garanti/expect

pub fn to_be_ok_then_suite() {
  Suite("Matching to_be_ok_then", [
    Test("it should return the assertion result from the callbakc", fn() {
      expect.to_be_ok_then(Ok(1), fn(_: Int) { garanti.Fail("Faked error", []) })
      |> expect.to_be_equal(garanti.Fail("Faked error", []))
    }),

    Test("it should not the given test callback for Error values", fn() {
      expect.to_be_ok_then(Error(Nil), fn(_: Int) { garanti.Pass })
      |> expect.to_be_equal(
        garanti.Fail("Expected actual to be Ok but it was an Error of Nil", [
          garanti.Actual("Nil"),
          garanti.Expected("Ok"),
        ]),
      )
    }),
  ])
}

pub fn to_be_ok_suite() {
  Suite("Matching to_be_ok", [
    Test("it should pass when actual is Ok", fn() {
      expect.to_be_ok(Ok(1))
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should fail if actual is Error", fn() {
      expect.to_be_ok(Error(Nil))
      |> expect.to_be_equal(
        garanti.Fail("Expected actual to be Ok but it was an Error of Nil", []),
      )
    }),
  ])
}
