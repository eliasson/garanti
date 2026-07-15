import garanti.{type Suite}
import garanti_erlang/internal/discovery_ffi
import gleam/list

import gleam/string

pub fn discover_all_suites() -> List(Suite) {
  discovery_ffi.loaded_test_modules()
  |> list.flat_map(discover_suites_in_module)
}

fn discover_suites_in_module(module_name: String) -> List(Suite) {
  discovery_ffi.module_exports(module_name)
  |> list.filter(fn(export) {
    export.arity == 0 && string.ends_with(export.name, "_suite")
  })
  |> list.map(fn(export) { discovery_ffi.apply_suite(module_name, export.name) })
}
