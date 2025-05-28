# DevChest

Simplify and accelerate the setup of your Linux environment with DevChest, a curated collection of automation scripts. These scripts streamline the installation and configuration of essential applications and tools, making it effortless to get your system ready for development or everyday use.

## Features

- Automates the installation of common Linux applications and tools.
- Supports multiple Linux distributions (e.g., Ubuntu, Fedora, etc.).
- Easy-to-follow modular scripts for customization.

## Prerequisites

* A supported Linux distribution (Ubuntu, Debian, CentOS, RHEL, or Fedora).
* `sudo` privileges to install packages and configure the system.
* Internet connection for downloading scripts and dependencies.

## Installation

To set up your environment with DevChest, you can download and run the [install.sh](https://raw.githubusercontent.com/groot-arena/DevChest/main/install.sh) script or run the following `cURL` or `wget` command:

```
curl -fsSL https://raw.githubusercontent.com/groot-arena/DevChest/main/install.sh | sudo bash
```
```
wget -qO- https://raw.githubusercontent.com/groot-arena/DevChest/main/install.sh | sudo bash
```

## Supported Tools
* Docker Engine
* Google Chrome
* NVM (Node Version Manager)
* VS Code (Stable)

## Contributing
Contributions are welcome! If you'd like to add a new script or improve an existing one:

1. Fork the repository.
2. Create a new branch:
```bash
git checkout -b feat/package-name
```
3. Commit your changes:
```bash
git commit -m "Add your message here"
```
4. Push to your fork:
```bash
git push origin feature-name
```
5. Open a pull request describing your changes.

---

### Happy automating with DevChest!

If you have any issues or questions, please open an issue in this repository.