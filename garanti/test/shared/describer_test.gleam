import garanti.{Suite, Test}
import garanti/expect
import garanti/shared/describer
import garanti/shared/report.{Enriched, Error, Indent, Info, Message, NewLine}
import gleam/list

pub fn run_summary_suite() {
  Suite("When describing run summary", [
    Test("it should report all passed when there are no failures", fn() {
      describer.run_summary(10, 0)
      |> expect.to_be_equal(
        Message(report.Success, [
          Enriched("All", [report.Secondary]),
          Enriched("10", [report.Name]),
          Enriched("test(s) passed!", [report.Positive, report.Bold]),
        ]),
      )
    }),
    Test("it should report the number of failures when some tests failed", fn() {
      describer.run_summary(10, 3)
      |> expect.to_be_equal(
        Message(report.Error, [
          Enriched("3", [report.Name]),
          Enriched("of", [report.Secondary]),
          Enriched("10", [report.Name]),
          Enriched("test(s) failed.", [report.Negative, report.Bold]),
        ]),
      )
    }),
  ])
}

pub fn describer_suite() {
  let result =
    describer.suite_results("TestSuite", [
      garanti.TestResult("test 1", garanti.Fail("Oh no!", [])),
      garanti.TestResult("test 2", garanti.Pass),
      garanti.TestResult("test 3", garanti.Fail("No, not me too...", [])),
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
          report.NewLine,
          Indent,
          Indent,
          Enriched("Oh no!", [report.Name]),
          report.NewLine,
        ]),
        Message(Info, [
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
          report.NewLine,
          Indent,
          Indent,
          Enriched("No, not me too...", [report.Name]),
          report.NewLine,
        ]),
      ])
    }),
  ])
}

pub fn describe_nested_failure_suite() {
  let result =
    describer.suite_results("TestSuite", [
      garanti.TestResult(
        "Nested Test",
        garanti.Fail("Outer", [
          garanti.NestedTestFailure("inner A", []),
          garanti.NestedTestFailure("inner B", [
            garanti.Actual("foo"),
            garanti.Expected("bar"),
          ]),
        ]),
      ),
    ])

  Suite("When describing a nested test result", [
    Test("it should include both failures", fn() {
      use tail <- expect.to_be_ok_then(list.rest(result))

      tail
      |> expect.to_be_equal([
        Message(report.Error, [
          report.Indent,
          report.Enriched("Test", [report.Secondary]),
          report.Enriched("Nested Test", [report.Name]),
          report.Enriched("failed with:", [report.Negative, report.Bold]),
          report.NewLine,
          report.Indent,
          report.Indent,
          report.Enriched("Outer", [report.Name]),
          report.NewLine,
          report.Indent,
          report.Indent,
          report.Indent,
          report.Enriched("inner A", [report.Bold]),
          report.NewLine,
          report.Indent,
          report.Indent,
          report.Indent,
          report.Enriched("inner B", [report.Bold]),
          report.NewLine,
          report.Indent,
          report.Indent,
          report.Indent,
          report.Indent,
          report.Enriched("Actual: ", [report.Bold]),
          report.Enriched("foo", [report.Negative, report.Bold]),
          report.NewLine,
          report.Indent,
          report.Indent,
          report.Indent,
          report.Indent,
          report.Enriched("Expected: ", [report.Bold]),
          report.Enriched("bar", [report.Positive, report.Bold]),
          report.NewLine,
        ]),
      ])
    }),
  ])
}

pub fn failures_summary_suite() {
  Suite("When describing the failures summary", [
    Test("it should be empty when there are no failures", fn() {
      describer.failures_summary([])
      |> expect.to_be_empty
    }),

    Test("it should not include passing tests", fn() {
      describer.failures_summary([
        #("TestSuite", garanti.TestResult("test 1", garanti.Pass)),
      ])
      |> expect.to_be_empty
    }),

    Test("it should start with a header when there are failures", fn() {
      use head <- expect.to_be_ok_then(
        list.first(
          describer.failures_summary([
            #(
              "TestSuite",
              garanti.TestResult("test 1", garanti.Fail("Oh no!", [])),
            ),
          ]),
        ),
      )

      head
      |> expect.to_be_equal(
        Message(Error, [
          NewLine,
          Enriched("Failures:", [report.Negative, report.Bold]),
        ]),
      )
    }),

    Test("it should list each failure with its suite name", fn() {
      use tail <- expect.to_be_ok_then(
        list.rest(
          describer.failures_summary([
            #(
              "Suite A",
              garanti.TestResult("test 1", garanti.Fail("Oh no!", [])),
            ),
            #("Suite B", garanti.TestResult("test 2", garanti.Timeout)),
          ]),
        ),
      )

      tail
      |> expect.to_be_equal([
        Message(Error, [
          Indent,
          Enriched("Suite", [report.Secondary]),
          Enriched("Suite A", [report.Name]),
          NewLine,
          Indent,
          Indent,
          Enriched("Test", [report.Secondary]),
          Enriched("test 1", [report.Name]),
          Enriched("failed with:", [report.Negative, report.Bold]),
          NewLine,
          Indent,
          Indent,
          Indent,
          Enriched("Oh no!", [report.Name]),
          NewLine,
        ]),
        Message(Info, [
          Indent,
          Enriched("Suite", [report.Secondary]),
          Enriched("Suite B", [report.Name]),
          Enriched("Test", [report.Secondary]),
          Enriched("test 2", [report.Name]),
          Enriched("timed out", [report.Negative, report.Bold]),
        ]),
      ])
    }),
  ])
}
