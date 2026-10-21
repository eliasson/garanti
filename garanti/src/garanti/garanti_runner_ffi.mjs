export function exit_failure() {
  if (globalThis.Deno) {
    Deno.exitCode = 1;
  } else {
    process.exitCode = 1;
  }
}
