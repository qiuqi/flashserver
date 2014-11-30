%% @author Mochi Media <dev@mochimedia.com>
%% @copyright 2010 Mochi Media <dev@mochimedia.com>

%% @doc Web server for flash.

-module(flash_web).
-author("Mochi Media <dev@mochimedia.com>").

-export([start/1, stop/0, loop/2]).
-include("a_include.hrl").

%% External API

start(Options) ->
    {DocRoot, Options1} = get_option(docroot, Options),
    Loop = fun (Req) ->
                   ?MODULE:loop(Req, DocRoot)
           end,
    mochiweb_http:start([{name, ?MODULE}, {loop, Loop} | Options1]).

stop() ->
    mochiweb_http:stop(?MODULE).

loop(Req, DocRoot) ->
	"/" ++ Path = Req:get(path),
    ?B([Req:get(peer), " -> ", Path]),
    ?B([DocRoot, Path]),
    try
            case Req:get(method) of
                    Method when Method =:= 'GET'; Method =:= 'HEAD' ->
                            a_url:get_url_dispatch(Req, DocRoot, Path);
                    'POST' ->
                            a_url:post_url_dispatch(Req, DocRoot, Path);
                    'PUT' ->
                            a_url:put_url_dispatch(Req, DocRoot, Path);
                    _ ->
                            Req:respond({501, [], []})
            end
    catch
            Type:What ->
                    Report = ["web request failed",
                              {path, Path},
                              {type, Type}, {what, What},
                              {trace, erlang:get_stacktrace()}],
                    error_logger:error_report(Report),
                    Req:respond({500, [{"Content-Type", "text/plain"}],
                                 "request failed, sorry\n"})
    end.



%% Internal API

get_option(Option, Options) ->
        {proplists:get_value(Option, Options), proplists:delete(Option, Options)}.

%%
%% Tests
%%
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

you_should_write_a_test() ->
        ?assertEqual(
           "No, but I will!",
           "Have you written any tests?"),
        ok.

-endif.
