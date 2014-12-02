-module(users).
-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([isAlive/1, deleteUidByPid/1, deletePidByUid/1, getPidByUid/1, getUidByPid/1, setUidPid/2, logout/1]).
-export([monShowOnlineId/0, monShowDeadId/0, monShowAllPid/0, monShowAllUid/0]).
-include("../a_include.hrl").

-define(SERVER, global:whereis_name(?MODULE)).


start_link()->
	gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).

isAlive(Uid)->
	gen_server:call(?SERVER, {isAlive, Uid}).

monShowAllUid() ->
	gen_server:call(?SERVER, {monShowAllUid}).

monShowAllPid() ->
	gen_server:call(?SERVER, {monShowAllPid}).

monShowOnlineId()->
	gen_server:call(?SERVER, {monShowOnlineId}).

monShowDeadId()->
	gen_server:call(?SERVER, {monShowDeadId}).


deleteUidByPid(Pid) when is_pid(Pid)->
	gen_server:call(?SERVER, {deleteUidByPid, Pid}).

deletePidByUid(Uid) ->
	gen_server:call(?SERVER, {deletePidByUid, Uid}).

getPidByUid(Uid) ->
	gen_server:call(?SERVER, {getPidByUid, Uid}).

getUidByPid(Pid) when is_pid(Pid)->
	gen_server:call(?SERVER, {getUidByPid, Pid}).

setUidPid(Uid, Pid) when is_pid(Pid)->
	gen_server:call(?SERVER, {setUidPid, Uid, Pid}).

logout(Pid) when is_pid(Pid) ->
	gen_server:call(?SERVER, {logout, Pid}).

handle_call({isAlive, Uid}, _From, State) ->
	Pids = [ P || {_Uid, P} <- ets:lookup(State#state.id2pid, Uid) ],
	Reply = case length(Pids) > 0 of
				true ->
					[Pid | _] = Pids,
					case erlang:is_process_alive(Pid) of
						true ->
							{true, Pid};
						_ ->
							ets:delete(State#state.id2pid, Uid),
							ets:delete(State#state.pid2id, Pid),
							{false}
					end;
				_ ->
					{false}
			end,
	{reply, Reply, State};

handle_call({monShowAllUid}, _From, State)->
	Reply = ets:select(State#state.id2pid, [{{'$1', '$2'}, [], ['$$']}]),
	{reply, Reply, State};

handle_call({monShowAllPid}, _From, State)->
	Reply = ets:select(State#state.pid2id, [{{'$1', '$2'}, [], ['$$']}]),
	{reply, Reply, State};

handle_call({monShowOnlineId}, _From, State)->
	Pids = ets:select(State#state.id2pid, [{{'$1', '$2'}, [], ['$$']}]),
	LiveFilter = fun([_, X])->erlang:is_process_alive(X) end,
	Reply = lists:filter(LiveFilter, Pids),
	{reply, Reply, State};

handle_call({monShowDeadId}, _From, State)->
	Pids = ets:select(State#state.id2pid, [{{'$1', '$2'}, [], ['$$']}]),
	DeadFilter = fun([_,X])->ancode_utils:is_process_dead(X) end,  %%查找属于这个Uid的Pid
	Reply = lists:filter(DeadFilter, Pids),
	{reply, Reply, State};


handle_call({deleteUidByPid, Pid}, _From, State) when is_pid(Pid) ->
	Uids = [ U || {_Pid, U} <- ets:lookup(State#state.pid2id, Pid) ],
	Reply =  case length(Uids)>0 of
		true->
			[Uid|_] = Uids,
			ets:delete(State#state.id2pid, Uid),
			ets:delete(State#state.pid2id, Pid),
			{done, Pid};
		false->
			{false}
	end,
	{reply, Reply, State};


handle_call({deletePidByUid, Uid}, _From, State) ->
	Pids = [ P || {_Uid, P} <- ets:lookup(State#state.id2pid, Uid) ],
	Reply = case length(Pids)>0 of
				true ->
					[Pid | _] = Pids,
					ets:delete(State#state.id2pid, Uid),
					ets:delete(State#state.pid2id, Pid),
					{done, Pid};
				_ ->
					{false}
			end,
	{reply, Reply, State};

handle_call({getPidByUid, Uid}, _From, State)->
	Pids = [ P || {_Uid, P} <- ets:lookup(State#state.id2pid, Uid) ],
	Reply = case length(Pids)>0 of
		true->
			[Pid|_] = Pids,
			{done, Pid};
		false->
			{null}
	end,
	{reply, Reply, State};

handle_call({getUidByPid, Pid}, _From, State) when is_pid(Pid)->
	Uids = [ U || {_Pid, U} <- ets:lookup(State#state.pid2id, Pid) ],
	Reply = case length(Uids)>0 of
		true->
			[Uid|_] = Uids,
			{done, Uid};
		false->
			{null}
	end,
	{reply, Reply, State};

handle_call({setUidPid, Uid, Pid}, _From, State) when is_pid(Pid) ->
	OldPids = [P || {_Uid, P} <- ets:lookup(State#state.id2pid, Uid)] ,
	Reply = case length(OldPids) > 0 of
				true ->
					[OldPid | _] = OldPids,
					case Pid =:= OldPid of
						true ->
							{same, OldPid};
						_ ->
							ets:delete(State#state.pid2id, OldPid),
							ets:insert(State#state.id2pid, {Uid, Pid}), 
							ets:insert(State#state.pid2id, {Pid, Uid}),
							{done, Pid}
					end;
				_ ->
					ets:insert(State#state.id2pid, {Uid, Pid}), 
					ets:insert(State#state.pid2id, {Pid, Uid}),
					{done, Pid}
			end,
	{reply, Reply, State};

handle_call({logout, Pid}, _From, State) when is_pid(Pid) ->
	Uid = ets:lookup(State#state.pid2id, Pid),
	r:delUsedSkey(Uid),
	Pids = [ P || {_Id, P} <- ets:lookup(State#state.id2pid, Uid) ],
	[unlink(Pid1) || Pid1 <- Pids],
	[ets:delete(State#state.pid2id, Pid2) || Pid2 <- Pids],
	Reply = {ok},
	{reply, Reply, State}.


init([]) ->
	?B(["users:init()"]),
	{ok, #state{
			pid2id = ets:new(?MODULE, [set]),
			id2pid = ets:new(?MODULE, [set])
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


