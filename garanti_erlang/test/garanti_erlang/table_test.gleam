import garanti.{Suite, Test}
import garanti/expect
import garanti/table
import gleam/int
import gleam/list

pub fn empty_table_suite() {
  let test_suite =
    garanti.Suite(
      "TestSuite",
      table.table([], fn(_) { "" }, fn(_) { garanti.Pass }),
    )

  Suite("Empty table input", [
    Test("should return zero tests", fn() {
      test_suite
      |> test_names
      |> expect.to_be_empty
    }),
  ])
}

pub fn table_suite() {
  let test_suite =
    garanti.Suite(
      "TestSuite",
      table.table([1, 2, 3], fn(n) { "Test " <> int.to_string(n) }, fn(_) {
        garanti.Pass
      }),
    )

  Suite("Test table input", [
    Test("should return tests with the computed names", fn() {
      test_suite
      |> test_names
      |> expect.to_be_equivalent(["Test 1", "Test 2", "Test 3"])
    }),
  ])
}

fn test_names(suite: garanti.Suite) -> List(String) {
  suite.tests
  |> list.map(fn(t) { t.name })
}
