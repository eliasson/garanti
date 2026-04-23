//// Garanti is a test runner and matcher library.

/// Result for a single test assertion.
pub type AssertionResult {
  /// The test passed, the assertion(s) was fulfilled.
  Pass
  /// The test failed, one or more assertion(s) was NOT fulfilled.
  Fail(String)
}
