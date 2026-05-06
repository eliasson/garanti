import garanti
import gleam/io

/// Console printing
/// - Currently wraps the io module only.
/// - Extend with ANSI colours and graphics for tests result.
pub type Output {
  Output(level: garanti.LogLevel)
}

pub fn error(out: Output, line: String) -> Output {
  case out.level {
    garanti.Error -> print_it(out, line)
    _ -> out
  }
}

pub fn warning(out: Output, line: String) -> Output {
  case out.level {
    garanti.Error -> print_it(out, line)
    garanti.Warning -> print_it(out, line)
    _ -> out
  }
}

pub fn info(out: Output, line: String) -> Output {
  case out.level {
    garanti.Error -> print_it(out, line)
    garanti.Warning -> print_it(out, line)
    garanti.Info -> print_it(out, line)
    garanti.Debug -> print_it(out, line)
  }
}

pub fn debug(out: Output, line: String) -> Output {
  print_it(out, line)
}

fn print_it(out: Output, line: String) -> Output {
  println(line)
  out
}

fn println(line: String) {
  io.println(line)
}
