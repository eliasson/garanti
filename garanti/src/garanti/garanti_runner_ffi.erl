-module(garanti_runner_ffi).

-export([exit_failure/0]).

exit_failure() ->
    erlang:halt(1).
