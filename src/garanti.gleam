//// Garanti is a test runner and matcher library.

/// Result for a single test assertion.
pub type AssertionResult {
  /// The test passed, the assertion(s) was fulfilled.
  Pass
  /// The test failed, one or more assertion(s) was NOT fulfilled.
  Fail(String)
}

/// The top level structure for any tests is a suite. All tests must belong to ONE suite,
/// there are no free-form tests.
pub type Suite {
  Suite(name: String, tests: List(Test))
}

pub type Test {
  /// A standard named tests with a parameter-less function that is the test.
  Test(name: String, run: fn() -> AssertionResult)
}

pub type SuiteResult {
  // TODO
  // - Should suites be identified by something other than name?
  // - Do we need uniqueness among suite names?
  SuiteComplete(suite_name: String, results: List(TestResult))
  SuiteCancelled(suite_name: String)
}

pub type TestResult {
  TestResult(name: String, result: AssertionResult)
}

/// The different levels of logging output that Garanti generates.
pub type LogLevel {
  Error
  Warning
  Info
  Debug
}
