# Garanti

Garanti is a test runner and matcher library for Gleam.

## Purpose and design goals

Writing tests in Gleam today using `gleeunit` is a pretty barebone solution, which is fine, since it is the default. But I want something more similiar to what I am used to in other languages.

Core concepts:

- Each tests should return the result of it, which can be success, failure, error or skip.
- Each test runs in isolation from all the other tests.
- All tests run in parallel.

Also, tests should be managed in suites. This will give a group of tests a context and allows for local helper functions for these tests. It should be possible to run a single suite as well as disabling a single suite easily.

## Under development

This library is under development and is not in a usable state yet. I have a few other private Gleam projects where I will dog-food this library before making anything public.

So this README is currently more of my notebook than a proper README =)

## Contributors

Initially I want to implement this project myself, then I should open up for contributors.

## Artificial Intelligence

I want this project to be mine with the purpose of something small and fun to work and polish on. Therefore I prefer to avoid AI generated code in this project. Using an AI as a rubberduck, conversation, help is perfectly fine, but not for code generation.

However, I am a pragmatic and there are some areas in which an agent are truly helpful for me, and that would be, Erlang. The following pieces of FFI are implemented with heavy use of agents.

- The test discovery mechanism, traversing compilied modules to find `_test` functions.
- The `run_catching` method allowing supressing panicking tests to case a crash report.

## Features

Features and limitiations that needs to be described and illustrated in a documentation.

Test discovery performs some validation on the suites and show warnings for:

- Suite names that are not unique
- Suites that have zero tests.

## Matchers needed

- [X] Value equal.
- [X] Value not equal.
- [X] List equivalent.
- [ ] Distinct list items.
- [ ] Value greater than (if relevant, else failure).
- [ ] Value greater or equal than (if relevant, else failure).
- [ ] Value less than (if relevant, else failure).
- [ ] Value less or equal than (if relevant, else failure).
- [ ] List length.
- [ ] String length.
- [ ] String contains.
- [ ] List contains.
- [ ] String starts with (?)
- [ ] String ends with (?)
- [X] Is Error.
- [X] Is Ok.
- [X] Is Some.
- [X] Is None.
