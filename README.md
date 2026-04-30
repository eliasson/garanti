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

I want this project to be mine with the purpose of something small and fun to work and polish. Therefore I do not want AI generated code in this project. Using an AI as a rubberduck, conversation, help is perfectly fine, but not for code generation. There is one particular part of Garanti that is generated with the help of Claude Code though, the test discovery mechanism.
