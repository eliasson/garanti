import garanti.{Suite, Test}
import garanti/expect

pub fn to_be_error_then_suite() {
  Suite("Matching to_be_error_then", [
    Test("it should return the assertion result from the callback", fn() {
      expect.to_be_error_then(Error(1), fn(_: Int) {
        garanti.Fail("Faked error", [])
      })
      |> expect.to_be_equal(garanti.Fail("Faked error", []))
    }),

    Test("it should not call the given test callback for Error values", fn() {
      expect.to_be_error_then(Ok(1), fn(_: Int) { garanti.Pass })
      |> expect.to_be_equal(
        garanti.Fail("Expected actual to be Error but it was an Ok of 1", [
          garanti.Actual("1"),
          garanti.Expected("Error"),
        ]),
      )
    }),

    Test("it should pass when actual is Error", fn() {
      expect.to_be_error_then(Error(1), fn(_: Int) { garanti.Pass })
      |> expect.to_be_equal(garanti.Pass)
    }),
  ])
}

pub fn to_be_error_suite() {
  Suite("Matching to_be_error", [
    Test("it should pass when actual is Error", fn() {
      expect.to_be_error(Error(1))
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should fail if actual is Ok", fn() {
      expect.to_be_error(Ok(1))
      |> expect.to_be_equal(
        garanti.Fail("Expected actual to be Error but it was an Ok of 1", []),
      )
    }),
  ])
}
