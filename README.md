# Python-Scripts
share some useful python scripts

### pwn.sh :a shell script for implementing pwn subjects in a CTF

- Usage: 

        "Usage: pwn [-h|-v|-l <pwn-name>|-d <pwn-name>|-u <pwn-name>|-s] [--bianry <binary>] [--port <server-port>] [--flag <string-flag>]" 
        "Options:"
        "  -h,--help"
        "  -v,--version"
        "  -l  <pwn-name>     #loading a pwn server"
        "  -d  <pwn-name>     #delete a pwn server"
        "  -u  <pwn-name>     #unload a pwn server"
        "  -s,--start                    #start a pwn server, more args should be given"
        "  --binary <executable-file>  #pwn server"
        "  --flag   <string-flag>       #pwn flag"
        "  --port   <port-number>       #less than 65535"`
- Eg:
    - start a ctf server
        `$sudo pwn.sh -s --binary /home/xxx/ctf_binary_name --port 33333 --flag flag{test_ctf}`
    - unload a ctf server
        `$sudo pwn.sh -u ctf_binary_name`
    - reload a ctf server
        `$sudo pwn.sh -l ctf_binary_name`
    - delete a ctf server
        `$sudo pwn.sh -d ctf_binary_name`
