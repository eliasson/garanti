import garanti
import garanti/internal/suite
import garanti/support/suite_matcher
import garanti/support/suite_probe
import garanti/support/tests
import gleeunit/should

pub fn it_should_pass_suite_with_three_passing_tests_test() {
  // Create the probe so that we have something that receives messages
  // from the suite. We need this to assert that it completed.
  let probe = suite_probe.new()

  let test_suite =
    garanti.Suite("TestSuite", [
      tests.passing_test("Alpha"),
      tests.passing_test("Bravo"),
      tests.passing_test("Charlie"),
    ])

  // Start the suite runner actor.
  let assert Ok(_) = suite.start(test_suite, probe.subject)

  suite_probe.receive_result(probe)
  |> should.be_ok
  |> suite_matcher.have_suite_name("TestSuite")
  |> suite_matcher.have_completed_tests(3)
}
