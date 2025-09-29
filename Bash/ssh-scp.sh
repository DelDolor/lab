# connect from windows host to linux server and downolad file xxx.txt
scp -i "C:\Users\zzz\.ssh\aaa.pem" user@server.com:~/folder/xxx.txt "C:\Users\zzz\Downloads\xxx.txt"