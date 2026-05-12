import garanti
import garanti/internal/list_ext
import gleam/list
import gleam/string

/// Match two values of the same type to be equal.
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
      )
  }
}

/// Match two values of the same type to NOT be equal.
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
      )
  }
}

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

      // Build the failure message. Start with the missing.
      let msg = case missing, extra {
        m, [] -> "is missing element(s) " <> describe_list(m)
        [], e -> "has extra element(s) " <> describe_list(e)
        m, e ->
          "is missing element(s) "
          <> describe_list(m)
          <> " and has extra element(s) "
          <> describe_list(e)
      }

      garanti.Fail("Actual value " <> msg)
    }
  }
}

fn identify_element_presence(
  actual: List(a),
  remaining: List(a),
  acc: List(CollectionPresence(a)),
) -> List(CollectionPresence(a)) {
  case actual, remaining {
    [], [] -> acc

    [], r -> {
      // All elements in the remaining list is missing.
      list.append(acc, list.map(r, Missing))
    }

    a, [] -> {
      // All elements in a is extra.
      list.append(acc, list.map(a, Extra))
    }

    [head, ..tail], r -> {
      // Find the first occurance of the element in the remaining list.
      case list.find(r, fn(rx) { rx == head }) {
        Ok(_match) -> {
          // Drop the first occurance of the element from the remaining.
          let updated_remaining = list_ext.remove_first(from: r, where: head)
          identify_element_presence(tail, updated_remaining, acc)
        }

        _ -> {
          // The element was not found, register a missing element and
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

fn describe_list(lst: List(CollectionPresence(a))) -> String {
  let elements =
    lst
    |> list.map(describe)
    |> string.join(", ")

  "[" <> elements <> "]"
}

fn describe(value: CollectionPresence(a)) {
  string.inspect(value.value)
}
