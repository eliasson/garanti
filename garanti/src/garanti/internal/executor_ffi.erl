-module(executor_ffi).
-export([run_catching/1]).

% Calls the given test function inside a try/catch so that any exception (e.g. a
% Gleam panic) is caught before it propagates. When an exception is caught the
% process exits normally rather than crashing, which suppresses the Erlang crash
% report that would otherwise be printed to stdout.
%
% Returns {ok, Result} if the function completes, or {error, nil} if it throws.
run_catching(TestFn) ->
    try
        {ok, TestFn()}
    catch
        _:_ -> {error, nil}
    end.
