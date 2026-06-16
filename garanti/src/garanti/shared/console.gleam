import garanti
import garanti/shared/report
import gleam/io
import gleam/list
import gleam/string

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

pub fn print_all(out: Output, messages: List(report.Message)) -> Output {
  list.each(messages, fn(m) { print(out, m) })
  out
}

pub fn print(out: Output, message: report.Message) -> Output {
  case out.level, message.level {
    // Always print successful messages.
    _, report.Success -> print_message(out, message)

    // Print only errors.
    garanti.Error, report.Error -> print_message(out, message)

    // Print errors and warnings.
    garanti.Warning, report.Error -> print_message(out, message)
    garanti.Warning, report.Warning -> print_message(out, message)

    // Print errors, warnings and info.
    garanti.Info, report.Error -> print_message(out, message)
    garanti.Info, report.Warning -> print_message(out, message)
    garanti.Info, report.Info -> print_message(out, message)

    // Print all messages.
    garanti.Debug, _ -> print_message(out, message)

    // Print nothing.
    _, _ -> out
  }
}

fn print_message(out: Output, message: report.Message) -> Output {
  message.tokens
  |> list.map(evaluate_token)
  |> string.join(" ")
  |> println()
  out
}

fn evaluate_token(token: report.Token) -> String {
  case token {
    report.Plain(text) -> text
    report.Enriched(text, effects) -> t(text, effects)
    report.Indent -> "  "
    report.Block(text) -> "\n\n" <> text <> "\n"
  }
}

const ansi_reset = "\u{001b}[0m"

fn t(text: String, effects: List(report.Effect)) -> String {
  case effects {
    [] -> text
    [head, ..tail] -> {
      case head {
        // Green
        report.Positive -> "\u{001b}[32m" <> t(text, tail) <> ansi_reset

        // Red
        report.Negative -> "\u{001b}[31m" <> t(text, tail) <> ansi_reset

        // Yellow
        report.Important -> "\u{001b}[33m" <> t(text, tail) <> ansi_reset

        // Bright white
        report.Name -> "\u{001b}[97m" <> t(text, tail) <> ansi_reset

        // Dim white
        report.Secondary -> "\u{001b}[2m" <> t(text, tail) <> ansi_reset

        // Just bold
        report.Bold -> "\u{001b}[1m" <> t(text, tail) <> ansi_reset
      }
    }
  }
}

fn println(line: String) {
  io.println("  " <> line)
}
