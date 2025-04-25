Bare metal setup on macOS/Linux is scripted with ansible.
Important (!) macOS ansible script will require homebrew.

Full setup is regularly checked with in Jenkins pipeline with the scrips [ubuntu.23.10.sh](ubuntu.23.10.sh)

### Pre-setup on Debian Based OS

```bash
$ sudo apt install make ansible
```

### Pre-setup on macOS:

```bash
$ brew install make ansible
```

### Provisioning setup with just one make command:

```bash
$ make ansible
```

## Helpers commands:

```bash
# clean virtual env and other generated files
$ make clean_dev
```

```bash
# show command how to activate dev venv
$ make activate_env_dev
```
