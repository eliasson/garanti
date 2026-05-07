import garanti
import garanti/expect
import gleeunit/should

pub fn it_should_be_equal_int_pass_test() {
  expect.to_be_equal(12, 12)
  |> should.equal(garanti.Pass)
}

pub fn it_should_be_equal_string_pass_test() {
  expect.to_be_equal("abrakadabra", "abrakadabra")
  |> should.equal(garanti.Pass)
}

pub fn it_should_be_equal_int_fail_test() {
  expect.to_be_equal(12, 22)
  |> should.equal(garanti.Fail("Expected 12 to equal 22."))
}

pub fn it_should_be_equal_string_fail_test() {
  expect.to_be_equal("abrakadabra", "simsalabim")
  |> should.equal(garanti.Fail(
    "Expected \"abrakadabra\" to equal \"simsalabim\".",
  ))
}

pub fn it_should_not_be_equal_int_pass_test() {
  expect.to_not_be_equal(12, 44)
  |> should.equal(garanti.Pass)
}

pub fn it_should_not_be_equal_string_pass_test() {
  expect.to_not_be_equal("Abba", "Queen")
  |> should.equal(garanti.Pass)
}

pub fn it_should_not_be_equal_int_fail_test() {
  expect.to_not_be_equal(12, 12)
  |> should.equal(garanti.Fail("Expected 12 to NOT equal 12."))
}

pub fn it_should_not_be_equal_string_fail_test() {
  expect.to_not_be_equal("Abba", "Abba")
  |> should.equal(garanti.Fail("Expected \"Abba\" to NOT equal \"Abba\"."))
}
