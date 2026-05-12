import garanti
import garanti/expect
import gleeunit/should

pub fn it_should_be_equivalent_pass_ordered_int_test() {
  expect.to_be_equivalent([1, 2, 3], [1, 2, 3])
  |> should.equal(garanti.Pass)
}

pub fn it_should_be_equivalent_pass_unordered_int_test() {
  expect.to_be_equivalent([3, 1, 2], [2, 3, 1])
  |> should.equal(garanti.Pass)
}

pub fn it_should_be_equivalent_fail_when_actual_is_empty_test() {
  expect.to_be_equivalent([], [1, 2])
  |> should.equal(garanti.Fail("Actual value is missing element(s) [1, 2]"))
}

pub fn it_should_be_equivalent_fail_when_expected_is_empty_test() {
  expect.to_be_equivalent([1, 2], [])
  |> should.equal(garanti.Fail("Actual value has extra element(s) [1, 2]"))
}

pub fn it_should_be_equivalent_fail_when_actual_is_missing_some_test() {
  expect.to_be_equivalent([1], [1, 2])
  |> should.equal(garanti.Fail("Actual value is missing element(s) [2]"))
}

pub fn it_should_be_equivalent_fail_when_actual_has_some_extra_test() {
  expect.to_be_equivalent([1, 2, 3], [1, 3])
  |> should.equal(garanti.Fail("Actual value has extra element(s) [2]"))
}

pub fn it_should_be_equivalent_fail_when_actual_has_duplicate_test() {
  expect.to_be_equivalent([1, 1, 1], [1, 1])
  |> should.equal(garanti.Fail("Actual value has extra element(s) [1]"))
}

pub fn it_should_be_equivalent_fail_when_expected_has_duplicate_test() {
  expect.to_be_equivalent([1, 1], [1, 1, 1])
  |> should.equal(garanti.Fail("Actual value is missing element(s) [1]"))
}

pub fn it_should_be_equivalent_string_pass_test() {
  expect.to_be_equivalent(["Boys Don't Cry", "A Forest"], [
    "A Forest",
    "Boys Don't Cry",
  ])
  |> should.equal(garanti.Pass)
}

pub fn it_should_be_equivalent_string_fail_test() {
  expect.to_be_equivalent(["Boys Don't Cry", "A Forest"], [
    "A Forest",
    "Atmosphere",
  ])
  |> should.equal(garanti.Fail(
    "Actual value is missing element(s) [\"Atmosphere\"] and has extra element(s) [\"Boys Don't Cry\"]",
  ))
}
