%%% vim: expandtab tabstop=4 shiftwidth=4

%% @author Mochi Media <dev@mochimedia.com>
%% @copyright 2010 Mochi Media <dev@mochimedia.com>

%% @doc flash.

-module(flash).
-author("Mochi Media <dev@mochimedia.com>").
-export([start/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.


%% @spec start() -> ok
%% @doc Start the flash server.
start() ->
    flash_deps:ensure(),
    ensure_started(crypto),
    ensure_started(salt),
    ensure_started(gproc),
    lager:start(),
    inets:start(),
    application:start(flash).


%% @spec stop() -> ok
%% @doc Stop the flash server.
stop() ->
    application:stop(gproc),
    application:stop(flash).
