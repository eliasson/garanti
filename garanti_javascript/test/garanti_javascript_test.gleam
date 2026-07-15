import garanti
import garanti_javascript/runner
import gleam/javascript/promise.{type Promise}

pub fn main() -> Promise(Nil) {
  runner.run(garanti.Debug)
}
