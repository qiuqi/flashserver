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
    receive
        cancel->
            void;
        {_Pid, _Tag, Message} ->
            http_show(Response, Message),
            message(Response)
    after 1000->
            http_show(Response, mochijson2:encode([{<<"type">>, <<"Time">>}, {<<"time">>, list_to_binary(utils:longtime_list())}])),
            message(Response)
    end.



push(Req)->
    QS = Req:parse_post(),
    Pubkey = ?GETVALUE("pubkey", QS),
    Message = ?GETVALUE("message", QS),
    pubsub:notify(Pubkey, Message),
    ?HTTP_OK(Req).

jsonMessage(Message)->
    {struct,
     [
            {"type", ?U("Message")},
            {"body", ?U(Message)}
            ]}.

publish(Req)->
    QS = Req:parse_post(),
    From = ?GETVALUE("from", QS),
    Channel = ?GETVALUE("channel", QS),
    Nonce = ?GETVALUE("nonce", QS),
    Auth = ?GETVALUE("auth", QS),
    Msg = ?GETVALUE("msg", QS),
    case publish_core(From, Channel, Nonce, Auth, Msg) of
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
    Msg = "bde9fc18",
    case publish_core(From, Channel, Nonce, Auth, Msg) of
        true ->
            ?HTTP_OK(Req);
        false ->
            ?HTTP_FAILED(Req)
    end.


publish_core(From, Channel, Nonce, Auth, Msg)->
    FromPK = hex:hexstr_to_bin(From),
    {ok, ServerSK} = keys:getServerSKBin(),
    {ok, ChannelName} = salt:crypto_box_open(hex:hexstr_to_bin(Auth), list_to_binary(Nonce), FromPK, ServerSK),
    case list_to_binary(Channel) =:= ChannelName of
        true ->
            ChannelId = From ++ "." ++ Channel,
            Message = ?JSON(jsonMessage(Msg)),
            pubsub:notify(ChannelId, Message),
            true;
        false ->
            false
    end.


subscribe(Req, PubIdentityKey, SubIdentityKey, Channel, Nonce, Auth)->
    SubIdentityKeyBin = hex:hexstr_to_bin(SubIdentityKey), 
    {ok, ChannelName} = keys:boxOpen(hex:hexstr_to_bin(Auth), list_to_binary(Nonce), SubIdentityKeyBin), 
    case list_to_binary(Channel) =:= ChannelName of
        true ->
            Response = Req:ok({"text/plain", chunked}),
            ChannelId = PubIdentityKey++"."++Channel, 
            pubsub:subscribe(ChannelId),
            message(Response);
        false ->
            ?HTTP_FAILED(Req)
    end.
