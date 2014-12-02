%%% vim: expandtab tabstop=4 shiftwidth=4

-module(j).
-author('qiuqi<qiuqi@ancode.org>').
-compile([export_all]).
-include("a_include.hrl").

http_show_json(Req, Json)->
    Re =binary_to_list(list_to_binary(mochijson2:encode(Json))),
    Req:ok({"application/json;charset=UTF-8", [], Re}).

http_show_json(Req, ResHeader, Json)->
    Re =binary_to_list(list_to_binary(mochijson2:encode(Json))),
    %%?B(["json:", Re]),
    Req:ok({"application/json;charset=UTF-8", ResHeader, Re}).


encodeInit()->
    [].
add(Key, Value, Json)->
    [{Key, Value}|Json].
getBin(Json)->
    list_to_binary(mochijson2:encode(Json)).
getString(Json)->
    binary_to_list(list_to_binary(mochijson2:encode(Json))).


decodeInit(JsonString)->
    {struct, JsonData} = mochijson2:decode(JsonString),
    JsonData.
getValue(Key, JsonData)->
    proplists:get_value(Key, JsonData).



%% unit test
testEncode()->
    A = encodeInit(),
    B = add("key1", <<"value1">>, A),
    C = add("key2", 3, B),
    D = add(key3, "itesttesttestvalue3", C),
    E = getBin(D),
    F = getString(D),
    {A,B,C,D,E,F}.

testDecode()->
    A = "{\"key1\":\"value1\", \"key2\":3, \"key3\":\"value3\"}",
    B = decodeInit(A),
    C = getValue(<<"key1">>, B),
    D = getValue(<<"key2">>, B),
    E = getValue(<<"key3">>, B),
    {A,B,C,D,E}.

jsonOk()->
    {struct,
     [
      {"type", ?U("bool")},
      {"value", ?U("true")}
     ]}.
jsonFailed()->
    {struct,
     [
      {"type", ?U("bool")},
      {"value", ?U("false")}
     ]}.
