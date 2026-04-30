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

% Returns all available modules whose name ends with "_test" and belong to the
% same project as the test entry point.
%
% Gleam namespaces compiled modules as "<project>@<module>", so "example@another_test"
% belongs to the "example" project. We find the project name by inspecting the current
% call stack for the main/0 frame — that is always the test entry point — and extracting
% its namespace prefix.
%
% code:all_available/0 gives [{ModuleNameString, Filepath, IsLoaded}] for every module
% on the code path, including unloaded ones. We call code:ensure_loaded/1 before
% returning so that module_info/1 can be called on them by the caller.
% Module names come back as character lists from all_available/0, so we convert
% to atom first, then to binary for Gleam.
loaded_test_modules() ->
    Prefix = test_project_prefix(),
    [begin
        Atom = list_to_atom(Mod),
        code:ensure_loaded(Atom),
        atom_to_binary(Atom, utf8)
     end
     || {Mod, _Path, _Loaded} <- code:all_available(),
        is_test_module(Mod),
        lists:prefix(Prefix, Mod)].

% Walks the current call stack looking for a main/0 frame, then extracts the
% namespace prefix (the part before "@") from that module name.
test_project_prefix() ->
    {current_stacktrace, Stack} = process_info(self(), current_stacktrace),
    find_prefix_in_stack(Stack).

find_prefix_in_stack([]) -> "";
find_prefix_in_stack([{Mod, main, 0, _} | _]) ->
    ModStr = atom_to_list(Mod),
    case string:split(ModStr, "@", leading) of
        [Prefix, _] -> Prefix ++ "@";
        _           -> ""
    end;
find_prefix_in_stack([_ | Rest]) ->
    find_prefix_in_stack(Rest).

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
