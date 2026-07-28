# Garanti

Garanti is a Gleam test framework built around suites, parallel execution and readable failure messages.

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

- Each test should return the result of it, which can be success, failure or error.
- Each test runs in isolation from all the other tests.
- All tests run in parallel.

Also, tests should be managed in suites. This will give a group of tests a context and allows for local helper functions for these tests. It should be possible to run a single suite as well as disabling a single suite easily.

## Installation

  > [!NOTE]
  > I currently dog-fooding this library in one of my applications and will likely do some adjustments and extensions.
  > Hence, I am making the repository public but not publishing on hex.pm until it reaches v1.0.0.

1. First you need to clone the git repository as a local clone.

2. Add `garanti` to your `gleam.toml`:

```toml
[dev-dependencies]
garanti =  { path = "/home/you/stuff-from-the-internet/garanti" }
```

3. Add the runner.

Depending on your target VM you have to also add a separate runner. This is since the Erlang runner use OTP for parallelism and that is not available in JavaScript. A side effect of this is that the JavaScript runner will execute tests in sequence, and without support for timeouts.

```toml
[dev-dependencies]
# NOTE, you should only use ONE of these.
garanti_erlang =  { path = "/home/you/stuff-from-the-internet/garanti_erlang" }
garanti_javascript =  { path = "/home/you/stuff-from-the-internet/garanti_javascript" }
```

4. Then set your test entrypoint to call the runner (which is also based on the target VM):

```gleam
// test/my_project_test.gleam
import garanti
// NOTE only import the runner you need.
import garanti_erlang/runner
import garanti_javascript/runner

pub fn main() -> Nil {
  runner.run(garanti.Info)
}
```

## Writing tests

All tests belong to a suite. A suite is any function ending in `_suite` and that returns a `Suite`.

Each test is a function that returns `AssertionResult`:

```gleam
pub type AssertionResult {
  Pass
  Fail(String)
  Timeout
}
```

You can return `garanti.Pass` or `garanti.Fail("message")` directly, or use the `expect` module.

## Runner output

The log level controls how much the runner prints:

```gleam
runner.run(garanti.Debug)    // everything
runner.run(garanti.Info)     // suite results and warnings
runner.run(garanti.Warning)  // warnings and errors
runner.run(garanti.Error)    // errors only
```

Here is a snippet of the tests covering Garanti itself as an example of the test report output.

```
❯ gleam test
  Compiling garanti
   Compiled in 0.29s
    Running garanti_test.main
  Discovered 23 suite(s).
  Analysed suites: No problems found.
  Running 23 suites...
  Suite math completed successfully with 3 test(s)
     Test should not divide by zero completed successfully
     Test should divide by two completed successfully
     Test should add two numbers completed successfully
  ...
  Suite to_be_equal completed with 1 failure(s)
     Test should pass completed successfully
     Test should fail failed with: 
       Expected 1 to equal 2. 
       Actual:  1 
       Expected:  2 

  All 81 test(s) passed!
```

## Matchers

Import `garanti/expect` and use the matchers directly. Each returns an `AssertionResult`.

| Matcher                             | What it checks |
|-------------------------------------|----------------|
| `to_be_equal(a, b)`                 | `a == b` |
| `to_not_be_equal(a, b)`             | `a != b` |
| `to_be_some(opt, val)`              | option is `Some(val)` |
| `to_be_none(opt)`                   | option is `None` |
| `to_be_ok(result)`                  | result is `Ok(_)` |
| `to_be_ok_then(result, fn)`         | result is `Ok`, continue asserting on value |
| `to_be_error(result)`               | result is `Error(_)` |
| `to_be_error_then(result, fn)`      | result is `Error`, continue asserting on value |
| `to_be_empty(list)`                 | list has zero elements |
| `to_contain(list, el)`              | list contains element |
| `to_be_equivalent(a, b)`            | same elements regardless of order |
| `to_be_greater(a, b, cmp)`          | `a > b` |
| `to_be_greater_or_equal(a, b, cmp)` | `a >= b` |
| `to_be_less(a, b, cmp)`             | `a < b` |
| `to_be_less_or_equal(a, b, cmp)`    | `a <= b` |

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

## Artificial Intelligence

I want this project to be mine with the purpose of something small and fun to work and polish on. Therefore I prefer to avoid AI generated code in this project. Using an AI as a rubberduck, conversation, help is perfectly fine, but not for code generation.

However, I am a pragmatic person and there are some areas in which an agent are truly helpful for me, one of these areas is Erlang. The following pieces of FFI are implemented with heavy use of agents.

- The test discovery mechanism, traversing compiled modules to find `_suite` functions.
- The `run_catching` method allowing suppressing panicking tests from causing a crash report.

## Contributors

Initially I want to implement this project myself, then I might open up for contributors. If you are interested drop me an email (markus.eliasson@proton.me) and we will take it from there. Please do not just open a pull requests with out us discussing first.
