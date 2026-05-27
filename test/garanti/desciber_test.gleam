import garanti.{Suite, Test}
import garanti/expect
import garanti/internal/describer
import garanti/internal/report.{Block, Enriched, Indent, Info, Message}
import gleam/list

pub fn describer_suite() {
  let result =
    describer.suite_results("TestSuite", [
      garanti.TestResult("test 1", garanti.Fail("Oh no!")),
      garanti.TestResult("test 2", garanti.Pass),
      garanti.TestResult("test 3", garanti.Fail("No, not me too...")),
    ])

  Suite("When describing test result", [
    Test("it should include the overall suite result as first element", fn() {
      use head <- expect.to_be_ok_then(list.first(result))

      head
      |> expect.to_be_equal(
        Message(Info, [
          Enriched("Suite", [report.Secondary]),
          Enriched("TestSuite", [report.Name]),
          Enriched("completed with", [report.Secondary]),
          Enriched("2", [report.Name]),
          Enriched("failure(s)", [report.Negative, report.Bold]),
        ]),
      )
    }),

    Test("it should include successul suite result", fn() {
      let successful_result =
        describer.suite_results("TestSuite", [
          garanti.TestResult("test 1", garanti.Pass),
          garanti.TestResult("test 2", garanti.Pass),
        ])

      use head <- expect.to_be_ok_then(list.first(successful_result))

      head
      |> expect.to_be_equal(
        Message(Info, [
          Enriched("Suite", [report.Secondary]),
          Enriched("TestSuite", [report.Name]),
          Enriched("completed", [report.Secondary]),
          Enriched("successfully", [report.Positive, report.Bold]),
          Enriched("with", [report.Secondary]),
          Enriched("2", [report.Name]),
          Enriched("test(s)", [report.Secondary]),
        ]),
      )
    }),

    Test("it should describe each test", fn() {
      use tail <- expect.to_be_ok_then(list.rest(result))

      tail
      |> expect.to_be_equal([
        Message(report.Error, [
          Indent,
          Enriched("Test", [report.Secondary]),
          Enriched("test 1", [report.Name]),
          Enriched("failed with:", [report.Negative, report.Bold]),
          Block("Oh no!"),
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
          Block("No, not me too..."),
        ]),
      ])
    }),
  ])
}
