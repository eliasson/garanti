import garanti.{type Suite}
import gleam/javascript/promise.{type Promise}

@external(javascript, "./discovery_ffi.mjs", "discover_all_suites")
pub fn discover_all_suites() -> Promise(List(Suite))

/// Calls `build` and returns its Suite. If `build` panics (e.g. a failed `let
/// assert` in setup code that runs before the Suite value is returned), the
/// panic is caught and a suite with a single failing test is returned instead.
@external(javascript, "./discovery_ffi.mjs", "attempt_suite")
pub fn attempt_suite(build: fn() -> Suite, label: String) -> Suite
