%%% vim: expandtab tabstop=4 shiftwidth=4

-module(a_long).
-export([pull/2, push/1]).
-export([subscribe/5]).
-export([publish/1]).
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

jsonMessage(Message, Nonce)->
    {struct,
     [
      {"type", ?U("message")},
      {"nonce", ?U(Nonce)},
      {"body", ?U(Message)}
     ]}.

publish(Req)->
    QS = Req:parse_post(),
    From = ?GETVALUE("from", QS),
    %%DynamicPK = ?GETVALUE("dynamic", QS),
    Channel = ?GETVALUE("channel", QS),
    Nonce = ?GETVALUE("nonce", QS),
    Auth = ?GETVALUE("auth", QS),
    MsgNonce = ?GETVALUE("msg_nonce", QS),
    Msg = ?GETVALUE("msg", QS),
    FromPK = hex:hexstr_to_bin(From),
    {ok, ChannelName} = keys:boxOpen(Auth, Nonce, FromPK),
    if
            Channel==ChannelName ->
                    Message = ?JSON(jsonMessage(Msg, MsgNonce)),
                    pubsub:notify(Channel, Message),
                    ?HTTP_OK(Req);
            true ->
                    ?HTTP_FAILED(Req)
    end.

subscribe(Req, DynamicPK, Channel, Nonce, Auth)->
    DPK = hex:hexstr_to_bin(DynamicPK), 
    {ok, ChannelName} = keys:boxOpen(Auth, Nonce, DPK), 
    ?B(["sub", Channel, ChannelName]),
    if 
            Channel==ChannelName ->
                Response = Req:ok({"text/plain", chunked}),
                pubsub:subscribe(Channel),
                message(Response);
            true ->
                ?HTTP_FAILED(Req)
    end.



