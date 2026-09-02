# Garanti

[![Package Version](https://img.shields.io/hexpm/v/garanti)](https://hex.pm/packages/garanti)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/garanti)

Garanti is a Gleam test framework built around suites, tests and readable failure messages.

```gleam
import example
import garanti.{type Suite, Suite, Test}
import garanti/expect

pub fn math_suite() -> Suite {
  Suite("math", [
    Test("should add two numbers", fn() {
      example.add(2, 2)
      |> expect.to_be_equal(4)
    }),

    Test("should divide by two", fn() {
      use result <- expect.to_be_ok_then(example.divide(4, 2))
      expect.to_be_equal(result, 2)
    }),

    Test("should not divide by zero", fn() {
      use result <- expect.to_be_error_then(example.divide(4, 0))
      expect.to_be_equal(result, Nil)
    }),
  ])
}
```

## Why

Writing tests in Gleam today using `gleeunit` is a pretty barebone solution, which is fine, since it is the default. But I want something more similar to what I am used to in other languages.

Core concepts:

- Each test returns its result, a value. This can be a pass, a failure, or a timeout.
- Tests are also just values, organised into suites. This enables tests to share test setup or to have small local helpers.
- Matchers are just convenience functions that produce assertions.

There are built in runners for both Erlang and JavaScript targets, these run non-preemptive and synchronous. If you want parallelism and isolated test execution there is a specific Erlang runner that provides that without modifying any test, just by specifying a different runner.

I have written about the design of Garanti on my blog. There is no need to read it in order to use the library, but
if you are curious about what is [under the hood of a Gleam test framework](https://markuseliasson.se/article/under-the-hood-of-a-gleam-test-framework) it has all the details.

## Installation

1. Add `garanti` to your `gleam.toml` as a dev-dependency:

```bash
gleam add garanti --dev
```

2. Set your test entrypoint to call the runner:

```gleam
// test/my_project_test.gleam
import garanti
import garanti/runner

pub fn main() {
  runner.run(garanti.Info)
}
```

That's it - this works unchanged whether your project targets Erlang, JavaScript, or cross-compiles to both. No extra runner dependency is required by default.

### Choosing a runner

Garanti has two runners:

- **`garanti/runner`** - the default, included in `garanti` itself. Suites and tests run sequentially, in the same process, on either target. No timeouts, no isolation, no extra dependencies. If your project is a multi-target project, this is your only option.
- **`garanti_erlang`** (opt-in, Erlang-only) - runs every test in its own process and every suite in parallel. Tests timing out or panicking will be reported as failures instead of crashing the whole run. If you only target Erlang and already use specific dependencies for that, this is the better runner.

If you prefer the Erlang backed runner, you need to add a separate dependency:

```bash
gleam add garanti_erlang --dev
```

And then update your test file to use this runner:

```gleam
// test/my_project_test.gleam
import garanti
import garanti_erlang/runner // <-- this is the thing.

pub fn main() -> Nil {
  runner.run(garanti.Info)
}
```

## Writing tests

All tests belong to a suite. A suite is any function ending in `_suite` and that returns a `garanti.Suite`.

Each test is a function that returns `garanti.AssertionResult`:

```gleam
pub type AssertionResult {
  Pass
  Fail(summary: String, expectations: List(Expectation))
  Timeout
}
```

You can return `garanti.Pass` or `garanti.Fail("message", [])` directly, or use the `expect` module, which builds both the summary and the structured `Expectation`s for you.

```gleam
import example
import garanti.{type Suite, Suite, Test}
import garanti/expect

pub fn math_suite() -> Suite {
  Suite("math", [
    Test("should add two numbers", fn() {
      example.add(2, 2)
      |> expect.to_be_equal(4)
    })
  ])
}
```

## Table-driven tests

If you have a sequence of inputs you want to test you can use the `garanti/table` module. Each of the given inputs
will be reported individually like separate tests.

```gleam
import garanti.{type Suite, Suite}
import garanti/expect
import garanti/table
import gleam/int

pub fn math_suite() -> Suite {
  let inputs = [#(1, 1, 2), #(2, 2, 4), #(3, 3, 6)]

  Suite(
    "math",
    table.table(
      // The list of inputs.
      inputs,
      // A function that returns a string describing the test.
      fn(i) { "add " <> int.to_string(i.0) <> " and " <> int.to_string(i.1) },
      // The actual test, providing a garanti.AssertionResult.
      fn(i) { example.add(i.0, i.1) |> expect.to_be_equal(i.2) },
    ),
  )
}
```

Note, thanks to Garanti's philosophy that a `garanti.Test` is just a value, the table feature could just as well
have been a function in the consuming package. You should use this strength to build your own, application specific,
helpers.

## Focused suites

If you only want to run some of the suites, you can make them focused by swapping `Suite` for `FocusedSuite`:

```gleam
import example
import garanti.{type Suite, FocusedSuite, Test}
import garanti/expect

pub fn math_suite() -> Suite {
  FocusedSuite("math", [
    Test("should add two numbers", fn() {
      example.add(2, 2)
      |> expect.to_be_equal(4)
    })
  ])
}
```

## Runner output

The log level controls how much the runner prints:

```gleam
runner.run(garanti.Debug)    // everything
runner.run(garanti.Info)     // suite results and warnings
runner.run(garanti.Warning)  // warnings and errors
runner.run(garanti.Error)    // errors only
```

Here are the tests covering Garanti itself run at `Debug`, as an example of the test report output.

```
❯ gleam test
    Running garanti_test.main
  Discovered 29 suite(s).
  Analysed suites: No problems found.
  Suite When a suite panics during setup completed successfully with 1 test(s)
     Test it should have a single failing test in the suite completed successfully
  Suite When executing tests completed successfully with 3 test(s)
     Test it should pass a passing tests completed successfully
     Test it should fail a failing test completed successfully
     Test it should fail execution for a panicking test completed successfully
  ...

  All 95 test(s) passed!
```

And here is what a failing test looks like in context:

```
  Suite to_not_be_equal completed with 1 failure(s)
     Test should pass completed successfully
     Test should fail failed with:
       Expected 1 to NOT equal 1.
       Actual:  1
       NOT expected:  1
```

## Matchers

Import `garanti/expect` and use the matchers directly. Each returns an `AssertionResult`.

| Matcher                             | What it checks                                     |
| ----------------------------------- | -------------------------------------------------- |
| `all(results)`                      | combines multiple results into one (all must pass) |
| `to_be_equal(a, b)`                 | `a == b`                                           |
| `to_not_be_equal(a, b)`             | `a != b`                                           |
| `to_be_some(opt, val)`              | option is `Some(val)`                              |
| `to_be_none(opt)`                   | option is `None`                                   |
| `to_be_ok(result)`                  | result is `Ok(_)`                                  |
| `to_be_ok_then(result, fn)`         | result is `Ok`, continue asserting on value        |
| `to_be_error(result)`               | result is `Error(_)`                               |
| `to_be_error_then(result, fn)`      | result is `Error`, continue asserting on value     |
| `to_be_empty(list)`                 | list has zero elements                             |
| `to_contain(list, el)`              | list contains element                              |
| `to_be_equivalent(a, b)`            | same elements regardless of order                  |
| `to_be_greater(a, b, cmp)`          | `a > b`                                            |
| `to_be_greater_or_equal(a, b, cmp)` | `a >= b`                                           |
| `to_be_less(a, b, cmp)`             | `a < b`                                            |
| `to_be_less_or_equal(a, b, cmp)`    | `a <= b`                                           |

I want to keep the matchers few. When I write tests I prefer to transform complex data to something simpler. E.g. extract the significant parts of a struct into a smaller tuple and assert on that.

## Before each

There is no before each. You can do complex setup before creating the Suite and the tests will have access to that. Also, since Gleam is immutable there is no risk of tests interfering with each other using that state. Test-specific modifications are done in each test if needed, keeping the state local and nice.

```gleam
import garanti.{type Suite, Test}
import garanti/expect

pub fn math_suite() -> Suite {
  // This is the place to make "complex" setup.
  let addend = 2

  Suite("math", [
    Test("should add two numbers", fn() {
      // And then use it in your test as you want.
      let other_addend = addend + 2

      math.add(addend, other_addend)
      |> expect.to_be_equal(6)
    }),
  ])
}
```

## Custom matchers

A matcher is just a function taking an _actual_ value, often an _expected_ value, and then returns a `garanti.AssertionResult`. This means that you can build your own matchers quite easily, and it will fit in perfect into the runners, reporters, etc.

This is something I have started to use quite frequently in my projects that use Garanti. I keep a separate test module with my custom matchers like this:

```gleam
// test/support/expect.gleam
import garanti
import gleam/int
import gleam/list

pub fn to_have_length(
  actual: List(a),
  expected_length: Int,
) -> garanti.AssertionResult {
  let actual_length = list.length(actual)

  case actual_length == expected_length {
    True -> garanti.Pass
    False ->
      garanti.Fail(
        "Expected list to contain "
          <> int.to_string(expected_length)
          <> " elements",
        [
          garanti.Actual(int.to_string(actual_length)),
          garanti.Expected(int.to_string(expected_length)),
        ],
      )
  }
}
```

This way I can also make custom matchers that rely on the application specific types, keeping the tests nice and tidy.

## Contributors

If you are interested to contribute, open an issue or drop me an email (markus.eliasson@proton.me) and we will take it from there. Please do not just open a pull requests with out us discussing first. And, no AI generated pull-requests.

## Attributions

The official test framework, [`gleeunit`](https://gleeunit.hexdocs.pm), has been studied to understand how test code is discovered. Garanti use a very similar solution thanks to that!
