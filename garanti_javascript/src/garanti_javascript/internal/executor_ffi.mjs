import { Ok, Error } from "../../gleam.mjs";

// Run the test function without raising an exception (to not abort a test run). This
// is similar to the Erlang executor (garanti_erlang/src/internal/executor_ffi.erl).
export function run_catching(testFn) {
  try {
    return new Ok(testFn());
  }
  catch (_error) {
    return new Error(undefined);
  }
}
