# Euclid Tools
This folder contains command line tools useful for working with the Euclids.

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
