import garanti.{Suite, Test}
import garanti/internal/discovery
import garanti/support/tests
import gleam/list
import gleam/string
import gleeunit/should

pub fn it_should_return_no_warnings_for_proper_suites_test() {
  [
    Suite("Alpha", [Test("One", tests.passing_assert)]),
    Suite("Bravo", [Test("One", tests.passing_assert)]),
  ]
  |> discovery.analyse_suites()
  |> should.equal([])
}

pub fn it_should_identify_duplicate_suite_names_test() {
  [
    Suite("Alpha", [Test("One", tests.passing_assert)]),
    Suite("Alpha", [Test("One", tests.passing_assert)]),
  ]
  |> discovery.analyse_suites()
  |> should.equal([discovery.DuplicateSuiteName("Alpha")])
}

pub fn it_should_ignore_casing_when_identifying_duplicate_suite_names_test() {
  [
    Suite("ALPHA", [Test("One", tests.passing_assert)]),
    Suite("alpha", [Test("One", tests.passing_assert)]),
  ]
  |> discovery.analyse_suites()
  |> should.equal([discovery.DuplicateSuiteName("alpha")])
  // Ignore which term that is used, it is arbitrary.
}

pub fn it_should_identify_multiple_duplicate_suite_names_test() {
  [
    Suite("Alpha", [Test("One", tests.passing_assert)]),
    Suite("Bravo", [Test("One", tests.passing_assert)]),
    Suite("Charlie", [Test("One", tests.passing_assert)]),
    Suite("Bravo", [Test("One", tests.passing_assert)]),
    Suite("Alpha", [Test("One", tests.passing_assert)]),
  ]
  |> discovery.analyse_suites()
  |> list.sort(fn(a, b) { string.compare(a.suite_name, b.suite_name) })
  |> should.equal([
    discovery.DuplicateSuiteName("Alpha"),
    discovery.DuplicateSuiteName("Bravo"),
  ])
}
