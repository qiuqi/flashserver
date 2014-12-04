flashserver
===========

based on mada's suggestion.


1. 实现目标
   实现在任意两个节点之间的安全通知

2. 单节点通知过程
   假设节点A, 产生公私钥对Apk, Ask
   Apk就是节点的标识符号
   节点A,发起一个长连接: http get http://www.somesite.com/wait/{apkstring}
   节点B,向节点A发送一个消息， http post http://www.somesite.com/send/{apkstring}

   * message:"encrypted Message",
   * key:利用公钥加密的对称密钥,
   * from:节点B的公钥
   * nonce:随机字符串

   A将收到信息，格式如下：

    {
        "message":"Encrypted Message",
        "key":利用公钥加密的对称密钥,
        "from":"消息发起端的公钥字符串",
        "to":"消息接收端的公钥字符串",
        "nonce":"随机字符串"
    }


3. 推送
```
POST /publish

from={pub_identity_key}
channel=xxxx
nonce=yyyy
auth=box({channel}, {nonce}, {ServePub}, {pub_identity_privkey})
msg_nonce=xxxxxxx
msg=box({msg_plain}, {msg_nonce}, {dynamic_public_key}, {dynamic_private_key})


注意： server端并不需要关心msg的box实现，它的内容是由pub方自己负责的， server端只需要对auth内容认证，验证auth的内容确实是由{channel}实现的。

返回：
{ "type" : "Accept", "value" : true/false}
```

4. 订阅
```
GET /subscribe/{sub_identity_key}/{channel}/{nonce}/{auth}
其中auth=box({channel}, {nonce}, {ServePub}, {sub_identity_private_key})

{ "type" : "message", "nonce" : {msg_nonce}, "body" : {msg}}
subscribe需要对msg解密，方式为
msg_plain=box_open({msg}, {msg_nonce}, {dynamic_public_key}, {dynamic_private_key})
或
{ "type" : "Accept", "value" : false}

注意： server端需要对auth认证，如果认证成功，则允许sub接收到{channel}内的msg，如果失败，返回错误。
```

-------------------------------------------------------------------------

安装使用
========
1. 在Erlang最新版本下保持测试
2. 需要安装https://github.com/freza/salt

