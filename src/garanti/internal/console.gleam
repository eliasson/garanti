import garanti
import gleam/io
import gleam/list
import gleam/string

/// Console printing
/// - Currently wraps the io module only.
/// - Extend with ANSI colours and graphics for tests result.
pub type Output {
  Output(level: garanti.LogLevel)
}

pub type Message {
  Success(String)
  Error(String)
  Warning(String)
  Info(String)
  Debug(String)
}

pub fn print_all(out: Output, messages: List(Message)) -> Output {
  list.each(messages, fn(m) { print(out, m) })
  out
}

const success = "[GARANTI]"

const error = "  [ERROR]"

const warn = "   [WARN]"

const info = "   [INFO]"

const debug = "  [DEBUG]"

pub fn print(out: Output, message: Message) -> Output {
  case message, out.level {
    Success(line), _ -> print_it(out, success, line)

    Error(line), _ -> print_it(out, error, line)

    Warning(line), garanti.Warning -> print_it(out, warn, line)
    Warning(line), garanti.Info -> print_it(out, warn, line)
    Warning(line), garanti.Debug -> print_it(out, warn, line)

    Info(line), garanti.Info -> print_it(out, info, line)
    Info(line), garanti.Debug -> print_it(out, info, line)

    Debug(line), garanti.Debug -> print_it(out, debug, line)

    _, _ -> out
  }
}

fn print_it(out: Output, prefix: String, line: String) -> Output {
  // Likely generating some allocations, investigate string trees.
  string.append(prefix <> " ", line)
  |> println()

  out
}

fn println(line: String) {
  io.println(line)
}
