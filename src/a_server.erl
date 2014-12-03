-module(a_server).
-export([pubkey/1]).
-include("a_include.hrl").


jsonServerPk(ServerPk)->
    {struct,
     [
      {"type", ?U("ServerPubKey")},
      {"r", ?U("ok")},
      {"serverpk", ?U(ServerPk)}
     ]}.

pubkey(Req)->
    {ok, ServerPk} = keys:getServerPK(),
    j:http_show_json(Req, jsonServerPk(ServerPk)).
