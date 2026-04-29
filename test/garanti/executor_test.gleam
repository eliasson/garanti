import garanti
import garanti/internal/executor
import garanti/support/tests
import gleeunit/should

pub fn it_should_pass_passing_test_test() {
  executor.run(tests.passing)
  |> should.equal(executor.Executed(garanti.Pass))
}

pub fn it_should_fail_failing_test_test() {
  executor.run(tests.failing)
  |> should.equal(executor.Executed(garanti.Fail("set up to fail")))
}

pub fn it_should_fail_execution_for_paniciing_test_test() {
  executor.run(tests.panicking)
  |> should.equal(executor.ExecutionFailure("Unknown test failure"))
}
