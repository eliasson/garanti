/// Assertion matchers for garanti tests.
///
/// Most functions takes an `actual` and an `expected` value and returns a
/// `garanti.AssertionResult` with the result.
import garanti
import garanti/shared/list_ext
import gleam/list
import gleam/option
import gleam/order
import gleam/string

/// The max number of elements to describe when a list comparision failed.
const describe_list_limit = 10

/// Asserts that two values of the same type are equal.
///
/// ## Examples
///
/// ```gleam
/// expect.to_be_equal(1, 1)
/// // -> Pass
///
/// expect.to_be_equal("hello", "world")
/// // -> Fail("Expected \"hello\" to equal \"world\".")
/// ```
pub fn to_be_equal(actual: a, expected: a) -> garanti.AssertionResult {
  case actual == expected {
    True -> garanti.Pass
    False ->
      garanti.Fail(
        string.concat([
          "Expected ",
          string.inspect(actual),
          " to equal ",
          string.inspect(expected),
          ".",
        ]),
        [
          garanti.Actual(string.inspect(actual)),
          garanti.Expected(string.inspect(expected)),
        ],
      )
  }
}

/// Asserts that two values of the same type are NOT equal.
///
/// ## Examples
///
/// ```gleam
/// expect.to_not_be_equal(1, 2)
/// // -> Pass
///
/// expect.to_not_be_equal("hello", "hello")
/// // -> Fail("Expected \"hello\" to NOT equal \"hello\".")
/// ```
pub fn to_not_be_equal(actual: a, expected: a) -> garanti.AssertionResult {
  case actual == expected {
    False -> garanti.Pass
    True ->
      garanti.Fail(
        string.concat([
          "Expected ",
          string.inspect(actual),
          " to NOT equal ",
          string.inspect(expected),
          ".",
        ]),
        [
          garanti.Actual(string.inspect(actual)),
          garanti.NotExpected(string.inspect(expected)),
        ],
      )
  }
}

/// Asserts that two lists contain the same elements, regardless of order.
///
/// Each element is matched by equality, and duplicates are considered. I.e.
/// `[1, 1, 2]` is not equivalent to `[1, 2]`.
///
/// > Note: this assertion compares every element in both lists, so avoid it
/// > for very large lists where performance matters.
///
/// ## Examples
///
/// ```gleam
/// expect.to_be_equivalent([1, 2, 3], [3, 1, 2])
/// // -> Pass
///
/// expect.to_be_equivalent([1, 2], [1, 2, 3])
/// // -> Fail("Actual value is missing element(s) [3]")
///
/// expect.to_be_equivalent([1, 2, 3], [1, 2])
/// // -> Fail("Actual value has extra element(s) [3]")
/// ```
pub fn to_be_equivalent(
  actual: List(a),
  expected: List(a),
) -> garanti.AssertionResult {
  // Let's assume that the lists are not very big. If they are, this assertion should be avoided.

  case identify_element_presence(actual, expected, []) {
    [] -> garanti.Pass
    result -> {
      let #(missing, extra) =
        list.partition(result, fn(p) {
          case p {
            Missing(_) -> True
            _ -> False
          }
        })

      let expectations = case missing, extra {
        m, [] -> [garanti.Missing(describe_presence_list(m))]
        [], e -> [garanti.Extra(describe_presence_list(e))]
        m, e -> [
          garanti.Missing(describe_presence_list(m)),
          garanti.Extra(describe_presence_list(e)),
        ]
      }

      garanti.Fail("Expect to be equivalent:", expectations)
    }
  }
}

/// Asserts that the actual value is a Some of an expected value.
///
/// ## Examples
///
/// ```gleam
/// expect.to_be_some(option.Some(1), 1)
/// // -> Pass
///
/// expect.to_be_some(option.None, "world")
/// // -> Fail("Expected None to be Some of \"world\".")
/// ```
pub fn to_be_some(
  actual: option.Option(a),
  expected: a,
) -> garanti.AssertionResult {
  case actual {
    option.Some(a) if a == expected -> garanti.Pass
    option.Some(a) ->
      garanti.Fail(
        string.concat([
          "Expected ",
          string.inspect(a),
          " to be ",
          string.inspect(expected),
          ".",
        ]),
        [
          garanti.Actual(string.inspect(a)),
          garanti.Expected(string.inspect(expected)),
        ],
      )
    option.None ->
      garanti.Fail(
        string.concat([
          "Expected None to be ",
          string.inspect(expected),
          ".",
        ]),
        [
          garanti.Actual("None"),
          garanti.Expected(string.inspect(expected)),
        ],
      )
  }
}

/// Assert that the given option is None.
///
/// ## Examples
///
/// ```gleam
/// expect.to_be_none(option.None)
/// // -> Pass
///
/// expect.to_be_none(option.Some("hello"))
/// // -> Fail("Expected \"world\" to be None.")
/// ```
pub fn to_be_none(actual: option.Option(a)) -> garanti.AssertionResult {
  case actual {
    option.None -> garanti.Pass
    option.Some(a) ->
      garanti.Fail(
        string.concat([
          "Expected ",
          string.inspect(a),
          " to be None.",
        ]),
        [
          garanti.Actual(string.inspect(a)),
          garanti.Expected("None"),
        ],
      )
  }
}

/// Asserts that the actual value is `Ok`, then runs further assertions on the
/// inner value via a callback.
///
/// Use this when you want to both verify a `Result` is `Ok` and make
/// additional assertions on the unwrapped value in a single expression.
///
/// ## Examples
///
/// ```gleam
/// expect.to_be_ok_then(Ok(42), fn(n) { expect.to_be_equal(n, 42) })
/// // -> Pass
///
/// // Or alternative
/// use value <- expect.to_be_ok_then(Ok(42))
/// expect.to_be_equal(value, 42)
/// // -> Pass
///
/// expect.to_be_ok_then(Ok(42), fn(n) { expect.to_be_equal(n, 0) })
/// // -> Fail("Expected 42 to equal 0.")
/// ```
pub fn to_be_ok_then(
  actual: Result(a, b),
  t: fn(a) -> garanti.AssertionResult,
) -> garanti.AssertionResult {
  case actual {
    Ok(res) -> t(res)
    Error(err) ->
      garanti.Fail(
        "Expected actual to be Ok but it was an Error of "
          <> string.inspect(err),
        [garanti.Actual(string.inspect(err)), garanti.Expected("Ok")],
      )
  }
}

/// Asserts that the actual value is `Ok`.
///
/// This is a blunt test as the value of Ok is not asserted. Using `to_be_ok_then` will
/// provide more robust test.
///
/// ## Examples
///
/// ```gleam
/// expect.to_be_ok(Ok(42))
/// // -> Pass
///
/// expect.to_be_ok(Error(Nil))
/// // -> Fail("Expected actual to be Ok but it was an Error of Nil.")
/// ```
pub fn to_be_ok(actual: Result(a, b)) -> garanti.AssertionResult {
  case actual {
    Ok(_) -> garanti.Pass
    Error(err) ->
      garanti.Fail(
        "Expected actual to be Ok but it was an Error of "
          <> string.inspect(err),
        [garanti.Actual(string.inspect(err)), garanti.Expected("Ok")],
      )
  }
}

/// Asserts that the actual value is an `Error`, then runs further assertions on the
/// inner value via a callback.
///
/// Use this when you want to both verify a `Result` is `Error` and make
/// additional assertions on the unwrapped value in a single expression.
///
/// ## Examples
///
/// ```gleam
/// expect.to_be_error_then(Error(404), fn(n) { expect.to_be_equal(n, 404) })
/// // -> Pass
///
/// // Or alternative
/// use value <- expect.to_be_error_then(Error(404))
/// expect.to_be_equal(value, 404)
/// // -> Pass
///
/// expect.to_be_ok_error(Error(418), fn(n) { expect.to_be_equal(n, 404) })
/// // -> Fail("Expected 418 to equal 404.")
/// ```
pub fn to_be_error_then(
  actual: Result(a, b),
  t: fn(b) -> garanti.AssertionResult,
) -> garanti.AssertionResult {
  case actual {
    Ok(value) ->
      garanti.Fail(
        "Expected actual to be Error but it was an Ok of "
          <> string.inspect(value),
        [garanti.Actual(string.inspect(value)), garanti.Expected("Error")],
      )
    Error(err) -> t(err)
  }
}

/// Asserts that the actual value is an`Error`.
///
/// This is a blunt test as the value of Error is not asserted. Using `to_be_error_then` will
/// provide more robust test.
///
/// ## Examples
///
/// ```gleam
/// expect.to_be_error(Error(Nil))
/// // -> Pass
///
/// expect.to_be_error(Ok(42))
/// // -> Fail("Expected actual to be Error but it was an Ok of 42.")
/// ```
pub fn to_be_error(actual: Result(a, b)) -> garanti.AssertionResult {
  case actual {
    Ok(value) ->
      garanti.Fail(
        "Expected actual to be Error but it was an Ok of "
          <> string.inspect(value),
        [garanti.Actual(string.inspect(value)), garanti.Expected("Error")],
      )
    Error(_) -> garanti.Pass
  }
}

/// Asserts that a list has no elemenets.
///
/// ## Examples
///
/// ```gleam
/// expect.to_be_empty([])
/// // -> Pass
///
/// expect.to_be_error([1, 2, 3])
/// // -> Fail("Expected list to be empty but was [1, 2, 3]")
/// ```
pub fn to_be_empty(actual: List(a)) -> garanti.AssertionResult {
  case actual {
    [] -> garanti.Pass
    _ -> {
      garanti.Fail("Expected list to be empty:", [
        garanti.Actual(list_ext.describe(actual, describe_list_limit)),
        garanti.Expected("[]"),
      ])
    }
  }
}

/// Assert that a list contains a given element.
///
/// ## Examples
///
/// ```gleam
/// expect.to_contain([1, 2, 3], 2)
/// // -> Pass
///
/// expect.to_contain([1, 2, 3], 4)
/// // -> Fail("Expected list to contain 4 but contained [1, 2, 3]")
/// ```
pub fn to_contain(actual: List(a), expected: a) -> garanti.AssertionResult {
  case list.contains(actual, expected) {
    True -> garanti.Pass
    False -> {
      case actual {
        [] -> {
          garanti.Fail(
            "Expected empty list to contain " <> string.inspect(expected),
            [garanti.Actual("[]"), garanti.Expected(string.inspect(expected))],
          )
        }
        _ -> {
          garanti.Fail(
            "Expected list to contain "
              <> string.inspect(expected)
              <> " but contained "
              <> list_ext.describe(actual, describe_list_limit),
            [
              garanti.Actual(list_ext.describe(actual, describe_list_limit)),
              garanti.Expected(string.inspect(expected)),
            ],
          )
        }
      }
    }
  }
}

/// Assert that the actual value is greater than the expected value.
///
/// ## Examples
///
/// ```gleam
/// expect.to_be_greater(3, 2, int.compare)
/// // -> Pass
///
/// expect.to_be_greater(2, 3, int.compare)
/// // -> Fail("Expected 2 to be greater than 3")
/// ```
pub fn to_be_greater(
  actual: a,
  expected: a,
  compare: fn(a, a) -> order.Order,
) -> garanti.AssertionResult {
  case compare(actual, expected) {
    order.Gt -> garanti.Pass
    _ ->
      garanti.Fail(
        "Expected "
          <> string.inspect(actual)
          <> " to be greater than "
          <> string.inspect(expected),
        [
          garanti.Actual(string.inspect(actual)),
          // What to add as "expected"? New ExpectGreaterThan is pretty specific...
        ],
      )
  }
}

/// Assert that the actual value is greater than or equal to the expected value.
///
/// ## Examples
///
/// ```gleam
/// expect.to_be_greater_or_equal(2, 2)
/// // -> Pass
///
/// expect.to_be_greater_or_equal(2, 3)
/// // -> Fail("Expected 2 to be greater or equal to 3")
/// ```
pub fn to_be_greater_or_equal(
  actual: a,
  expected: a,
  compare: fn(a, a) -> order.Order,
) -> garanti.AssertionResult {
  case compare(actual, expected) {
    order.Lt ->
      garanti.Fail(
        "Expected "
          <> string.inspect(actual)
          <> " to be greater or equal to "
          <> string.inspect(expected),
        [
          garanti.Actual(string.inspect(actual)),
          // What to add as "expected"? New ExpectGreaterThan is pretty specific...
        ],
      )
    _ -> garanti.Pass
  }
}

/// Assert that the actual value is less than the expected value.
///
/// ## Examples
///
/// ```gleam
/// expect.to_be_less(2, 3)
/// // -> Pass
///
/// expect.to_be_less(3, 2)
/// // -> Fail("Expected 3 to be less than 2")
/// ```
pub fn to_be_less(
  actual: a,
  expected: a,
  compare: fn(a, a) -> order.Order,
) -> garanti.AssertionResult {
  case compare(actual, expected) {
    order.Lt -> garanti.Pass
    _ ->
      garanti.Fail(
        "Expected "
          <> string.inspect(actual)
          <> " to be less than "
          <> string.inspect(expected),
        [
          garanti.Actual(string.inspect(actual)),
          // What to add as "expected"? New ExpectLessThan is pretty specific...
        ],
      )
  }
}

/// Assert that the actual value is less than or equal to the expected value.
///
/// ## Examples
///
/// ```gleam
/// expect.to_be_less_or_equal(2, 2)
/// // -> Pass
///
/// expect.to_be_less_or_equal(2, 3)
/// // -> Fail("Expected 2 to be less than or equal to 3")
/// ```
pub fn to_be_less_or_equal(
  actual: a,
  expected: a,
  compare: fn(a, a) -> order.Order,
) -> garanti.AssertionResult {
  case compare(actual, expected) {
    order.Gt ->
      garanti.Fail(
        "Expected "
          <> string.inspect(actual)
          <> " to be less than or equal to "
          <> string.inspect(expected),
        [
          garanti.Actual(string.inspect(actual)),
          // What to add as "expected"? New ExpectLessThan is pretty specific...
        ],
      )
    _ -> garanti.Pass
  }
}

fn identify_element_presence(
  actual: List(a),
  remaining: List(a),
  acc: List(CollectionPresence(a)),
) -> List(CollectionPresence(a)) {
  case actual, remaining {
    // We're done!
    [], [] -> acc

    // All elements in the remaining list is missing.
    [], r -> list.append(acc, list.map(r, Missing))

    // All elements in a is extra.
    a, [] -> list.append(acc, list.map(a, Extra))

    // Find the first occurance of the element in the remaining list.
    [head, ..tail], r -> {
      case list.find(r, fn(rx) { rx == head }) {
        Ok(_match) -> {
          // Drop the first occurance of the element from the remaining.
          let updated_remaining = list_ext.remove_first(from: r, where: head)
          identify_element_presence(tail, updated_remaining, acc)
        }

        _ -> {
          // The element was not found, register an extra element and
          // continue with the same remaining elements as this call.
          let updated_acc = list.append(acc, [Extra(head)])
          identify_element_presence(tail, r, updated_acc)
        }
      }
    }
  }
}

type CollectionPresence(a) {
  // The element was missing in the actual collection (i.e. present in the expected collection only).
  Missing(value: a)
  // The element was extra in the actual collection (i.e. missing from the expected collection).
  Extra(value: a)
}

fn describe_presence_list(lst: List(CollectionPresence(a))) -> String {
  lst
  |> list.map(fn(value: CollectionPresence(a)) { value.value })
  |> list_ext.describe(describe_list_limit)
}
