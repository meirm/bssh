# bssh

bssh is a collection of command-line tools for bulk SSH and SCP operations. Originally written in 2006 on Linux, these scripts still run flawlessly on modern systems (including macOS) with no modifications. This project is a testament to the power of CLI tools and the Unix philosophy.

## Overview

bssh provides a suite of utilities to perform parallel and sequential operations across multiple servers. The primary commands include:
- bssh: Run SSH commands in parallel.
- bsshs: Run SSH commands sequentially.
- bput: Copy files (via scp) in parallel from local to remote hosts.
- bputs: Sequential version of bput.
- bget: Copy files (via scp) in parallel from remote to local hosts.
- bgets: Sequential version of bget.

The scripts use a simple nodes file to specify target hosts and their groups.

## Installation
1. Clone the Repository:

```
git clone https://github.com/meirm/bssh
```

2. Copy the Scripts to Your PATH (adjust paths as needed):

```
cd bssh
sudo cp bssh bsshs bput bputs bget bgets /usr/local/bin/
sudo cp lib/bcommon.pm /usr/local/lib/  # Or another location in your @INC
```

3. (Optional) Add the repository directory to your PATH instead of copying the scripts.

## Setting Up Your Nodes File

bssh expects a file called nodes in either `~/.bssh/` or `/usr/local/bsshtools/etc/`. To create a default nodes file, run:

```
bssh --init
```

This creates a file with the following content:

```
localhost:all
```

Edit this file to include your servers. For example:

```
localhost:all
192.168.4.100:wawa,all
192.168.4.101:wawa,all
192.168.4.102:all
myserver1:dev,all
myserver2:dev,all
```

## Usage

### Parallel SSH Commands

Run a command on all servers in the all group:

```
bssh @all uname -a
```

### Listing Nodes

See which nodes match your criteria:

```
bssh @all -ls
```

### Using Ranges and Exclusions

Run a command on the first three nodes in your nodes file:

```
bssh :0-2 uname -r
```

Exclude a specific group:

```
bssh @all -@wawa uptime
```

Run a command on a specific host:

```
bssh 192.168.4.101: df -h
```

### Adding SSH Options and Dry Run

Specify custom SSH options:

```
bssh --sshoptions "-i /path/to/key -p 2022" @all uptime
```

Perform a dry run (prints the commands without executing them):

```
bssh --dry-run @all uname -n
```

### File Transfer with bput and bget

bput (parallel file copy to remote hosts):

```
bput @all /etc/motd /tmp/
```

bget (parallel file copy from remote hosts):

```
bget @all /etc/passwd ./backups/
```

### Sequential Versions

If you prefer to run commands sequentially, use:
- bsshs: Sequential SSH commands.
- bputs: Sequential file copy to remote hosts.
- bgets: Sequential file copy from remote hosts.

Their usage is identical to their parallel counterparts.

### Advanced Tips
- Default SSH Options:
Store persistent options in `~/.bssh/sshparams` (e.g., `-o StrictHostKeyChecking=no`).
- Combining Patterns:
You can mix ranges, groups, and exclusions in a single command:

```
bssh :0-5 @dev -@excluded sudo systemctl restart nginx
```

- Error Handling:
In parallel mode, each child process returns an exit code. Sequential scripts handle errors one by one.

## Conclusion

bssh is a powerful toolkit for managing multiple servers with ease. Whether you’re deploying code, transferring files, or gathering logs, these tools help automate repetitive tasks with the simplicity and elegance of Unix command-line philosophy.

Feel free to explore the code and contribute to the project on GitHub.

Happy automating!