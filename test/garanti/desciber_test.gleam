import garanti
import garanti/internal/describer
import gleam/list
import gleeunit/should

pub fn it_should_describe_test_result_test() {
  describer.suite_results("TestSuite", [
    garanti.TestResult("test", garanti.Pass),
  ])
  |> list.first
  |> should.be_ok
  |> should.equal("Suite TestSuite completed (1 of 1 passed)")
}

pub fn it_should_describe_failing_test_result_test() {
  describer.suite_results("TestSuite", [
    garanti.TestResult("test 1", garanti.Pass),
    garanti.TestResult("test 2", garanti.Fail("Oh no")),
  ])
  |> list.first
  |> should.be_ok
  |> should.equal("Suite TestSuite completed (1 of 2 passed)")
}
