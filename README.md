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


-------------------------------------------------------------------------
安装使用
1、在Erlang最新版本下保持测试
2、需要安装https://github.com/freza/salt

