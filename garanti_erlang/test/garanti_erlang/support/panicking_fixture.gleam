import garanti.{type Suite}

pub fn broken_suite() -> Suite {
  panic as "setup was setup to fail!"
}
