-module(pubsub).

-export([subscribe/1,
         notify/2]).

subscribe(EventType) ->
    %% Gproc notation: {p, l, Name} means {(p)roperty, (l)ocal, Name}
    gproc:reg({p, l, {?MODULE, EventType}}).

notify(EventType, Msg) ->
    Key = {?MODULE, EventType},
    gproc:send({p, l, Key}, {self(), Key, Msg}).
