%% @author Mochi Media <dev@mochimedia.com>
%% @copyright flash Mochi Media <dev@mochimedia.com>

%% @doc Callbacks for the flash application.

-module(flash_app).
-author("Mochi Media <dev@mochimedia.com>").

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for flash.
start(_Type, _StartArgs) ->
    flash_deps:ensure(),
    flash_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for flash.
stop(_State) ->
    ok.
