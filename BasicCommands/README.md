# Basic CLI commands
## Connect to a Euclid machine:
`ssh <login_name>@euclid-<number>.maths.gla.ac.uk`

## Copy file to/from Euclid machines (run on local machine):
- To: `scp -r path/to/local/file euclid-<number>.maths.gla.ac.uk:path/on/euclid/machine`
- From: `scp -r euclid-<number>.maths.gla.ac.uk:path/on/euclid/machine path/to/local/file`
`-r` may be omitted if a single file is being transferred.
The Euclid machines share a single file system - transferring a file to your home folder on one machine will make it available on them all.
Be careful not to leave large files on the Euclid machines indefinitely. To see the file usage of a file or folder, use `du -sh path/to/folder`.

## Run program in background
To run a program in the background, so it doesn't close when your terminal session closes, there are two main options:
1. Prefix your command with `nohup` (short for "no hangup") to prevent closing the terminal from stopping the program, and place an `&` after your command to be able to be able to continue using the same command prompt.
- Example usage: `nohup python my_python_script.py arg1 arg2 &`.
- Command output will be appended to the `nohup.out` file in real time.
- You can view live command output using `tail -f nohup.out`.
- Running programs can be killed using `killall command_name --user your_username`. You can check the command name using `top`.
2. Use `screen`.
- Create a screen session with `screen -S session_name` (`session_name` can be any name of your choice).
- Run your program. You can use `Ctrl+a c` to switch to a new window in your screen session, even while a program is running, and `Ctrl+a "` to switch between windows.
- To safely leave the program running when you close the terminal, use `Ctrl+a d` to detach the screen session before closing.
- When you want to connect to the session again, reopen the terminal connected to the same Euclid machine, and use `screen -r session_name` to rejoin the session.
- Screen sessions can be closed with `exit`.

## Disconnect from a Euclid machine:
`logout`

## Run at lower priority:
To run at a lower priority (such as a task on an already busy machine), prefix your command with `nice -n <level>`, e.g., `nice -n 19 mycommand`. Nice level ranges from -20 (least nice, highest priority) to 19 (lowest priority), and often defaults to 0.

## Run on certain cores only:
You may want to limit the number of cores your process runs on. To do this, you can specify the IDs of the cores you wish to use by prefixing your command with `taskset -c <list of core ids>`, e.g., `taskset -c 0,1,2,3 mycommand` to run `mycommand` on cores 0-3 only.

# Misc & Tools
## Use SSH Keys to skip password prompt
Instead of entering a password on every connection, you can instead add your machine's public key as an "authorized key" on the Euclid machines. To do this:
1. **On your machine** open a command prompt to generate a key. Use `ssh-keygen` (Unix/WSL/MacOS), or `ssh-keygen.exe` (Windows). Click enter to accept all defaults. 
2. Verify your public-private key pair has now been saved to your default SSH directory, usually `~/.ssh`, by entering the command `ls ~/.ssh/`. Check for files `id_ed25519` (private key, do not distribute!) and `id_ed2519.pub` (public key).
3. Copy public key. Print public key using `cat ~/.ssh/id_ed25519.pub`. Copy this line.
4. Connect to one of the Euclid machines.
5. On a Euclid machine, open the `authorized_hosts` file with `nano ~/.ssh/authorized_keys`. On a new line, paste your public key. Close and save the file.

You should now be able to establish an SSH connection with any of the Euclid machines in the normal way without entering your password.
If you use WSL, you will need to do this separately for both Windows and WSL, or copy the keys from one filesystem to the other.

## Create SSH Aliases
To prevent you having to type out `<login_name>@euclid-<number>.maths.gla.ac.uk` every time, aliases for servers can be added to your SSH config file, usually located at `~/.ssh/config`.

Instructions can be found in [tools/README](/tools/README.md).

