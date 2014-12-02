%%% vim: expandtab tabstop=4 shiftwidth=4

-module(a_url).
-export([get_url_dispatch/3, post_url_dispatch/3, put_url_dispatch/3]).
-include("a_include.hrl").

get_url_dispatch(Req, DocRoot, Path) ->
    ListPath = string:tokens(Path, "/"),
    case ListPath of
            ["test", "test"]->a_test:test(Req);
            ["long", "pull", Pubkey]->a_long:pull(Req, Pubkey);
            ["server", "pubkey"]->a_server:pubkey(Req);
            ["subscribe", DynamicPK, Channel, Nonce, Auth]->a_long:subscribe(Req, DynamicPK, Channel, Nonce, Auth);
        _ -> 
            Req:serve_file(Path, DocRoot)
    end.

post_url_dispatch(Req, _DocRoot, Path) ->
    ListPath = string:tokens(Path, "/"),
    case ListPath of
            ["long", "push"]->a_long:push(Req);
            ["public"]->a_long:publish(Req);
        _ -> Req:not_found()
    end.

put_url_dispatch(Req, _, Path) ->
    ListPath = string:tokens(Path, "/"),
    case ListPath of
        _ -> Req:not_found()
    end.


