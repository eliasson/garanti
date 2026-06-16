import gleam/int
import gleam/list
import gleam/string

/// Return a new list where the first occurance of the target element is removed.
pub fn remove_first(from list: List(a), where target: a) -> List(a) {
  case list {
    [] -> []
    [head, ..tail] if head == target -> tail
    [head, ..tail] -> [head, ..remove_first(tail, target)]
  }
}

/// Describe the given list by printing each element up to and inclusive the given limit.
///
/// If the list is contains more elements than the list, only the <limit> number of elements
/// are printed together with a count of the total number of elements in the list.
///
/// Examples
/// ```gleam
///  list_ext.describe([1, 2, 3], 2)
///  // -> "[1, 2, ...] with a total of 3 element(s)"
/// ```
pub fn describe(list: List(a), limit: Int) -> String {
  case list {
    [] -> "empty"
    _ -> {
      let start = list.take(list, limit)
      let total = list.length(list)

      // Does the list contain more items than the limit?
      case total > list.length(start) {
        True -> {
          let elements =
            start
            |> list.map(string.inspect)
            |> list.append(["..."])
            |> string.join(", ")

          "["
          <> elements
          <> "] with a total of "
          <> int.to_string(total)
          <> " element(s)"
        }

        False -> describe_all(list)
      }
    }
  }
}

fn describe_all(list: List(a)) {
  let elements =
    list
    |> list.map(string.inspect)
    |> string.join(", ")

  "[" <> elements <> "]"
}
