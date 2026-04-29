import garanti

/// An always passing assert.
pub fn passing_assert() -> garanti.AssertionResult {
  garanti.Pass
}

/// An always failing assert.
pub fn failing_assert() -> garanti.AssertionResult {
  garanti.Fail("set up to fail")
}

/// An always panicking assert.
pub fn panicking_assert() -> garanti.AssertionResult {
  panic as "bad test"
}
