%%% vim: expandtab tabstop=4 shiftwidth=4

-module(a_test).
-compile([export_all]).
-include("a_include.hrl").


test(Req)->
    ?B("test1"),
    test1(),
    test2(),
    test3(),
    test4(),
    test5(),
    test6(),

    ?HTTP_OK(Req).
%%测试用例1
%%用自己的公私钥加密，再用自己的公私钥解密
test1()->
    Nonce = salt:crypto_random_bytes(24),
    {Apk, Ask}= salt:crypto_box_keypair(),
    PlainText = <<"Hello Bob, message from Alice.">>,
    CipherText = salt:crypto_box(PlainText, Nonce, Apk, Ask),
    ?B(["keypair", hex:bin_to_hexstr(Apk), hex:bin_to_hexstr(Ask)]),
    ?B(["keypair", base64:encode(Apk), base64:encode(Ask)]),
    {ok, Decrypted} = salt:crypto_box_open(CipherText, Nonce, Apk, Ask),
    compare("test1", PlainText, Decrypted).

%%测试用例2
%%A用B的公钥和自己的私钥加密
%%B用A的公钥和自己的私钥解密
test2()->
    Nonce = salt:crypto_random_bytes(24),
    {Apk, Ask}= salt:crypto_box_keypair(),
    {Bpk, Bsk}= salt:crypto_box_keypair(),
    PlainText = <<"Hello Bob, message from Alice.">>,
    CipherText = salt:crypto_box(PlainText, Nonce, Bpk, Ask),
    {ok, Decrypted} = salt:crypto_box_open(CipherText, Nonce, Apk, Bsk),
    compare("test2", PlainText, Decrypted).

%%测试用例3
%%用生成的Context进行多次加密解密
test3()->
    Nonce = salt:crypto_random_bytes(24),
    {Apk, Ask}= salt:crypto_box_keypair(),
    {Bpk, Bsk}= salt:crypto_box_keypair(),
    Ac = salt:crypto_box_beforenm(Bpk, Ask),
    Bc = salt:crypto_box_beforenm(Apk, Bsk),
    P1 = <<"test 1 sdfdsafdsafdsafdsafdsafdsafffffffffffffffffffffffffffff">>,
    P2 = <<"test 2 sdfdsafdsafdsafdsafdsafdsafffffffffffffffffffffffffffff">>,
    C1 = salt:crypto_box_afternm(P1, Nonce, Ac),
    C2 = salt:crypto_box_afternm(P2, Nonce, Ac),
    {ok, D1} = salt:crypto_box_open_afternm(C1, Nonce, Bc),
    {ok, D2} = salt:crypto_box_open_afternm(C2, Nonce, Bc),
    compare("test3", P1, D1),
    compare("test3", P2, D2).

%%测试用例4
%%测试对称加密算法
test4()->
    SecretKey = salt:crypto_random_bytes(32),
    Nonce     = salt:crypto_random_bytes(24),
    PlainText = <<"Secret message with中文">>,
    Encrypted = salt:crypto_secretbox(PlainText, Nonce, SecretKey),
    {ok, Decrypted} = salt:crypto_secretbox_open(Encrypted, Nonce, SecretKey),
    compare("test4", PlainText, Decrypted).

%%
test5()->
    {Apk, Ask}= salt:crypto_sign_keypair(),
    PlainText = <<"Plain text to be signed">>,
    Sm = salt:crypto_sign(PlainText, Ask),
    {ok, Verify} = salt:crypto_sign_open(Sm, Apk),
    compare("test5", PlainText, Verify).

test6()->
    Sk = salt:crypto_random_bytes(32),
    Pt = <<"Authentic message.">>,
    Au = salt:crypto_onetimeauth(Pt, Sk),
    ?B(["Au:", Au]),
    V1 = salt:crypto_onetimeauth_verify(Au, Pt, Sk),
    receive
    after 30000->
        ok
    end,
    V2 = salt:crypto_onetimeauth_verify(Au, Pt, Sk),
    ?B(["verify:", V1, V2]).







compare(L, X, Y) when X/=Y ->
    ?B([L, "failed", ?U(X), ?U(Y)]);
compare(L, X, Y)->
    ?B([L, "pass", ?U(X), ?U(Y)]).


