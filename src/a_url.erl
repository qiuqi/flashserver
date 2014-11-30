-module(a_url).
-export([get_url_dispatch/3, post_url_dispatch/3, put_url_dispatch/3]).
-include("a_include.hrl").

get_url_dispatch(Req, DocRoot, Path) ->
	ListPath = string:tokens(Path, "/"),
	case ListPath of
            ["test", "test"]->a_test:test(Req);
            _ -> 
                    Req:serve_file(Path, DocRoot)
    end.

post_url_dispatch(Req, _DocRoot, Path) ->
        ListPath = string:tokens(Path, "/"),
        case ListPath of
                ["getkey"]->a_key:getkey(Req);
                ["login"] ->a_login:login(Req);
                _ -> Req:not_found()
        end.

put_url_dispatch(Req, _, Path) ->
        ListPath = string:tokens(Path, "/"),
        case ListPath of
                _ -> Req:not_found()
        end.


