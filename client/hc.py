import tornado.ioloop
from tornado.httpclient import AsyncHTTPClient
from tornado import httpclient


def on_chunk(chunk):
    print("ok")
    print(chunk)

requests = [
        httpclient.HTTPRequest(
            url='http://42.121.114.160:8080/long/pull',
            streaming_callback=on_chunk
            )]

http_client = AsyncHTTPClient()
http_client.fetch("http://127.0.0.1:8080/long/pull", streaming_callback=on_chunk, request_timeout=1000000.0)
tornado.ioloop.IOLoop.instance().start()
