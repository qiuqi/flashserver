import nacl.utils
from nacl.public import PrivateKey, Box
from nacl.encoding import HexEncoder

skbob = PrivateKey.generate();
pkbob = skbob.public_key;

skalice = PrivateKey.generate();
pkalice = skalice.public_key;

bob_box = Box(skbob, pkalice);
alice_box = Box(skalice, pkbob);

plaintext = b"this is a test";
nonce = nacl.utils.random(Box.NONCE_SIZE);
encrypted = bob_box.encrypt(plaintext, nonce);

decrypted = alice_box.decrypt(encrypted);

print(plaintext);
print(decrypted);


