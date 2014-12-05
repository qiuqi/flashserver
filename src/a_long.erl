%%% vim: expandtab tabstop=4 shiftwidth=4
-module(a_long).
-export([pull/2, push/1]).
-export([subscribe/6]).
-export([publish/1]).
-export([test_publish/1]).
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
            void;
        {_Pid, _Tag, Message} ->
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
            {"type", ?U("Message")},
            {"nonce", ?U(Nonce)},
            {"body", ?U(Message)}
            ]}.

publish(Req)->
    QS = Req:parse_post(),
    From = ?GETVALUE("from", QS),
    Channel = ?GETVALUE("channel", QS),
    Nonce = ?GETVALUE("nonce", QS),
    Auth = ?GETVALUE("auth", QS),
    MsgNonce = ?GETVALUE("msg_nonce", QS),
    Msg = ?GETVALUE("msg", QS),
    case publish_core(From, Channel, Nonce, Auth, MsgNonce, Msg) of
        true ->
            ?HTTP_OK(Req);
        false ->
            ?HTTP_FAILED(Req)
    end.


test_publish(Req)->
    From = "7d065f1386aed340c964ad6d7f8e08452279c1aa0c5d598f91a0150cdb12695e",
    Channel = "default",
    Nonce = "000000000001417747086284",
    Auth = "9f9c2f5785d933",
    MsgNonce = "000000000001417747086285",
    Msg = "bde9fc18",
    case publish_core(From, Channel, Nonce, Auth, MsgNonce, Msg) of
        true ->
            ?HTTP_OK(Req);
        false ->
            ?HTTP_FAILED(Req)
    end.


publish_core(From, Channel, Nonce, Auth, MsgNonce, Msg)->
    FromPK = hex:hexstr_to_bin(From),
    {ok, ServerSK} = keys:getServerSKBin(),
    {ok, ChannelName} = salt:crypto_box_open(hex:hexstr_to_bin(Auth), list_to_binary(Nonce), FromPK, ServerSK),
    case list_to_binary(Channel) =:= ChannelName of
        true ->
            ChannelId = From ++ "." ++ Channel,
            Message = ?JSON(jsonMessage(Msg, MsgNonce)),
            pubsub:notify(ChannelId, Message),
            true;
        false ->
            false
    end.


subscribe(Req, PubIdentityKey, SubIdentityKey, Channel, Nonce, Auth)->
    SubIdentityKeyBin = hex:hexstr_to_bin(SubIdentityKey), 
    {ok, ChannelName} = keys:boxOpen(base64:decode(Auth), Nonce, SubIdentityKeyBin), 
    case list_to_binary(Channel) =:= ChannelName of
        true ->
            Response = Req:ok({"text/plain", chunked}),
            ChannelId = PubIdentityKey++"."++Channel, 
            pubsub:subscribe(ChannelId),
            message(Response);
        false ->
            ?HTTP_FAILED(Req)
    end.
