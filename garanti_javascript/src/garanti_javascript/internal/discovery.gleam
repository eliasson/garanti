import garanti.{type Suite}
import gleam/javascript/promise.{type Promise}

@external(javascript, "./discovery_ffi.mjs", "discover_all_suites")
pub fn discover_all_suites() -> Promise(List(Suite))
