%%% vim: expandtab tabstop=4 shiftwidth=4

-module(a_long).
-compile([export_all]).
-include("a_include.hrl").

http_show(Response, Content)->
    Response:write_chunk(io_lib:format("~s~n", [lists:flatten(Content, "")])).

pull(Req, Pubkey)->
    Response = Req:ok({"text/plain", chunked}),
    users:setUidPid(Pubkey, self()),
    message(Response),
    ok.

message(Response)->
    http_show(Response, mochijson2:encode([{<<"time">>, list_to_binary(utils:longtime_list())}])),
    receive
        cancel->
                    ?B("cancle"),
            void;
        {Message} ->
                    ?B(["message", Message]),
                    http_show(Response, mochijson2:encode([{<<"message">>, list_to_binary(Message)}]))
    after 1000->
              message(Response)
    end.



push(Req)->
        QS = Req:parse_post(),
        Pubkey = ?GETVALUE("pubkey", QS),
        Message = ?GETVALUE("message", QS),
        case users:isAlive(Pubkey) of
                {true, Pid} ->
                        Pid ! {Message},
                        ?HTTP_OK(Req);
                _ ->
                        ?HTTP_FAILED(Req)
        end.
