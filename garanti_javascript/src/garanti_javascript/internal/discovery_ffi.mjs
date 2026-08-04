import { toList } from "../../gleam.mjs";
import { Suite, Test, Fail } from "../../../garanti/garanti.mjs";

//
// This FFI code is inspired by the way the official gleeunit performs its test discovery:
//
// https://github.com/lpil/gleeunit/blob/main/src/gleeunit_ffi.mjs

export async function discover_all_suites() {
  const suites = [];
  const packageName = await readRootPackageName();

  // The compiled output of the package consuming Garanti (relative to this file).
  const distUrl = new URL(`../../../${packageName}/`, import.meta.url);

  // Process all files under test directory to find our suites.
  for await (const gleamPath of gleamFiles("test")) {
    const jsPath = gleamPath.slice("test/".length).replace(/\.gleam$/, ".mjs");

    // Resolve the compiled module against the build directory and import it.
    const moduleUrl = new URL(jsPath, distUrl);
    const module = await import(moduleUrl.href);

    // Identify any exported function using the suffix _suite. These are assumed to take
    // zero arguments.
    for (const exportName of Object.keys(module)) {
      if (!exportName.endsWith("_suite")) continue;

      // Suite must be a function.
      const candidate = module[exportName];
      if (typeof candidate !== "function" || candidate.length !== 0) continue;

      // Attemtp to execute the suite (not the tests).
      suites.push(attempt_suite(candidate, `${jsPath}.${exportName}`));
    }
  }

  return toList(suites);
}

// Try to execute the suite, if that fails during setup / discovery catch it and return
// an on-the-fly generated suite with that failure.
export function attempt_suite(candidate, label) {
  try {
    return candidate();
  } catch (error) {
    const reason = error instanceof Error ? error.message : String(error);
    return new Suite(
      label,
      toList([new Test(label, () => new Fail(reason, toList([])))]),
    );
  }
}

/** Read the name of the package that consumes the garanti library. */
async function readRootPackageName() {
  const toml = await readTextFile("gleam.toml");
  for (const line of toml.split("\n")) {
    const matches = line.match(/\s*name\s*=\s*"([a-z][a-z0-9_]*)"/);
    if (matches) return matches[1];
  }
  throw new Error("Could not determine package name from gleam.toml");
}

/** Recursively yield every `*.gleam` file under `directory`. */
async function* gleamFiles(directory) {
  for (const entry of await readDir(directory)) {
    const path = joinPath(directory, entry);
    if (path.endsWith(".gleam")) {
      yield path;
    } else {
      try {
        yield* gleamFiles(path);
      } catch {
        // Ignore
      }
    }
  }
}

async function readDir(path) {
  if (globalThis.Deno) {
    const items = [];
    for await (const item of Deno.readDir(path)) {
      items.push(item.name);
    }
    return items;
  } else {
    const { readdir } = await import("node:fs/promises");
    return readdir(path);
  }
}

async function readTextFile(path) {
  if (globalThis.Deno) {
    return Deno.readTextFile(path);
  } else {
    const { readFile } = await import("node:fs/promises");
    return (await readFile(path)).toString();
  }
}

function joinPath(a, b) {
  return a.endsWith("/") ? a + b : a + "/" + b;
}
