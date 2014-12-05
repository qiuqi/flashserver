-module(keys).
-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([getServerPK/0, getServerSK/0]).
-export([getServerPKBin/0, getServerSKBin/0]).
-export([boxOpen/3]).
-include("../a_include.hrl").

-define(SERVER, global:whereis_name(?MODULE)).


start_link()->
	gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).

boxOpen(Cipher, Nonce, Apk)->
    gen_server:call(?SERVER, {boxOpen, Cipher, Nonce, Apk}).

getServerPK()->
	gen_server:call(?SERVER, {getServerPK}).

getServerSK()->
    gen_server:call(?SERVER, {getServerSK}).

getServerPKBin()->
	gen_server:call(?SERVER, {getServerPKBin}).

getServerSKBin()->
    gen_server:call(?SERVER, {getServerSKBin}).

handle_call({boxOpen, Cipher, Nonce, Apk}, _From, State)->
    ServerSK = State#skeypair.sk,
    ?B(["Cipher", Cipher]),
    ?B(["Nonce", Nonce]),
    ?B(["Apk", Apk]),
    ?B(["ServerSK", ServerSK]),
    Reply = salt:crypto_box_open(Cipher, Nonce, Apk, ServerSK),
    {reply, Reply, State};

handle_call({getServerPK}, _From, State)->
	Reply = {ok, State#skeypair.pk_hex},
	{reply, Reply, State};

handle_call({getServerSK}, _From, State)->
    Reply = {ok, State#skeypair.sk_hex},
    {reply, Reply, State};

handle_call({getServerPKBin}, _From, State)->
	Reply = {ok, State#skeypair.pk},
	{reply, Reply, State};

handle_call({getServerSKBin}, _From, State)->
    Reply = {ok, State#skeypair.sk},
    {reply, Reply, State}.


init([]) ->
	?B(["users:init()"]),
	{ServerPk, ServerSk} = salt:crypto_box_keypair(),
	{ok, #skeypair{
		pk = ServerPk,
		sk = ServerSk,
		pk_hex = hex:bin_to_hexstr(ServerPk),
		sk_hex = hex:bin_to_hexstr(ServerSk)
		}
	}.

handle_cast(_Msg, State)->
	{noreply, State}.

handle_info(Info, State)->
	case Info of
		{'EXIT', Pid, _Why}->
			handle_call({logout, Pid}, blah, State);
		Wtf->
			io:format("Caught unhandled message: ~w\n", [Wtf])
	end,
	{noreply, State}.

terminate(_Reason, _State)->
	ok.

code_change(_OldVsn, State, _Extra)->
	{ok, State}.


