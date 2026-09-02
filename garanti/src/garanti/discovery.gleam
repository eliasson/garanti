@target(erlang)
import garanti.{type Suite, Suite, Test}

@target(erlang)
import gleam/list

@target(erlang)
import gleam/string

@target(javascript)
import garanti.{type Suite}

@target(javascript)
import gleam/javascript/promise.{type Promise}

@target(erlang)
pub type Export {
  Export(name: String, arity: Int)
}

@target(erlang)
@external(erlang, "discovery_ffi", "loaded_test_modules")
fn loaded_test_modules() -> List(String)

@target(erlang)
@external(erlang, "discovery_ffi", "module_exports")
fn module_exports(module_name: String) -> List(Export)

@target(erlang)
@external(erlang, "discovery_ffi", "apply_suite")
fn apply_suite(
  module_name: String,
  function_name: String,
) -> Result(Suite, String)

@target(erlang)
pub fn discover_all_suites() -> List(Suite) {
  loaded_test_modules()
  |> list.flat_map(discover_suites_in_module)
}

@target(erlang)
pub fn discover_suites_in_module(module_name: String) -> List(Suite) {
  module_exports(module_name)
  |> list.filter(fn(export) {
    export.arity == 0 && string.ends_with(export.name, "_suite")
  })
  |> list.map(fn(export) {
    case apply_suite(module_name, export.name) {
      Ok(suite) -> suite
      Error(reason) -> failed_suite(module_name, export.name, reason)
    }
  })
}

// Produce an on-the-fly suite to represent a panic during the suite discovery. The reason
// is whatever gets passed from the runtime (e.g. an Erlang stacktrace)/
@target(erlang)
fn failed_suite(
  module_name: String,
  function_name: String,
  reason: String,
) -> Suite {
  Suite(module_name <> "." <> function_name, [
    Test(function_name, fn() { garanti.Fail(reason, []) }),
  ])
}

@target(javascript)
@external(javascript, "./discovery_ffi.mjs", "discover_all_suites")
pub fn discover_all_suites() -> Promise(List(Suite))

@target(javascript)
/// Calls `build` and returns its Suite. If `build` panics (e.g. a failed `let
/// assert` in setup code that runs before the Suite value is returned), the
/// panic is caught and a suite with a single failing test is returned instead.
@external(javascript, "./discovery_ffi.mjs", "attempt_suite")
pub fn attempt_suite(build: fn() -> Suite, label: String) -> Suite
