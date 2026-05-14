import garanti
import garanti/expect
import gleam/option
import gleeunit/should

pub fn it_should_be_none_int_fail_test() {
  expect.to_be_none(option.Some(12))
  |> should.equal(garanti.Fail("Expected 12 to be None."))
}

pub fn it_should_be_none_pass_test() {
  expect.to_be_none(option.None)
  |> should.equal(garanti.Pass)
}

pub fn it_should_be_some_string_fail_test() {
  expect.to_be_none(option.Some("two"))
  |> should.equal(garanti.Fail("Expected \"two\" to be None."))
}
