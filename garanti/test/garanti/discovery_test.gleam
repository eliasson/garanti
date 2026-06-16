import garanti.{Suite, Test}
import garanti/expect
import garanti/internal/discovery
import garanti/support/tests
import gleam/list
import gleam/string

pub fn when_analysing_suites_suite() {
  Suite("When analysing suties", [
    Test("it should return no warnings for well defined suites", fn() {
      [
        Suite("Alpha", [Test("One", tests.passing_assert)]),
        Suite("Bravo", [Test("One", tests.passing_assert)]),
      ]
      |> discovery.analyse_suites()
      |> expect.to_be_equal([])
    }),

    Test("it should identify duplicate suite names", fn() {
      [
        Suite("Alpha", [Test("One", tests.passing_assert)]),
        Suite("Alpha", [Test("One", tests.passing_assert)]),
      ]
      |> discovery.analyse_suites()
      |> expect.to_be_equal([discovery.DuplicateSuiteName("Alpha")])
    }),

    Test("it should ignore casing when identifying duplicate suite", fn() {
      [
        Suite("ALPHA", [Test("One", tests.passing_assert)]),
        Suite("alpha", [Test("One", tests.passing_assert)]),
      ]
      |> discovery.analyse_suites()
      |> expect.to_be_equal([discovery.DuplicateSuiteName("alpha")])
    }),

    Test("it should identify multiple duplicates suite names", fn() {
      [
        Suite("Alpha", [Test("One", tests.passing_assert)]),
        Suite("Bravo", [Test("One", tests.passing_assert)]),
        Suite("Charlie", [Test("One", tests.passing_assert)]),
        Suite("Bravo", [Test("One", tests.passing_assert)]),
        Suite("Alpha", [Test("One", tests.passing_assert)]),
      ]
      |> discovery.analyse_suites()
      |> list.sort(fn(a, b) { string.compare(a.suite_name, b.suite_name) })
      |> expect.to_be_equal([
        discovery.DuplicateSuiteName("Alpha"),
        discovery.DuplicateSuiteName("Bravo"),
      ])
    }),

    Test("it should identify empty suites", fn() {
      [
        Suite("Alpha", []),
        Suite("Bravo", []),
        Suite("Charlie", [Test("One", tests.passing_assert)]),
      ]
      |> discovery.analyse_suites()
      |> list.sort(fn(a, b) { string.compare(a.suite_name, b.suite_name) })
      |> expect.to_be_equal([
        discovery.EmptySuite("Alpha"),
        discovery.EmptySuite("Bravo"),
      ])
    }),
  ])
}
