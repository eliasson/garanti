import garanti.{FocusedSuite, Suite, Test}
import garanti/expect
import garanti/shared/focus
import garanti_erlang/support/tests
import gleam/list

pub fn filtering_focused_suites_suite() {
  Suite("Filtering focused suites", [
    Test("it should return all suites when none are focused", fn() {
      let suites = [
        Suite("Alpha", [tests.passing_test("One")]),
        Suite("Bravo", [tests.passing_test("One")]),
      ]

      suites
      |> focus.filter_focused()
      |> suite_names
      |> expect.to_be_equal(["Alpha", "Bravo"])
    }),

    Test("it should return only the focused suite", fn() {
      let suites = [
        Suite("Alpha", [tests.passing_test("One")]),
        FocusedSuite("Bravo", [tests.passing_test("One")]),
        Suite("Charlie", [tests.passing_test("One")]),
      ]

      suites
      |> focus.filter_focused()
      |> suite_names
      |> expect.to_be_equal(["Bravo"])
    }),

    Test("it should return all focused suites", fn() {
      let suites = [
        FocusedSuite("Alpha", [tests.passing_test("One")]),
        Suite("Bravo", [tests.passing_test("One")]),
        FocusedSuite("Charlie", [tests.passing_test("One")]),
      ]

      suites
      |> focus.filter_focused()
      |> suite_names
      |> expect.to_be_equal(["Alpha", "Charlie"])
    }),

    Test("it should return an empty list when no suites", fn() {
      []
      |> focus.filter_focused()
      |> expect.to_be_equal([])
    }),
  ])
}

pub fn detecting_a_focused_run_suite() {
  Suite("Detecting a focused run", [
    Test("it should be false when no suites are focused", fn() {
      [
        Suite("Alpha", []),
        Suite("Bravo", []),
      ]
      |> focus.is_focused_run()
      |> expect.to_be_equal(False)
    }),

    Test("it should be true when a suite is focused", fn() {
      [
        Suite("Alpha", []),
        FocusedSuite("Bravo", []),
      ]
      |> focus.is_focused_run()
      |> expect.to_be_equal(True)
    }),
  ])
}

fn suite_names(suites: List(garanti.Suite)) -> List(String) {
  list.map(suites, fn(s) { s.name })
}
