import garanti
import garanti/internal/describer
import garanti/internal/report.{Info, Message, Plain, important, negative}
import gleam/list
import gleeunit/should

pub fn it_should_describe_test_result_test() {
  describer.suite_results("TestSuite", [
    garanti.TestResult("test", garanti.Pass),
  ])
  |> list.first
  |> should.be_ok
  |> should.equal(
    Message(Info, [
      Plain("Suite"),
      important("TestSuite"),
      Plain("comleted with"),
      important("1 of 1"),
      Plain("test(s) passed"),
    ]),
  )
}

pub fn it_should_describe_failing_test_result_test() {
  describer.suite_results("TestSuite", [
    garanti.TestResult("test 1", garanti.Pass),
    garanti.TestResult("test 2", garanti.Fail("Oh no")),
  ])
  |> list.first
  |> should.be_ok
  |> should.equal(
    Message(Info, [
      Plain("Suite"),
      important("TestSuite"),
      Plain("comleted with"),
      important("1 of 2"),
      Plain("test(s) passed"),
    ]),
  )
}

pub fn it_should_describe_each_failing_test() {
  describer.suite_results("TestSuite", [
    garanti.TestResult("test 1", garanti.Fail("Oh no!")),
    garanti.TestResult("test 2", garanti.Pass),
    garanti.TestResult("test 3", garanti.Fail("No, not me too...")),
  ])
  |> list.rest
  |> should.be_ok
  |> should.equal([
    Message(report.Error, [
      important("test 1"),
      negative("failed with:"),
      Plain("Oh no!"),
    ]),
    Message(report.Error, [
      important("test 3"),
      negative("failed with:"),
      Plain("No, not me too..."),
    ]),
  ])
}
