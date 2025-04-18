# Raven

Convert numbers with the intelligence of the namesake.

[![CI](https://img.shields.io/github/actions/workflow/status/AdityaMotale/raven/unit_test.yaml?branch=master)](https://github.com/AdityaMotale/raven/actions/workflows/unit_test.yaml)
[![Release](https://img.shields.io/github/v/release/AdityaMotale/raven)](https://github.com/AdityaMotale/raven/releases/latest)

<p align="center">
<pre>
  /$$$$$$  /$$$$$$  /$$    /$$/$$$$$$  /$$$$$$$ 
 /$$__  $$|____  $$|  $$  /$$/$$__  $$| $$__  $$ 
| $$  \__/ /$$$$$$$ \  $$/$$/ $$$$$$$$| $$  \ $$ 
| $$      /$$__  $$  \  $$$/| $$_____/| $$  | $$ 
| $$     |  $$$$$$$   \  $/ |  $$$$$$$| $$  | $$ 
|__/      \_______/    \_/   \_______/|__/  |__/ 
</pre>
</p>


## 📥 Install

Install using the install script

```bash
# Default (non‑root → ~/.local/bin)
curl -sSL https://raw.githubusercontent.com/AdityaMotale/raven/master/install.sh | bash

# As root (→ /usr/local/bin)
curl -sSL https://raw.githubusercontent.com/AdityaMotale/raven/master/install.sh | sudo bash

# Custom directory
curl -sSL https://raw.githubusercontent.com/AdityaMotale/raven/master/install.sh 
| bash -s -- /opt/bin
```

## 🚀 Usage

```bash
raven <command> <value>
```

| Command | What it does              | Example           |
| ------- | ------------------------- | ----------------- |
| `d2b`   | Decimal → Binary          | `raven d2b 10`    |
| `b2d`   | Binary → Decimal          | `raven b2d 1010`  |
| `d2h`   | Decimal → Hexadecimal     | `raven d2h 255`   |
| `h2d`   | Hexadecimal → Decimal     | `raven h2d FF`    |

