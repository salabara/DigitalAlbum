#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Code from: https://pymotw.com/2/socket/tcp.html

import socket
import sys
import os
import subprocess

def main():
    # get the local ip
    cmd = 'hostname -I | awk \'{print $1}\''
    ip = os.popen(cmd).read().strip("\n") # https://stackoverflow.com/questions/3503879/
    pt = 1025

    # Create a TCP/IP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # Bind the socket to the port
    # server_address = ('localhost', pt)
    server_address = (ip, pt)
    print (sys.stderr, 'starting up on %s port %s' % server_address)
    sock.bind(server_address)

    # Listen for incoming connections
    sock.listen(1)
    try:
        hello = subprocess.Popen(["/home/album/hello.py", "asd", "123"], stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.STDOUT,text=True)

        while True:
            # Wait for a connection
            print(sys.stderr, 'waiting for a connection')
            connection, client_address = sock.accept()
            
            try:
                print(sys.stderr, 'connection from', client_address)

                # Receive the data in small chunks and retransmit it
                while True:
                    data = connection.recv(16)
                    # print (sys.stderr, 'received "%s"' % data)
                    print (sys.stderr, 'received "%s"' % data.decode()) # reason for decoding: https://stackoverflow.com/questions/40335581/
                    if data:
                        line = data.decode()
                        if line == "stop":
                            hello.terminate()
                        elif line == "write":
                            poll = hello.poll()
                            if poll is None:
                                hello.stdin.write("Hi from parent\n")
                                hello.stdin.flush()
                        elif line == "read":    
                            if hello.stdout.readable():
                                line = hello.stdout.readline()
                                print("Read: " + line)
                        elif line == "run":                    
                            poll = hello.poll()
                            if poll is None:                        
                                hello.terminate()
                            hello = subprocess.Popen(["/home/album/hello.py", "asd", "123"], stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.STDOUT,text=True)


                        print (sys.stderr, 'sending data back to the client')
                        connection.send(data)
                    else:
                        print (sys.stderr, 'no more data from', client_address)
                        break
                    
            finally:
                # Clean up the connection
                connection.close()
                
    except KeyboardInterrupt:
        hello.terminate()
            

if __name__ == '__main__':
    main()
