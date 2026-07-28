import garanti.{Suite, Test}
import garanti/expect
import garanti_erlang/internal/executor
import garanti_erlang/support/tests

pub fn executor_suite() {
  Suite("When executing tests", [
    Test("it should pass a passing tests", fn() {
      executor.run(tests.passing_assert)
      |> expect.to_be_equal(executor.Executed(garanti.Pass))
    }),

    Test("it should fail a failing test", fn() {
      executor.run(tests.failing_assert)
      |> expect.to_be_equal(
        executor.Executed(garanti.Fail("set up to fail", [])),
      )
    }),

    Test("it should fail execution for a panicking test", fn() {
      executor.run(tests.panicking_assert)
      |> expect.to_be_equal(executor.ExecutionFailure("Test panicked"))
    }),
  ])
}
