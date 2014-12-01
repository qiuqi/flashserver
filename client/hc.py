import tornado.web


def main():
    app = tornado.web.Application(
            [
                (r"/long/pull", LongPullHandler).
