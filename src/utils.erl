-module(utils).
-export([longtime_list/0, longtime_int/0, uuid/0]).

longtime_list() ->
	{M, S, I} = erlang:now(),
	integer_to_list(trunc(M * 1000000000 + S * 1000 + I / 1000)).

longtime_int() ->
	{_M, S, I} = erlang:now(),
	trunc(S * 1000 + I / 1000).


uuid()->
	{ok, File} = file:open("/proc/sys/kernel/random/uuid", [binary]),
	{ok, Uuid} = file:read(File, 36),
	Uuid.
