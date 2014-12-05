import nacl.utils
from nacl.public import PrivateKey, Box
from nacl.encoding import HexEncoder
import binascii

def test1():
    skbob = PrivateKey.generate();
    pkbob = skbob.public_key;

    skalice = PrivateKey.generate();
    pkalice = skalice.public_key;

    bob_box = Box(skbob, pkalice);
    alice_box = Box(skalice, pkbob);

    plaintext = b"this daffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffkjdsfkjdsa;lkfdsajf;kdsajf;ss a test";
    nonce = nacl.utils.random(Box.NONCE_SIZE);
    encrypted = bob_box.encrypt(plaintext, nonce);

    decrypted = alice_box.decrypt(encrypted);
    print(binascii.hexlify(encrypted));
    print(plaintext);
    print(decrypted);

def test2():
    plainttext = b"this is a test";
    noncestr = "6025ea0e098619ac91fbe6779404bdd181ddbf3ed3aa36dd";
    nonce = binascii.unhexlify(noncestr);
    print nonce;
    
test1();    
test2();


