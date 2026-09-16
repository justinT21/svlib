# svlib

A repository of rtl primitives I create as needed for projects so they are reuseable.

## How to use

This repository is based on fusesoc as a dependency manager.

1. [Install Fusesoc](https://fusesoc.readthedocs.io/en/latest/user/installation.html)
2. Create a new repository and mark it as a library

```bash
fusesoc library add <repo name> .
```

3. Add this repository as a git library

```bash
fusesoc library add git@github.com:justinT21/svlib.git --sync-type git
```

4. Create core files and add different ip here as a dependency. Learn more at the [fusesoc docs](https://fusesoc.readthedocs.io/en/stable/index.html).
