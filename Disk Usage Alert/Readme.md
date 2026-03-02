# 💾 Disk Space Alert Script

![Bash](https://img.shields.io/badge/Bash-Script-green)
![Linux](https://img.shields.io/badge/Platform-Linux-blue)
![Cron](https://img.shields.io/badge/Scheduler-Cron-yellow)
![License](https://img.shields.io/badge/License-MIT-orange)

A lightweight Bash script that monitors disk usage across all mounted filesystems and sends automated email alerts when usage exceeds a defined threshold. Designed to run via **cron** every 15–30 minutes, it also reports the top 5 largest directories on any filesystem nearing capacity.

---

## 📁 Project Structure

```
Disk Space Alert/
│
├── disk_alert.sh          # Main alert script
├── test_alert.sh          # Script to simulate threshold breach
├── .gitignore             # Git ignore file
└── README.md              # This file
```

---

## 🎯 Features

This script monitors disk space and provides:

1. Scans **all mounted filesystems** using `df`
2. Triggers alert when usage exceeds a configurable **threshold (default: 85%)**
3. Reports the **Top 5 largest directories** on the affected mount point
4. Sends a **formatted email alert** with hostname, filesystem, usage %, and timestamp
5. Fully compatible with **cron scheduling** (every 15–30 minutes)

---

## 🚀 Quick Start

### Prerequisites

- Linux/Unix environment
- Bash shell (`#!/bin/bash`)
- `mailutils` or `sendmail` installed for email alerts
- Basic command-line knowledge
- Sudo/root privileges (for reading all mount points)

### Installation

Clone the repository:

```bash
git clone https://github.com/munnavuyyuru/linux-interview-questions.git
cd "Disk Space Alert"
```

Make the script executable:

```bash
chmod +x disk_alert.sh
```

---

## 💻 Usage

### Basic Usage

```bash
./disk_alert.sh
```

### Customise Threshold & Email

Edit the top variables in `disk_alert.sh`:

```bash
THRESHOLD=85              # Alert when usage >= 85%
EMAIL="admin@example.com" # Recipient email address
```

### Example Email Alert

```
Subject: DISK ALERT: webserver01 - /var at 91%

DISK SPACE ALERT

Hostname  : webserver01
Filesystem: /var
Usage     : 91%
Threshold : 85%
Date      : Mon Jan 13 10:45:00 UTC 2025

Top 5 Largest Directories:
18G    /var/log
 5G    /var/lib
 3G    /var/cache
 1G    /var/spool
512M   /var/tmp
```

---

## 🔧 Script Breakdown

### disk_alert.sh

```bash
#!/bin/bash

# Disk Space Alert Script
# Run via cron every 15-30 minutes

THRESHOLD=85
EMAIL="admin@example.com"
HOSTNAME=$(hostname)

# Check each filesystem
df --output=pcent,target | tail -n +2 | while read line; do
    usage=$(echo $line | awk '{print $1}' | tr -d '%')
    mount=$(echo $line | awk '{print $2}')

    if [ $usage -ge $THRESHOLD ]; then
        # Get top 5 largest directories
        if [ "$mount" = "/" ]; then
            top_dirs=$(du -sh /* 2>/dev/null | sort -hr | head -5)
        else
            top_dirs=$(du -sh $mount/* 2>/dev/null | sort -hr | head -5)
        fi

        # Send alert email
        mail -s "DISK ALERT: $HOSTNAME - $mount at ${usage}%" $EMAIL <<EOF
DISK SPACE ALERT

Hostname  : $HOSTNAME
Filesystem: $mount
Usage     : ${usage}%
Threshold : ${THRESHOLD}%
Date      : $(date)

Top 5 Largest Directories:
$top_dirs
EOF
    fi
done
```

---

## 📚 Command Explanation

### 🔹 DF (df)

Reports the amount of disk space used and available on all mounted filesystems.

| Command                    | Explanation                                |
| -------------------------- | ------------------------------------------ |
| `df`                       | Show disk usage of all mounted filesystems |
| `df --output=pcent,target` | Show only usage % and mount point columns  |
| `df -h`                    | Human-readable sizes (KB, MB, GB)          |
| `df /var`                  | Show disk usage of a specific path         |

**Example:**

```bash
df --output=pcent,target
# Output:
# Use%  Mounted on
#  22%  /
#  91%  /var
#  45%  /home
# Selects only the "percent used" and "mount point" columns
```

---

### 🔹 AWK (awk)

A powerful text-processing tool that splits each input line into fields and lets you extract or manipulate them individually.

| Command               | Explanation                                            |
| --------------------- | ------------------------------------------------------ |
| `awk '{print $1}'`    | Print the 1st column (usage percentage)                |
| `awk '{print $2}'`    | Print the 2nd column (mount point)                     |
| `awk '{print $1,$2}'` | Print multiple columns with a space between            |
| `awk -F':'`           | Set the field separator to colon instead of whitespace |

**Example:**

```bash
echo "91% /var" | awk '{print $1}'
# Output: 91%
# awk splits the line by whitespace; $1 picks the first field

echo "91% /var" | awk '{print $2}'
# Output: /var
# $2 picks the second field (mount point)
```

---

### 🔹 DU (du)

Estimates file and directory disk usage — used here to find the top 5 largest directories on a nearly full filesystem.

| Command                 | Explanation                                         |
| ----------------------- | --------------------------------------------------- |
| `du -sh /path/*`        | Summarised, human-readable size of each item        |
| `du -sh`                | -s: summary only (no sub-dirs); -h: human-readable  |
| `du -sh /* 2>/dev/null` | Scan root, suppress "Permission denied" errors      |
| `du -ah`                | Show all files and directories (not just top-level) |

**Example:**

```bash
du -sh /var/* 2>/dev/null
# Output:
# 18G    /var/log
#  5G    /var/lib
#  3G    /var/cache
# -s gives one line per directory; -h gives human-readable sizes
```

---

### 🔹 SORT (sort)

Arranges lines of text in order — used here to rank directories from largest to smallest.

| Command    | Explanation                                 |
| ---------- | ------------------------------------------- |
| `sort`     | Sort lines alphabetically (ascending)       |
| `sort -r`  | Sort in reverse (descending) order          |
| `sort -h`  | Sort human-readable sizes (2K, 1G, 512M)    |
| `sort -hr` | Human-readable sizes, largest first         |
| `sort -rn` | Sort numerically in reverse (highest first) |

**Example:**

```bash
du -sh /var/* | sort -hr
# Output (sorted largest → smallest):
# 18G    /var/log
#  5G    /var/lib
#  3G    /var/cache
# -h understands 18G > 5G > 3G; -r reverses to show largest first
```

---

### 🔹 TR (tr)

Translates or deletes characters from input — used here to strip the `%` sign so usage can be compared as a plain integer.

| Command          | Explanation                                     |
| ---------------- | ----------------------------------------------- |
| `tr -d '%'`      | Delete all `%` characters from the input stream |
| `tr -d '\n'`     | Delete newline characters (join lines)          |
| `tr 'a-z' 'A-Z'` | Convert every lowercase letter to uppercase     |
| `tr -s ' '`      | Squeeze multiple consecutive spaces into one    |

**Example:**

```bash
echo "91%" | tr -d '%'
# Output: 91
# Removes % so bash can do an integer comparison: [ 91 -ge 85 ]
# Without tr, the comparison would fail with a syntax error
```

---

### 🔹 TAIL (tail)

Outputs the last part of a file — used here with `-n +2` to skip the column-header line that `df` prints.

| Command        | Explanation                                         |
| -------------- | --------------------------------------------------- |
| `tail -n +2`   | Output starting from line 2, skipping the header    |
| `tail -5`      | Show only the last 5 lines of a file                |
| `tail -f file` | Follow the file in real-time (useful for live logs) |
| `tail -n 10`   | Show the last 10 lines                              |

**Example:**

```bash
df --output=pcent,target | tail -n +2
# Skips the "Use% Mounted on" header row
# Output (data lines only):
#  22%  /
#  91%  /var
# +2 means "start output at line 2" — line 1 (header) is skipped
```

---

### 🔹 MAIL (mail)

Sends email from the command line — used to dispatch disk space alerts to the sysadmin.

| Command                        | Explanation                                       |
| ------------------------------ | ------------------------------------------------- |
| `mail -s "subject" email`      | Send email with a subject to the given address    |
| `<<EOF ... EOF`                | Here-document: supplies a multi-line body to mail |
| `mail -a "CC: x@x.com"`        | Add a CC recipient to the email                   |
| `mail -a "From: noreply@host"` | Set a custom From address                         |

**Example:**

```bash
mail -s "DISK ALERT: webserver01 - /var at 91%" admin@example.com <<EOF
DISK SPACE ALERT
Filesystem: /var
Usage: 91%
EOF
# Sends an email with the given subject and multi-line body
# The <<EOF...EOF block is a here-document that feeds the email body
```

---

## 🧩 Pipeline Breakdown

### Example 1 — Loop Over Every Filesystem

```bash
df --output=pcent,target | tail -n +2 | while read line; do ...; done
```

**Step-by-step:**

1. `df --output=pcent,target` → List all filesystems with usage % and mount point
2. `tail -n +2` → Drop the "Use% Mounted on" header row
3. `while read line` → Iterate over each remaining filesystem line one at a time

---

### Example 2 — Strip % and Compare Numerically

```bash
usage=$(echo $line | awk '{print $1}' | tr -d '%')
```

**Step-by-step:**

1. `echo $line` → Output the current line, e.g. ` 91% /var`
2. `awk '{print $1}'` → Extract the first field: `91%`
3. `tr -d '%'` → Strip the % symbol: `91`
4. `[ $usage -ge $THRESHOLD ]` → Compare 91 ≥ 85 → alert triggered ✅

---

### Example 3 — Find Top 5 Largest Directories

```bash
du -sh $mount/* 2>/dev/null | sort -hr | head -5
```

**Step-by-step:**

1. `du -sh $mount/*` → Get the size of every sub-directory inside the affected mount point
2. `2>/dev/null` → Discard "Permission denied" errors so they don't clutter the email
3. `sort -hr` → Sort by human-readable size, largest first (18G → 5G → 3G)
4. `head -5` → Keep only the top 5 results

---

## ⏰ Cron Setup

Schedule the script to run automatically every 15 minutes:

```bash
# Open the crontab editor
crontab -e

# Run every 15 minutes
*/15 * * * * /path/to/disk_alert.sh

# Run every 30 minutes
*/30 * * * * /path/to/disk_alert.sh
```

> ⚠️ **Tip:** Make sure `mail` is installed and configured.
> Install via `sudo apt install mailutils` (Debian/Ubuntu) or `sudo yum install mailx` (RHEL/CentOS).

---

## 🛠️ Common Use Cases

### During a Production Incident

```bash
# Run immediately to check all filesystems right now
./disk_alert.sh
```

### Quick Manual Disk Check

```bash
# See all filesystems and their usage %
df -h

# Check which sub-directories are largest inside /var
du -sh /var/* | sort -hr | head -10
```

### Change Threshold on the Fly

```bash
# Override threshold to 70% for stricter monitoring
THRESHOLD=70 ./disk_alert.sh
```

### Find and Clean Large Log Files

```bash
# Find the largest files under /var/log
find /var/log -type f | xargs du -sh | sort -hr | head -10

# Safely truncate a log file (keeps the file, clears content)
> /var/log/large_app.log
```

---

## 📄 License

This project is licensed under the **MIT License** — see the `LICENSE` file for details.
You are free to use, modify, and distribute this script.

---

## 👤 Author

**Venkata Bhargav Vuyyuru**

- GitHub: [@munnavuyyuru](https://github.com/munnavuyyuru)
- LinkedIn: [@v-venkata-bhargav](https://www.linkedin.com/in/v-venkata-bhargav-3723b4275)
