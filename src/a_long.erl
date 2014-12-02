%%% vim: expandtab tabstop=4 shiftwidth=4

-module(a_long).
-compile([export_all]).
-include("a_include.hrl").

http_show(Response, Content)->
    Response:write_chunk(io_lib:format("~s~n", [lists:flatten(Content, "")])).

pull(Req, Pubkey)->
    Response = Req:ok({"text/plain", chunked}),
    pubsub:subscribe(Pubkey),
    message(Response),
    ok.

message(Response)->
    http_show(Response, mochijson2:encode([{<<"time">>, list_to_binary(utils:longtime_list())}])),
    receive
        cancel->
            ?B("cancle"),
            void;
        {_Pid, _Tag, Message} ->
            ?B(["message", Message]),
            http_show(Response, mochijson2:encode([{<<"message">>, list_to_binary(Message)}]))
    after 1000->
              message(Response)
    end.



push(Req)->
    QS = Req:parse_post(),
    Pubkey = ?GETVALUE("pubkey", QS),
    Message = ?GETVALUE("message", QS),
    pubsub:notify(Pubkey, Message),
    ?HTTP_OK(Req).
