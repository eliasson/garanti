import garanti
import garanti/internal/describer
import garanti/internal/report.{Enriched, Indent, Info, Message, Plain}
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
      Enriched("Suite", [report.Secondary]),
      Enriched("TestSuite", [report.Name]),
      Enriched("completed with", [report.Secondary]),
      Enriched("1 of 1", [report.Name]),
      Enriched("test(s) passed", [report.Secondary]),
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
      Enriched("Suite", [report.Secondary]),
      Enriched("TestSuite", [report.Name]),
      Enriched("completed with", [report.Secondary]),
      Enriched("1 of 2", [report.Name]),
      Enriched("test(s) passed", [report.Secondary]),
    ]),
  )
}

pub fn it_should_describe_each_test() {
  describer.suite_results("TestSuite", [
    garanti.TestResult("test 1", garanti.Fail("Oh no!")),
    garanti.TestResult("test 2", garanti.Pass),
    garanti.TestResult("test 3", garanti.Fail("No, not me too...")),
  ])
  |> list.rest
  |> should.be_ok
  |> should.equal([
    Message(report.Error, [
      Indent,
      Enriched("Test", [report.Secondary]),
      Enriched("test 1", [report.Name]),
      Enriched("failed with:", [report.Negative, report.Bold]),
      Plain("Oh no!"),
    ]),
    Message(report.Info, [
      Indent,
      Enriched("Test", [report.Secondary]),
      Enriched("test 2", [report.Name]),
      Enriched("completed", [report.Secondary]),
      Enriched("successfully", [report.Positive, report.Bold]),
    ]),
    Message(report.Error, [
      Indent,
      Enriched("Test", [report.Secondary]),
      Enriched("test 3", [report.Name]),
      Enriched("failed with:", [report.Negative, report.Bold]),
      Plain("No, not me too..."),
    ]),
  ])
}
