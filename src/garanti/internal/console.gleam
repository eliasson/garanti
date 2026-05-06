import garanti
import gleam/io

/// Console printing
/// - Currently wraps the io module only.
/// - Extend with ANSI colours and graphics for tests result.
pub type Output {
  Output(level: garanti.LogLevel)
}

pub type Message {
  Error(String)
  Warning(String)
  Info(String)
}

pub fn print(out: Output, message: Message) -> Output {
  case out.level, message {
    garanti.Error, Error(line) -> print_it(out, line)

    garanti.Error, Warning(line) -> print_it(out, line)
    garanti.Warning, Warning(line) -> print_it(out, line)

    garanti.Error, Info(line) -> print_it(out, line)
    garanti.Warning, Info(line) -> print_it(out, line)
    garanti.Info, Info(line) -> print_it(out, line)

    _, _ -> out
  }
}

fn print_it(out: Output, line: String) -> Output {
  println(line)
  out
}

fn println(line: String) {
  io.println(line)
}
