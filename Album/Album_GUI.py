#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import tkinter as tk
from PIL import ImageTk, Image
import os
import threading
import socket
import sys
import xml_parse
# startup runing:       
#                       https://medium.com/@arslion/starting-python-gui-program-on-raspberry-pi-startup-56fb4e451cc1
#
# src:
#   load image:         https://www.c-sharpcorner.com/blogs/basics-for-displaying-image-in-tkinter-python
#   loading jpg file:   https://stackoverflow.com/questions/23901168/
#   resize:             https://www.tutorialspoint.com/how-to-resize-an-image-using-tkinter
#   multi files:        https://stackoverflow.com/questions/46625722/
#   close windows:      https://stackoverflow.com/questions/111155/
#   remove/forget:      https://stackoverflow.com/questions/3962247/

#   fullscreen:         https://stackoverflow.com/questions/7966119/

#   canavs text:        https://stackoverflow.com/questions/17736967/
#   canvas text anchor: https://docs.huihoo.com/tkinter/tkinter-reference-a-gui-for-python/create_text.html

# pending:
#   PanedWindow:        https://stackoverflow.com/questions/60122678/ # a draggable panel
#   lock_windows:       https://stackoverflow.com/questions/53358014/ # disable alt+f4

# socket:
#   Code from:          https://pymotw.com/2/socket/tcp.html
#   local stop:         https://stackoverflow.com/questions/16734534/
#
# Thread:
#   stop:               https://blog.miguelgrinberg.com/post/how-to-kill-a-python-thread


"""
class photo:
    def __init__():
"""

# get the local ip
cmd = 'hostname -I | awk \'{print $1}\''
ip = os.popen(cmd).read().strip("\n") # https://stackoverflow.com/questions/3503879/
pt = 1025

# folder = '/home/pi/Album/photos'
# other_folder = '/media/pi/*/photos'
folder = 'photos'


exit_event = threading.Event()
force_closing = False
    
def photo(folder, photo_file, window):
    canvas = tk.Canvas(window, width=100, height=115)
    canvas.pack(side="bottom", fill="both", expand="yes")

    img = Image.open(folder+"/"+photo_file)
    resize_img = img.resize((90, 90), Image.ANTIALIAS)
    imgtk = ImageTk.PhotoImage(resize_img)

    canvas.create_image(6, 6, anchor=tk.NW, image=imgtk)
    font_size = 12
    canvas.create_text(100,115, anchor=tk.SE,fill="black",font="Times "+str(font_size)+" italic bold",
                        text=photo_file)
                        
    # Reason for the next line: To keep reference
    #   https://web.archive.org/web/20201111190625id_/http://effbot.org/pyfaq/why-do-my-tkinter-images-not-appear.htm
    canvas.imgtk = imgtk

    # canvas.grid(padx=6, pady=6)
    return canvas


class color:    
    green_light = "#99fb99"
    red_light = "#fb9999"
    purple = "#9999fb"
    gray="#e3e3e3"
    green_gray="#d5e8d4"

    blue_dark_gray = "#496da6"
    blue_gray = "#a9bbd6"
    white_gray = "#eeefee"
    purple_light ="#e6e9ff"
    blue_light = "#c2e5f2"

    brown_dark = "#330f05"
    toffee = "#dd9d58"
    brown = "#9d6828"
    coffee = "#77441a"
    brown_gray = "#7d5032"

    cursor_blue = "#36a4ff"

def load_photos(pane):
    all_photos = os.listdir(folder)
    all_canvas = []
    all_frames = []
    col_limit = 8
    num_photos = len(all_photos)
    
    if num_photos == 0:
        rows = 0
    else:
        rows = ((num_photos - 1) // col_limit) + 1
    
    for row in range(rows):
        cols = (num_photos - row * col_limit)
        for col in range(col_limit):
            index = row * col_limit + col
            if index < num_photos:
                f = tk.Frame(pane, background="white",
                            bd=0, relief="flat", width=100, height=115)
                f.grid(row=row, column=col, padx=6, pady=6)
                all_canvas.append(photo(folder, all_photos[index],f))
                all_frames.append(f)
    return all_canvas, all_frames, all_photos, num_photos, col_limit


def cursor_socket(main_l, left_pane_l, right_pane_l, all_canvas_l, all_frame_l, all_photos_l, n, c):

    # Create a TCP/IP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # Bind the socket to the port
    # server_address = ('localhost', pt)
    server_address = (ip, pt)
    print (sys.stderr, 'starting up on %s port %s' % server_address)
    sock.bind(server_address)

    # Listen for incoming connections
    sock.listen(1)

    cursor = 0
    all_canvas_l[cursor].configure(bg=color.cursor_blue)

    stop = False
    entered = False
    canvas_l = None
    while not stop:
        # Wait for a connection
        print(sys.stderr, 'waiting for a connection')
        connection, client_address = sock.accept()
        
        try:
            print(sys.stderr, 'connection from', client_address)

            # Receive the data in small chunks and retransmit it
            while not stop:
                data = connection.recv(16)
                # print (sys.stderr, 'received "%s"' % data)
                print (sys.stderr, 'received "%s"' % data.decode()) # reason for decoding: https://stackoverflow.com/questions/40335581/
                if data:
                    line = data.decode()
                    if line == "up":
                        if cursor - c >= 0:
                            all_canvas_l[cursor].configure(bg='white')
                            cursor -= c
                    elif line == "left":
                        if cursor -1 >= 0:
                            all_canvas_l[cursor].configure(bg='white')
                            cursor -= 1
                    elif line == "right":   
                        if cursor +1 < n:
                            all_canvas_l[cursor].configure(bg='white')
                            cursor += 1 
                    elif line == "down":      
                        if cursor + c < n:
                            all_canvas_l[cursor].configure(bg='white')
                            cursor += c
                    elif line == "enter":    
                        if not entered:                    
                            img = Image.open(folder+"/"+ all_photos_l[cursor])
                            h = w = 0
                            if (img.height / 75) * 128 >= img.width:
                                h = int((img.height / img.width) * 600)
                                w = 600
                            else:
                                h = 1024
                                w = int((img.width / img.height) * 1024)

                            canvas_l = tk.Canvas(main_l, width=1024, height=600)      
                            canvas_l.configure(bg='black')     
                            canvas_l.pack(side="bottom", fill="both", expand="yes")                      
                            resize_img_l = img.resize((w, h), Image.ANTIALIAS)         
                            imgtk_l = ImageTk.PhotoImage(resize_img_l)                            
                            canvas_l.create_image(512 - w//2,0,anchor=tk.NW, image=imgtk_l)
                            left_pane_l.pack_forget()
                            right_pane_l.pack_forget()
                            print()
                            entered = True
                        else:
                            if canvas_l is not None:
                                canvas_l.pack_forget()
                                canvas_l.destroy()

                            left_pane_l.pack(side="left", fill="y",)
                            right_pane_l.pack(side="right", fill="y",)
                            print()
                            entered = False
                        print("hi")
                                  
                    elif line == "delete":   
                        all_canvas_l[cursor].pack_forget()
                        all_frame_l[cursor].grid_forget()
                        all_canvas_l[cursor].destroy()
                        all_frame_l[cursor].destroy()
                        os.remove(folder+"/"+all_photos_l[cursor])       

                        right_pane_l.pack_forget()
                        right_pane_l.destroy()
                        right_pane = tk.Frame(main_l, background=right_pane_bg, width=896) 
                        # main_l.right_pane = right_pane
                        all_canvas_l, all_frame_l, all_photos_l, n, c = load_photos(right_pane)  
                        right_pane.pack(side="right", fill="y",)  
                        if cursor >= n:
                            cursor = n-1      

                    all_canvas_l[cursor].configure(bg=color.cursor_blue)
                    print (sys.stderr, 'sending data back to the client')
                    connection.send(data)
                else:
                    print (sys.stderr, 'no more data from', client_address)
                    break

                if exit_event.is_set():
                    print(exit_event.is_set)
                    stop = True       
                    print("inner stop is: " + str(stop))
                    break
        finally:
            # Clean up the connection
            print("finally")
            connection.close()        
        if exit_event.is_set():
            print(exit_event.is_set)
            stop = True      
            print("outer stop is: " + str(stop))
            break  
    print("end")
    sock.close()  
    print("end2")
    sys.exit()
    print("end3")
            
def on_closing():  
    exit_event.set()
    socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((ip, pt))
    root.destroy()        

if __name__ == '__main__':
    try:
        high_contrast = False
        if high_contrast:
            toolbar_bg = color.green_gray
            statusbar_bg = color.gray
            main_bg = color.green_light
            left_pane_bg = color.red_light
            right_pane_bg = color.purple
        else:        
            toolbar_bg = color.brown_gray
            statusbar_bg = color.brown_gray
            main_bg = color.brown
            left_pane_bg = color.brown
            right_pane_bg = color.toffee


        

        root = tk.Tk()
        root.geometry("1024x600")
        root.title("Digital Photo Album")

        toolbar = tk.Frame(root, background=toolbar_bg, height=40)  # gray green
        statusbar = tk.Frame(root, background=statusbar_bg, height=20)  # gray
        main = tk.Frame(root, background=main_bg)
        

        toolbar.pack(side="top", fill="x",)
        statusbar.pack(side="bottom", fill="x",)
        main.pack(side="top", fill="both", expand=True)

        #### =====================================
        
        left_pane = tk.Frame(main, background=left_pane_bg, width=108)
        right_pane = tk.Frame(main, background=right_pane_bg, width=896) 
        
        left_pane.pack(side="left", fill="y",)
        right_pane.pack(side="right", fill="y",)

        #### =====================================

        l1 = tk.Label(left_pane, text="motion delay: {}".format(xml_parse.get_motion_dark_delay()))
        l2 = tk.Label(left_pane, text="light delay: {}".format(xml_parse.get_light_dark_delay()))
        l3 = tk.Label(left_pane, text="light threshold: {}".format(xml_parse.get_light_threshold()))
        l1.grid(row=0,column=0)
        l2.grid(row=1,column=0)
        l3.grid(row=2,column=0)

        #### =====================================
        all_canvas, all_frames, all_photos, num_photos, col_limit = load_photos(right_pane)
        # cursor = 0
        # all_canvas[cursor].configure(bg=color.cursor_blue)
        
        x = threading.Thread(target=cursor_socket, args=(main, left_pane, right_pane, all_canvas, all_frames, all_photos, num_photos, col_limit))
        x.start()

        #### =====================================

        # https://stackoverflow.com/questions/111155/
        root.protocol("WM_DELETE_WINDOW", on_closing)
        root.mainloop()
    except KeyboardInterrupt:    
        exit_event.set()
        socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((ip, pt))

