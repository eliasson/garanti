-module(discovery_ffi).

-export([loaded_test_modules/0, module_exports/1, apply_suite/2]).

%
% Full disclosure. This ffi module is generated using Claude Code.
%
% As far as I have understood the command "gleam test" will compile and load(?)
% all modules under test/ so that they are available when the main function in
% in the test entry (e.g. example/test/example_test.gleam) is run.
%
% The functions here are then use to grab the modules qualifying for being a
% test by using the _test suffix. Then to expose a function where the exports
% of these modules can be retrieved.

% Returns all currently loaded modules whose name ends with "_test".
% code:all_loaded/0 gives [{ModuleAtom, Filepath}] for every loaded beam file.
% Module names are atoms in Erlang but strings in Gleam, so we convert with atom_to_binary/2.
loaded_test_modules() ->
    AllLoaded = code:all_loaded(),
    [atom_to_binary(Mod, utf8)
     || {Mod, _Path} <- AllLoaded, is_test_module(atom_to_list(Mod))].

is_test_module(Name) ->
    lists:suffix("_test", Name).

% Returns the exported functions of a module as a list of Export records.
% Gleam passes module names as binaries, but Erlang module dispatch requires atoms,
% so we convert with binary_to_atom/2 before calling module_info/1.
% module_info(exports) gives [{FunctionAtom, Arity}]; we reshape each entry into
% the tagged tuple {export, FunctionBinary, Arity} that matches Gleam's Export type.
module_exports(ModuleBin) ->
    Mod = binary_to_atom(ModuleBin, utf8),
    [{export, atom_to_binary(F, utf8), A} || {F, A} <- Mod:module_info(exports)].

% Calls Module:Function() dynamically and returns the result.
% Both arguments arrive as Gleam strings (binaries) and must be converted to atoms
% before use in an Erlang apply expression.
% The return value is trusted to be a Suite by naming convention — no runtime check.
apply_suite(ModuleBin, FuncBin) ->
    Mod = binary_to_atom(ModuleBin, utf8),
    Func = binary_to_atom(FuncBin, utf8),
    Mod:Func().
