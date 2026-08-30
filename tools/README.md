# Euclid Tools
This folder contains student-written command line tools which you may find useful for working with the Euclids.

Use at your own risk, and always be careful not to cause any disruption to other users or access machines which you do not have permission to use. The lists of restricted-access and general-use Euclid machines on which these scripts rely were correct as of January 2026.

## Create SSH Aliases
To prevent you having to type out `<login_name>@euclid-<number>.maths.gla.ac.uk` every time, aliases for servers can be added to your SSH config file, usually located at `~/.ssh/config`.

The config file is structured as follows:
```bash
Host euclid-01 # Alias of your choice
    HostName euclid-01.maths.gla.ac.uk # Actual URL this is short for
    User <euclid-username> # Your username on the host machine you're connecting to
```

For Unix/WSL/MacOS, these aliases can be added to your SSH config file using the script located at `tools/euclid-ssh-aliases/create-euclid-aliases.sh`. Use `create-euclid-aliases.sh -h` for help menu. By default aliases will only be created for Euclids with unrestricted access.

For Windows, copy the config file you wish to use, use a find-and-replace tool to replace `<euclid-username>` with your username, and copy into `~/.ssh/config` (where `~/` specifies your home folder on your machine).

## Check Installed & Usage
These helper scripts check all public Euclids for the existence of a particular command (check_installed.sh) or the live CPU/Memory/GPU utilisation (usage.sh).

These can be modified to include other Euclids to which you have access by modifying the "SERVERS" variable in each script.

To add aliases for these scripts, you can add the following to your `~/.bashrc` file:
```bash
alias euclid-usage='./path/to/ServerInfo/tools/usage.sh'
alias euclid-installed='./path/to/ServerInfo/tools/check_installed.sh'
```
