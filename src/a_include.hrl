%%% vim: expandtab tabstop=4 shiftwidth=4

-ifndef(A_INCLUDE_HRL).
-define(A_INCLUDE_HRL, ok).

%%-define(B(F), log4erl:info("~p:~p ~p", [?MODULE, ?LINE, F])).
-define(B(F), lager:log(info, "flash", "~p:~p ~p", [?MODULE, ?LINE, F])).
-define(R_STORE, r_store).

-define(U(F), unicode:characters_to_binary(F)).

-define(GETVALUE(K, L), proplists:get_value(K, L)).
-define(B64(F), base64:encode(F)).

-define(HTTP_OK(F), j:http_show_json(F, j:jsonOk())).
-define(HTTP_FAILED(F), j:http_show_json(F, j:jsonFailed())).

-endif.
