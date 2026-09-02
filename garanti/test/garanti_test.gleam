import garanti
import garanti/runner

@target(javascript)
import gleam/javascript/promise.{type Promise}

@target(erlang)
pub fn main() -> Nil {
  runner.run(garanti.Debug)
}

@target(javascript)
pub fn main() -> Promise(Nil) {
  runner.run(garanti.Debug)
}
