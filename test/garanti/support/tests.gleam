import garanti

/// An always passing test.
pub fn passing() -> garanti.AssertionResult {
  garanti.Pass
}

/// An always failing test.
pub fn failing() -> garanti.AssertionResult {
  garanti.Fail("set up to fail")
}

/// An always panicking test.
pub fn panicking() -> garanti.AssertionResult {
  panic as "bad test"
}
