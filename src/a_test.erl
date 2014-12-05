%%% vim: expandtab tabstop=4 shiftwidth=4

-module(a_test).
-compile([export_all]).
-include("a_include.hrl").


test(Req)->
    ?B("test1"),
    test1(),
    test2(),
    test22(),
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
    PlainText = <<"default">>,
    CipherText = salt:crypto_box(PlainText, Nonce, Bpk, Ask),
    ?B(["PlainText", PlainText]),
    ?B(["CipherText", hex:bin_to_hexstr(CipherText)]),
    ?B(["Nonce", hex:bin_to_hexstr(Nonce)]),
    ?B(["Apk", hex:bin_to_hexstr(Apk)]),
    ?B(["Ask", hex:bin_to_hexstr(Ask)]),
    ?B(["Bpk", hex:bin_to_hexstr(Bpk)]),
    ?B(["Bsk", hex:bin_to_hexstr(Bsk)]),
    {ok, Decrypted} = salt:crypto_box_open(CipherText, Nonce, Apk, Bsk),
    compare("test2", PlainText, Decrypted).

test22() ->
    NonceStr = "6025ea0e098619ac91fbe6779404bdd181ddbf3ed3aa36dd",
    ApkStr = "d8efb8f33188f02fccc49949c75ce844e9cccfcc1b793a0bac12bff661777f60",
    AskStr = "bc019fa0b683e8dac31c142c49cbb4c0be85f95c299f45eb2a327ab145ba37ab",
    BpkStr = "72ad84b3c892d879be9127c11350d5cb401e5d35b5450d15ed63ba5417054a09",
    BskStr = "cc90c959714f9b90a9c6ad8875c381cd62a53bf6c6e16705f02b94adea673754",
    %%CipherStr = "0000000000000000000000000000000004c0cc048b93c1adb6a7af07327917f41f3a3ca89ab9eb7cfab59de9ee63b39b324aa98fd4e01fd9e5fe7e98cb04",
    CipherStr = "04c0cc048b93c1adb6a7af07327917f41f3a3ca89ab9eb7cfab59de9ee63b39b324aa98fd4e01fd9e5fe7e98cb04",
    Nonce = hex:hexstr_to_bin(NonceStr),
    Apk = hex:hexstr_to_bin(ApkStr),
    Ask = hex:hexstr_to_bin(AskStr),
    Bpk = hex:hexstr_to_bin(BpkStr),
    Bsk = hex:hexstr_to_bin(BskStr),
    Cipher = hex:hexstr_to_bin(CipherStr),
    {ok, Decrypted} = salt:crypto_box_open(Cipher, Nonce, Apk, Bsk),
   compare("test22", "why", Decrypted). 


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


