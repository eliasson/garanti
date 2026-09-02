import garanti.{Suite, Test}
import garanti/expect

pub fn to_be_equivalent_suite() {
  Suite("When combining matchers with all", [
    Test("it should fail on empty list", fn() {
      expect.all([])
      |> expect.to_be_equal(
        garanti.Fail("Cannot combine an empty list of matchers", []),
      )
    }),

    Test("it should unwrap a single passing result", fn() {
      expect.all([garanti.Pass])
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should unwrap a single failing result", fn() {
      expect.all([garanti.Fail("Bang", [garanti.Actual("x")])])
      |> expect.to_be_equal(garanti.Fail("Bang", [garanti.Actual("x")]))
    }),

    Test("it should pass when all pass", fn() {
      expect.all([garanti.Pass, garanti.Pass, garanti.Pass])
      |> expect.to_be_equal(garanti.Pass)
    }),

    Test("it should fail when some fail", fn() {
      expect.all([garanti.Pass, garanti.Pass, garanti.Fail("bummer", [])])
      |> expect.to_be_equal(
        garanti.Fail("A combined test failed:", [
          garanti.NestedTestFailure("bummer", []),
        ]),
      )
    }),

    Test("it should include all failures", fn() {
      expect.all([
        garanti.Pass,
        garanti.Pass,
        garanti.Fail("bummer", []),
        garanti.Fail("oh no", [garanti.Actual("13"), garanti.Expected("21")]),
      ])
      |> expect.to_be_equal(
        garanti.Fail("A combined test failed:", [
          garanti.NestedTestFailure("bummer", []),
          garanti.NestedTestFailure("oh no", [
            garanti.Actual("13"),
            garanti.Expected("21"),
          ]),
        ]),
      )
    }),
  ])
}
