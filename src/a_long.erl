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
        http_show(Response, ["k"]),
        receive
                cancel->
                        void;
                _ ->
                        good
        after 5000->
                      http_show(Response, ["55555"])
        end,
        message(Response).


