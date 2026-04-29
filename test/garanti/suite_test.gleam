import garanti
import garanti/internal/suite
import garanti/support/suite_probe
import gleeunit/should

pub fn it_should_pass_suite_with_three_passing_tests_test() {
  // Create the probe so that we have something that receives messages
  // from the suite. We need this to assert that it completed.
  let probe = suite_probe.new()

  let test_suite = garanti.Suite("TestSuite")

  // Start the suite runner actor.
  let assert Ok(_) = suite.start(test_suite, probe.subject)

  // We expect the named suite to be complete.
  let expected = garanti.SuiteComplete("TestSuite", [])

  suite_probe.receive_result(probe)
  |> should.be_ok
  |> should.equal(expected)
}
