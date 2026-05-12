/// Return a new list where the first occurance of the target element is removed.
pub fn remove_first(from list: List(a), where target: a) -> List(a) {
  case list {
    [] -> []
    [head, ..tail] if head == target -> tail
    [head, ..tail] -> [head, ..remove_first(tail, target)]
  }
}
