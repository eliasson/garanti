import garanti.{type Suite, Suite, Test}
import garanti_erlang/internal/discovery_ffi
import gleam/list

import gleam/string

pub fn discover_all_suites() -> List(Suite) {
  discovery_ffi.loaded_test_modules()
  |> list.flat_map(discover_suites_in_module)
}

pub fn discover_suites_in_module(module_name: String) -> List(Suite) {
  discovery_ffi.module_exports(module_name)
  |> list.filter(fn(export) {
    export.arity == 0 && string.ends_with(export.name, "_suite")
  })
  |> list.map(fn(export) {
    case discovery_ffi.apply_suite(module_name, export.name) {
      Ok(suite) -> suite
      Error(reason) -> failed_suite(module_name, export.name, reason)
    }
  })
}

// Produce an on-the-fly suite to represent a panic during the suite discovery. The reason
// is whatever gets passed from the runtime (e.g. an Erlang stacktrace)/
fn failed_suite(
  module_name: String,
  function_name: String,
  reason: String,
) -> Suite {
  Suite(module_name <> "." <> function_name, [
    Test(function_name, fn() { garanti.Fail(reason, []) }),
  ])
}
