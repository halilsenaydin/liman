# Open Source Software Development

Halil İbrahim ŞENAYDIN | 200707069 | Atatürk University

This repository contains project liman of the Open Source Software Development lesson.

## Exec Script File

A script file with param is run like this:

```bash
chmod +x script.sh # add to executable permission
./script.sh -h # exec script file with param
```

## Project Liman
> This script allows the installation, removal and resetting of the Liman. Script has FileLogger, ExecCommand functions. Thanks to these functions, installation control and logging operations are easily carried out.

### Exec Script File

```bash
chmod +x liman.sh # add to executable permission

# Install Liman
./liman.sh -i
./liman.sh --install

# Remove Liman
./liman.sh -p
./liman.sh --purge

# Reset Liman
./liman.sh -r <mail>
./liman.sh --reset <mail>

# Administrator
./liman.sh -a
./liman.sh --admin

# Help about script
./liman.sh -h
./liman.sh --help

```
