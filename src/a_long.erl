%%% vim: expandtab tabstop=4 shiftwidth=4

-module(a_long).
-compile([export_all]).
-include("a_include.hrl").

http_show(Response, Content)->
    Response:write_chunk(io_lib:format("~s~n", [lists:flatten(Content, "")])).

pull(Req)->
    Response = Req:ok({"text/plain", chunked}),
    message(Response),
    ok.

message(Response)->
    http_show(Response, mochijson2:encode([{<<"time">>, list_to_binary(utils:longtime_list())}])),
    receive
        cancel->
                    ?B("cancle"),
            void;
        _ ->
                    ?B("good"),
            good
    after 1000->
              message(Response)
    end.
