import garanti.{type SuiteResult}
import gleam/erlang/process.{type Subject}

/// The duration in ms for how long we wait for a suite to complete.
const probe_timeout = 3000

pub type SuiteProbe {
  Probe(subject: Subject(SuiteResult))
}

pub fn new() -> SuiteProbe {
  Probe(subject: process.new_subject())
}

pub fn receive_result(probe: SuiteProbe) -> Result(SuiteResult, Nil) {
  process.receive(probe.subject, within: probe_timeout)
}
