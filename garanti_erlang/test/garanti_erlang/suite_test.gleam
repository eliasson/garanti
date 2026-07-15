import garanti.{Suite, Test}
import garanti/expect
import garanti_erlang/internal/suite
import garanti_erlang/support/suite_matcher
import garanti_erlang/support/suite_probe
import garanti_erlang/support/tests
import gleam/erlang/process

pub fn successful_suite_suite() {
  let test_suite =
    garanti.Suite("TestSuite", [
      tests.passing_test("Alpha"),
      tests.passing_test("Bravo"),
      tests.passing_test("Charlie"),
    ])

  // Create the probe so that we have something that receives messages
  // from the suite. We need this to assert that it completed.
  let probe = suite_probe.new()
  let assert Ok(_) = suite.start(test_suite, probe.subject)
  let maybe_result = suite_probe.receive_result(probe)

  Suite("When suite is successful", [
    Test("it should have 3 completed tests", fn() {
      use result <- expect.to_be_ok_then(maybe_result)
      result
      |> suite_matcher.have_completed_tests(3)
    }),

    Test("it should have 3 passed tests", fn() {
      use result <- expect.to_be_ok_then(maybe_result)
      result
      |> suite_matcher.have_passing_tests(3)
    }),

    Test("it should have 0 failing tests", fn() {
      use result <- expect.to_be_ok_then(maybe_result)
      result
      |> suite_matcher.have_failing_tests(0)
    }),
  ])
}

pub fn failing_suite_suite() {
  let probe = suite_probe.new()
  let test_suite = garanti.Suite("TestSuite", [tests.failing_test()])
  let assert Ok(_) = suite.start(test_suite, probe.subject)
  let maybe_result = suite_probe.receive_result(probe)

  Suite("When suite is failing", [
    Test("it should have 1 completed tests", fn() {
      use result <- expect.to_be_ok_then(maybe_result)
      result
      |> suite_matcher.have_completed_tests(1)
    }),

    Test("it should have 0 passed tests", fn() {
      use result <- expect.to_be_ok_then(maybe_result)
      result
      |> suite_matcher.have_passing_tests(0)
    }),

    Test("it should have 1 failing tests", fn() {
      use result <- expect.to_be_ok_then(maybe_result)
      result
      |> suite_matcher.have_failing_tests(1)
    }),
  ])
}

pub fn canceled_suite_suite() {
  let probe = suite_probe.new()

  let test_suite =
    garanti.Suite("TestSuite", [
      tests.sleeping_test(10_000),
    ])

  let assert Ok(actor_subject) = suite.start(test_suite, probe.subject)
  process.send(actor_subject.data, suite.CancelSuite)
  let maybe_result = suite_probe.receive_result(probe)

  Suite("When sutie is cancelled", [
    Test("it should have been cancelled", fn() {
      use result <- expect.to_be_ok_then(maybe_result)

      case result {
        garanti.SuiteComplete(..) ->
          garanti.Fail("Test suite  was not cancelled")

        garanti.SuiteCancelled(..) -> garanti.Pass
      }
    }),
  ])
}
