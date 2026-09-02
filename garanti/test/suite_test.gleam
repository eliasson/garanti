import garanti.{Suite, Test}
import garanti/expect
import garanti/internal/suite
import support/tests

pub fn suite_suite() {
  Suite("When running a suite", [
    Test("it should run all tests and report their results", fn() {
      let test_suite =
        garanti.Suite("TestSuite", [
          tests.passing_test("Alpha"),
          tests.failing_test(),
        ])

      suite.run(test_suite)
      |> expect.to_be_equal(
        garanti.SuiteComplete("TestSuite", [
          garanti.TestResult("Alpha", garanti.Pass),
          garanti.TestResult(
            "Failing tests",
            garanti.Fail("set up to fail", []),
          ),
        ]),
      )
    }),
  ])
}
