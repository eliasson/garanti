//// Garanti is a test runner and matcher library.

/// Result for a single test assertion.
pub type AssertionResult {
  /// The test passed, the assertion(s) was fulfilled.
  Pass
  /// A failed test with the list of expectations detailing what is not as expected.
  Fail(summary: String, expectations: List(Expectation))
  Timeout
}

/// The expectation reported by a matcher as part of the `AssertionResult`. Used to give
/// semantic meaning to a failure in order to display it more clearly.
pub type Expectation {
  /// The expected value described as a string.
  Expected(String)
  /// The actual value described as a string.
  Actual(String)
  /// The value NOT expected described as a string.
  NotExpected(String)
}

/// Test did not finish executing within the maximum allowed time slot.
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
