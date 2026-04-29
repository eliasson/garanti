import garanti.{type SuiteResult}
import gleam/erlang/process.{type Subject}

pub type SuiteProbe {
  Probe(subject: Subject(SuiteResult))
}

pub fn new() -> SuiteProbe {
  Probe(subject: process.new_subject())
}

pub fn receive_result(probe: SuiteProbe) -> Result(SuiteResult, Nil) {
  process.receive(probe.subject, within: 5000)
}
