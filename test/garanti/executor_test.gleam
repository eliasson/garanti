import garanti
import garanti/internal/executor
import gleeunit/should

pub fn it_should_pass_passing_test_test() {
  executor.run(fn() { garanti.Pass })
  |> should.equal(executor.Executed(garanti.Pass))
}

pub fn it_should_fail_failing_test_test() {
  executor.run(fn() { garanti.Fail("set up to fail") })
  |> should.equal(executor.Executed(garanti.Fail("set up to fail")))
}

pub fn it_should_fail_execution_for_paniciing_test_test() {
  executor.run(fn() { panic as "bad test" })
  |> should.equal(executor.ExecutionFailure("Unknown test failure"))
}
