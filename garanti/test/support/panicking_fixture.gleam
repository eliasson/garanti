@target(erlang)
import garanti.{type Suite}

// Only used by the Erlang discovery test (looked up by module name via BEAM
// reflection). Target-gated so the JavaScript discovery walk — which has no
// filename filtering and picks up any `*_suite`-suffixed export under test/ —
// doesn't mistake this fixture for a real suite to run.
@target(erlang)
pub fn broken_suite() -> Suite {
  panic as "setup was setup to fail!"
}
