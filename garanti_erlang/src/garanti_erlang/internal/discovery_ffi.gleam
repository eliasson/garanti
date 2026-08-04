import garanti.{type Suite}

pub type Export {
  Export(name: String, arity: Int)
}

@external(erlang, "discovery_ffi", "loaded_test_modules")
pub fn loaded_test_modules() -> List(String)

@external(erlang, "discovery_ffi", "module_exports")
pub fn module_exports(module_name: String) -> List(Export)

@external(erlang, "discovery_ffi", "apply_suite")
pub fn apply_suite(
  module_name: String,
  function_name: String,
) -> Result(Suite, String)
