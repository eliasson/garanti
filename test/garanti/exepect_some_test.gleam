import garanti
import garanti/expect
import gleam/option
import gleeunit/should

pub fn it_should_be_some_int_pass_test() {
  expect.to_be_some(option.Some(12), 12)
  |> should.equal(garanti.Pass)
}

pub fn it_should_be_some_none_fail_test() {
  expect.to_be_some(option.None, 12)
  |> should.equal(garanti.Fail("Expected None to be Some of 12."))
}

pub fn it_should_be_some_string_fail_test() {
  expect.to_be_some(option.Some("one"), "two")
  |> should.equal(garanti.Fail(
    "Expected Some of \"one\" to be Some of \"two\".",
  ))
}
