#!/usr/bin/env python3
"""Simple HTTPS server to serve the apple-app-site-association file.

Usage: python3 serve_aasa.py --cert cert.pem --key key.pem --port 8001

Place the `apple-app-site-association` file at `./Example/.well-known/apple-app-site-association`.
"""
import argparse
import http.server
import ssl
import os


class AASAHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        if self.path.endswith("apple-app-site-association"):
            self.send_header("Content-Type", "application/json")
        super().end_headers()


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--cert", required=True, help="Path to certificate (PEM)")
    p.add_argument("--key", required=True, help="Path to private key (PEM)")
    p.add_argument("--port", type=int, default=8001)
    args = p.parse_args()

    root = os.path.join(os.getcwd())
    os.chdir(root)

    server_address = ("0.0.0.0", args.port)
    httpd = http.server.HTTPServer(server_address, AASAHandler)
    httpd.socket = ssl.wrap_socket(httpd.socket, certfile=args.cert, keyfile=args.key, server_side=True)
    print(f"Serving AASA at https://0.0.0.0:{args.port}/.well-known/apple-app-site-association")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("Stopping server")


if __name__ == '__main__':
    main()
