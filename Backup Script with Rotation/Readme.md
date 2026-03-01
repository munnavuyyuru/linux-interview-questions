# 💾 Automated Backup & Rotation Script

A simple yet powerful Bash script to create compressed backups of any directory with automatic rotation — keeping only the last 7 backups to save disk space.

---

## 📁 Project Structure

```text
Backup Script/
│
├── Backup_Script.sh                # Main backup script
├── dummy_files_gen.sh       # Generate the dummy files
└── README.md                # This file
```

---

## 🎯 Features

This script provides:

- **Argument validation** — Ensures correct usage with proper error messages
- **Source directory verification** — Checks if the source exists and is readable
- **Auto-creation of destination** — Creates backup directory if it doesn't exist
- **Timestamped compressed backups** — Creates `.tar.gz` archives with date-time stamps
- **Automatic rotation** — Keeps only the last 7 backups, deletes older ones

---

## 🚀 Quick Start

### Prerequisites

- Linux/Unix environment
- Bash shell
- `tar` utility (pre-installed on most systems)
- Basic command-line knowledge

### Installation

1. **Clone the repository:**

```bash
git clone https://github.com/munnavuyyuru/linux-interview-questions.git
cd Backup Script
```

2. **Make the script executable:**

```bash
chmod +x backup.sh
```

---

## 💻 Usage

### Basic Usage

```bash
./backup.sh <source_directory> <backup_destination>
```

### Examples

```bash
# Backup your project folder
./backup.sh /home/user/myproject /home/user/backups

# Backup Nginx config
./backup.sh /etc/nginx /var/backups/nginx

# Backup website files
./backup.sh /var/www/html /mnt/external/website-backups
```

### Example Output

```text
Backup created: /home/user/backups/backup_myproject_20250115_143022.tar.gz
```

### Error Outputs

```bash
# No arguments provided
Usage: ./backup.sh <source_directory> <backup_destination>

# Invalid source directory
Invalid or unreadable source directory: /nonexistent/path

# Backup failure
Backup failed
```

---

## 🔧 Script Breakdown

### `backup.sh`

```bash
#!/bin/bash

# Usage: ./backup.sh <source_dir> <backup_dir>

# 1. Argument check
if [ $# -ne 2 ]; then
    echo "Usage: $0 <source_directory> <backup_destination>"
    exit 1
fi

SOURCE="$1"
DEST="$2"
KEEP_COUNT=7

# 2. Validate source
if [ ! -d "$SOURCE" ] || [ ! -r "$SOURCE" ]; then
    echo "Invalid or unreadable source directory: $SOURCE"
    exit 1
fi

# 3. Ensure destination exists
mkdir -p "$DEST" || {
    echo "Cannot create destination directory: $DEST"
    exit 1
}

# 4. Create backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SOURCE_NAME=$(basename "$SOURCE")
BACKUP_PATH="$DEST/backup_${SOURCE_NAME}_${TIMESTAMP}.tar.gz"

tar -czf "$BACKUP_PATH" -C "$(dirname "$SOURCE")" "$SOURCE_NAME" || {
    echo "Backup failed"
    exit 1
}

echo "Backup created: $BACKUP_PATH"

# 5. Rotation (keep last 7)
TOTAL=$(ls -1 "$DEST"/backup_*.tar.gz 2>/dev/null | wc -l)

if [ "$TOTAL" -gt "$KEEP_COUNT" ]; then
    ls -t "$DEST"/backup_*.tar.gz \
        | tail -n +$((KEEP_COUNT + 1)) \
        | xargs -r rm -f
fi

exit 0
```

---

## 📚 Command & Term Explanation

### 🔹 `$#` — Argument Count

`$#` is a special variable in Bash that holds the number of arguments passed to the script.

| Variable | Meaning                              |
| -------- | ------------------------------------ |
| `$#`     | Total number of arguments            |
| `$0`     | Name of the script itself            |
| `$1`     | First argument (source directory)    |
| `$2`     | Second argument (backup destination) |
| `$@`     | All arguments as separate strings    |

**Example:**

```bash
./backup.sh /home/user/data /backups
# $# = 2
# $0 = ./backup.sh
# $1 = /home/user/data
# $2 = /backups
```

---

### 🔹 `-ne` — Not Equal (Numeric Comparison)

Used inside `[ ]` for integer comparison.

| Operator | Meaning                  |
| -------- | ------------------------ |
| `-ne`    | Not equal                |
| `-eq`    | Equal                    |
| `-gt`    | Greater than             |
| `-lt`    | Less than                |
| `-ge`    | Greater than or equal to |
| `-le`    | Less than or equal to    |

**Example:**

```bash
if [ $# -ne 2 ]; then
    echo "Exactly 2 arguments required"
fi
```

---

### 🔹 `exit` — Exit Codes

Terminates the script and returns a status code to the calling process.

| Code     | Meaning                      |
| -------- | ---------------------------- |
| `exit 0` | Success (everything is fine) |
| `exit 1` | General error / failure      |
| `exit 2` | Misuse of shell command      |

**Example:**

```bash
exit 1   # Script stops here with an error status
```

---

### 🔹 Test Operators: `! -d` and `! -r`

Used for file and directory testing inside `[ ]`.

| Operator | Meaning                           |
| -------- | --------------------------------- |
| `-d`     | True if path is a directory       |
| `-r`     | True if path is readable          |
| `-f`     | True if path is a regular file    |
| `-w`     | True if path is writable          |
| `-x`     | True if path is executable        |
| `-e`     | True if path exists (any type)    |
| `!`      | Negation — reverses the condition |

**Example:**

```bash
if [ ! -d "$SOURCE" ]; then
    echo "Not a directory!"
fi
# Checks: if SOURCE is NOT a directory
```

---

### 🔹 `mkdir -p` — Create Directory (with Parents)

Creates the directory and any missing parent directories in the path. Does not throw an error if the directory already exists.

| Command            | Explanation                        |
| ------------------ | ---------------------------------- |
| `mkdir mydir`      | Create a single directory          |
| `mkdir -p a/b/c/d` | Create entire path if not existing |

**Example:**

```bash
mkdir -p /home/user/backups/daily
# Creates: /home/user/backups/ AND /home/user/backups/daily/
# No error even if they already exist
```

---

### 🔹 `||` and `{ }` — OR Operator & Command Grouping

| Symbol  | Meaning                                       |
| ------- | --------------------------------------------- |
| `\|\|`  | Execute right side only if left side fails    |
| `&&`    | Execute right side only if left side succeeds |
| `{ ; }` | Group multiple commands together              |

**Example:**

```bash
mkdir -p "$DEST" || {
    echo "Cannot create destination directory"
    exit 1
}
# If mkdir fails → print error AND exit
```

---

### 🔹 `date +%Y%m%d_%H%M%S` — Timestamp Formatting

Generates a formatted date-time string.

| Format | Meaning         | Example |
| ------ | --------------- | ------- |
| `%Y`   | Year (4 digits) | 2025    |
| `%m`   | Month (01–12)   | 01      |
| `%d`   | Day (01–31)     | 15      |
| `%H`   | Hour (00–23)    | 14      |
| `%M`   | Minute (00–59)  | 30      |
| `%S`   | Second (00–59)  | 22      |

**Example:**

```bash
date +%Y%m%d_%H%M%S
# Output: 20250115_143022
```

---

### 🔹 `basename` and `dirname` — Path Utilities

These commands extract parts of a file/directory path.

| Command                         | Output       |
| ------------------------------- | ------------ |
| `basename /home/user/myproject` | `myproject`  |
| `dirname /home/user/myproject`  | `/home/user` |
| `basename /var/log/syslog`      | `syslog`     |
| `dirname /var/log/syslog`       | `/var/log`   |

**Example:**

```bash
SOURCE="/home/user/myproject"
basename "$SOURCE"   # myproject
dirname "$SOURCE"    # /home/user
```

---

### 🔹 `tar -czf` — Create Compressed Archive

`tar` bundles files into a single archive. Combined with gzip for compression.

| Flag | Meaning                              |
| ---- | ------------------------------------ |
| `-c` | Create a new archive                 |
| `-z` | Compress with gzip (.gz)             |
| `-f` | Specify the filename of the archive  |
| `-x` | Extract an archive (for restoring)   |
| `-v` | Verbose — show files being processed |
| `-C` | Change directory before archiving    |

**Example:**

```bash
tar -czf backup.tar.gz -C /home/user myproject
#     │       │          │              │
#     │       │          │              └─ What to archive
#     │       │          └─ Change to this directory first
#     │       └─ Output file name
#     └─ Create + gzip + file

# Result: backup.tar.gz containing the "myproject" folder
```

**Why use `-C`?**

- Without `-C`, the archive stores the full path (`/home/user/myproject/...`).
- With `-C /home/user`, it stores only `myproject/...` — cleaner extraction.

---

### 🔹 `ls -1` and `ls -t` — Listing Files

| Command  | Meaning                                  |
| -------- | ---------------------------------------- |
| `ls -1`  | List one file per line                   |
| `ls -t`  | Sort by modification time (newest first) |
| `ls -r`  | Reverse the sort order                   |
| `ls -lt` | Long format, sorted by time              |

**Example:**

```bash
ls -1 /backups/backup_*.tar.gz
# backup_myproject_20250115_143022.tar.gz
# backup_myproject_20250114_100000.tar.gz
# backup_myproject_20250113_090000.tar.gz
```

---

### 🔹 `2>/dev/null` — Suppress Errors

Redirects stderr (error messages) to `/dev/null` (a black hole — discards everything).

| Redirect      | Meaning                           |
| ------------- | --------------------------------- |
| `>/dev/null`  | Suppress standard output (stdout) |
| `2>/dev/null` | Suppress error output (stderr)    |
| `&>/dev/null` | Suppress both stdout and stderr   |

**Example:**

```bash
ls /nonexistent 2>/dev/null
# No error message shown, even though directory doesn't exist
```

**In the script:**

```bash
ls -1 "$DEST"/backup_*.tar.gz 2>/dev/null | wc -l
# If no backup files exist, the error "No such file" is suppressed
# wc -l will simply return 0
```

---

### 🔹 `tail -n +N` — Skip First N-1 Lines

| Command      | Meaning                                           |
| ------------ | ------------------------------------------------- |
| `tail -n 5`  | Show the last 5 lines                             |
| `tail -n +5` | Show everything from line 5 onward (skip first 4) |
| `tail -n +8` | Show everything from line 8 onward (skip first 7) |

**Example (Rotation Logic):**

```bash
ls -t backup_*.tar.gz | tail -n +8
# Lists backups sorted newest-first
# Skips the first 7 (keeps them)
# Outputs the rest (old ones to delete)
```

---

### 🔹 `xargs -r rm -f` — Execute Command on Input

`xargs` converts stdin input into command arguments.

| Flag       | Meaning                                        |
| ---------- | ---------------------------------------------- |
| `xargs`    | Pass input lines as arguments to command       |
| `xargs -r` | Do nothing if input is empty (no-run-if-empty) |
| `rm -f`    | Force remove without confirmation              |

**Example:**

```bash
echo "file1.txt file2.txt" | xargs rm -f
# Equivalent to: rm -f file1.txt file2.txt
```

**In the script:**

```bash
ls -t backup_*.tar.gz | tail -n +8 | xargs -r rm -f
# 1. List all backups (newest first)
# 2. Skip the 7 newest (keep them)
# 3. Delete the rest
# -r ensures nothing runs if there's nothing to delete
```

---

### 🔹 `$(( ))` — Arithmetic Expansion

Performs math operations inside Bash.

| Expression            | Result              |
| --------------------- | ------------------- |
| `$((5 + 3))`          | 8                   |
| `$((10 - 4))`         | 6                   |
| `$((KEEP_COUNT + 1))` | 8 (if KEEP_COUNT=7) |

**Example:**

```bash
KEEP_COUNT=7
echo $((KEEP_COUNT + 1))
# Output: 8

tail -n +$((KEEP_COUNT + 1))
# Same as: tail -n +8 → skip first 7 lines
```

---

## 🧩 Complete Pipeline Breakdown

### Rotation Logic (Step-by-Step)

```bash
ls -t "$DEST"/backup_*.tar.gz | tail -n +$((KEEP_COUNT + 1)) | xargs -r rm -f
```

Assume `/backups/` contains **9 backup files** and `KEEP_COUNT=7`:

**Step 1: `ls -t`** — List all backups, newest first:

```text
backup_myproject_20250115.tar.gz   ← Keep (1)
backup_myproject_20250114.tar.gz   ← Keep (2)
backup_myproject_20250113.tar.gz   ← Keep (3)
backup_myproject_20250112.tar.gz   ← Keep (4)
backup_myproject_20250111.tar.gz   ← Keep (5)
backup_myproject_20250110.tar.gz   ← Keep (6)
backup_myproject_20250109.tar.gz   ← Keep (7)
backup_myproject_20250108.tar.gz   ← DELETE
backup_myproject_20250107.tar.gz   ← DELETE
```

**Step 2: `tail -n +8`** — Skip first 7 lines, output the rest:

```text
backup_myproject_20250108.tar.gz
backup_myproject_20250107.tar.gz
```

**Step 3: `xargs -r rm -f`** — Delete those old backups:

```bash
rm -f backup_myproject_20250108.tar.gz backup_myproject_20250107.tar.gz
```

✅ **Result:** Only the 7 newest backups remain!

---

## ⏰ Automate with Cron

Schedule daily backups using `crontab`:

```bash
crontab -e
```

Add this line:

```bash
# Daily backup at 2:00 AM
0 2 * * * /path/to/backup.sh /var/www/html /backups/website
```

### Cron Format

```text
┌───────── Minute (0-59)
│ ┌─────── Hour (0-23)
│ │ ┌───── Day of Month (1-31)
│ │ │ ┌─── Month (1-12)
│ │ │ │ ┌─ Day of Week (0-6, Sunday=0)
│ │ │ │ │
0 2 * * * /path/to/command
```

---

## 🔄 Restoring a Backup

```bash
# Extract a backup
tar -xzf /backups/backup_myproject_20250115_143022.tar.gz -C /restore/path/

# Verify contents without extracting
tar -tzf /backups/backup_myproject_20250115_143022.tar.gz
```

---

## 🛠️ Common Use Cases

### Backup a Web Application

```bash
./backup.sh /var/www/html /backups/website
```

### Backup Configuration Files

```bash
./backup.sh /etc/nginx /backups/nginx-config
```

### Backup Database Dumps Directory

```bash
./backup.sh /var/lib/mysql-dumps /backups/database
```

### Backup User Home Directory

```bash
./backup.sh /home/devuser /mnt/external/user-backups
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Venkata Bhargav Vuyyuru**

- GitHub: [@munnavuyyuru](https://github.com/munnavuyyuru)
- LinkedIn: [@v-venkata-bhargav](https://linkedin.com/in/v-venkata-bhargav)
