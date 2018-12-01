# Auto-SSH-Shell-Script

## General Information

A simple linux script to automatically connect to ssh servers one at a time from a list and execute the same remote commands on each server. All remote command results are saved to a log file.

SSH connections are automated using `sshpass` (`apt-get install sshpass` on ubuntu/debian).

Tested with ubuntu 16.04 but should run on most other linux distros.

**NOTE:** This script requires you to save ssh credentials in plain-text which is not a recommended practice. Only use this script on a personal computer that you administer to reduce the risk of having your credentials hacked or stolen. This script does not make any safeguards against your data. Proceed with caution at your own risk!

## Usage Instructions

To begin, you must first download the initial script with the following command:

`wget https://raw.githubusercontent.com/NLXionaire/Auto-SSH-Shell-Script/master/autossh.sh`

By default, the script looks for a file called `cmd.txt` and `ssh.txt` within the same directory as the script. If both of these files already exist then no special arguments are necessary:

```
sh autossh.sh
```

You can also specify the names and paths to these files as well in the following format:

```
sh autossh.sh <cmd.txt> <ssh.txt>
```

Example:

```
sh autossh.sh /usr/local/bin/cmd-list.file /another/directory/ssh-list.file
```

## cmd.txt Format

Multiple commands can appear on the same line or multiple lines. Commands must be ended with a semi-colon.

### Format 1:

```
free;
uptime;
```

### Format 2:

```
free; uptime;
```

## ssh.txt Format

The server ip address, username and password must all be separated by a blank space and each ssh server must be on its own line in the following format:


```
IP_ADDRESS USER_NAME PASSWORD
```

### Sample:

```
12:34:56:78 myusername aeW8&X*?U$5@&n
130:172:161:10 bob 9^w_^7VH
```

**NOTE:** Usernames and passwords that contain spaces are currently not supported.

## Sample Log Output

```
========================================
[1/2] 02:59:32 AM - 12:34:56:78
========================================
              total        used        free      shared  buff/cache   available
Mem:         499876      291000       11960        1568      196916      179944
Swap:       4714488        3564     4710924
 20:59:32 up  3:53,  0 users,  load average: 0.00, 0.00, 0.00
========================================
[2/2] 02:59:32 AM - 130:172:161:10
========================================
              total        used        free      shared  buff/cache   available
Mem:         499876      285036       11344        1316      203496      186048
Swap:       4714488        7016     4707472
 21:02:02 up  3:59,  1 user,  load average: 0.06, 0.02, 0.00
```
