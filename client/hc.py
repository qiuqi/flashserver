import tornado.ioloop
from tornado.httpclient import AsyncHTTPClient
from tornado import httpclient

TestUrl = 'http://127.0.0.1:8080/long/pull/tag'

def on_chunk(chunk):
    print("ok")
    print(chunk)

http_client = AsyncHTTPClient()
http_client.fetch(TestUrl, streaming_callback=on_chunk, request_timeout=1000000.0)
tornado.ioloop.IOLoop.instance().start()
