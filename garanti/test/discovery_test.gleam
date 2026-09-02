@target(erlang)
import garanti.{Suite, Test}

@target(erlang)
import garanti/discovery

@target(javascript)
import garanti.{Suite, Test}

@target(javascript)
import garanti/discovery

import gleam/string

@target(erlang)
pub fn when_suite_setup_panics_suite() {
  // A bit meta, but this will discover a suite fixture that is setup to fail.
  let suites = discovery.discover_suites_in_module("support@panicking_fixture")

  Suite("When a suite panics during setup", [
    Test("it should have a single failing test in the suite", fn() {
      let assert [suite] = suites
      let assert [test_case] = suite.tests

      case test_case.run() {
        garanti.Fail(reason, []) -> {
          let correct = string.contains(reason, "setup was setup to fail!")
          case correct {
            True -> garanti.Pass
            False ->
              garanti.Fail(
                "Expected test case to fail with expected reason",
                [],
              )
          }
        }
        _ -> garanti.Fail("Expected test case to fail", [])
      }
    }),
  ])
}

@target(javascript)
pub fn when_suite_setup_panics_suite() {
  // Mimic an attempt to execute a sute that fails during setup.
  let suite =
    discovery.attempt_suite(
      fn() { panic as "setup was setup to fail!" },
      "broken_suite",
    )

  Suite("When a suite panics during setup", [
    Test("it should have a single failing test", fn() {
      let assert [test_case] = suite.tests

      case test_case.run() {
        garanti.Fail(reason, []) -> {
          let correct = string.contains(reason, "setup was setup to fail!")
          case correct {
            True -> garanti.Pass
            False ->
              garanti.Fail(
                "Expected test case to fail with expected reason",
                [],
              )
          }
        }
        _ -> garanti.Fail("Expected test case to fail", [])
      }
    }),
  ])
}
