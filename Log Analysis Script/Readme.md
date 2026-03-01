# 📊 Nginx Log Analysis Script

A simple Bash script to analyze Nginx access logs and generate insightful reports during production incidents or monitoring.

## 📁 Project Structure

```
Log Analysis Script/
│
├── analyze_logs.sh          # Main analysis script
├── dummy_log_gen.sh.txt         # Script to generate dummy logs
├── .gitignore               # Git ignore file
└── README.md                # This file
```

## 🎯 Features

This script analyzes Nginx access logs and provides:

1. Top 10 IP addresses by number of requests
2. Top 10 most requested URLs (without query strings)
3. Total number of requests and unique visitors
4. Requests per HTTP status code (200, 404, 500, etc.)

## 🚀 Quick Start

### Prerequisites

- Linux/Unix environment
- Bash shell
- Basic command-line knowledge

### Installation

Clone the repository:

```bash
git clone https://github.com:munnavuyyuru/linux-interview-questions.git
cd Log Analysis Script
```

Make the script executable:

```bash
chmod +x log_analysis_script.sh
```

## 💻 Usage

### Basic Usage

```bash
./log_analysis_script.sh access.log
```

### Example Output

```
Top 10 IPs:
     42 192.168.1.100
     38 10.0.0.25
     35 172.16.0.50
     ...

Top 10 URLs (no query strings):
     125 /api/users
     98 /index.html
     76 /products
     ...

Total Requests: 1523
Unique Visitors: 234

Requests by HTTP status code:
   1200 200
    150 404
     89 500
     ...
```

## 🔧 Script Breakdown

### analyze_logs.sh

```bash
#!/bin/bash

# 1. Top 10 IP addresses by number of requests
echo "Top 10 IPs:"
awk '{print $1}' "$1" | sort | uniq -c | sort -rn | head -10

# 2. Top 10 most requested URLs (clean the query strings)
echo "Top 10 URLs (no query strings):"
awk -F\" '{print $2}' "$1" | awk '{print $2}' | sort | uniq -c | sort -nr | head -10

# 3. Total number of requests and unique visitors
res=$(wc -l < "$1")
echo "Total Requests: $res"

ans=$(awk '{print $1}' "$1" | sort -u | wc -l)
echo "Unique Visitors: $ans"

# 4. Requests by HTTP Status Code
echo "Requests by HTTP status code:"
awk '{print $9}' "$1" | grep -E "^[0-9]{3}" | sort | uniq -c | sort -rn
```

## 📚 Command Explanation

### 🔹 AWK (awk)

A powerful text processing tool that works on columns/fields.

| Command            | Explanation                             |
| ------------------ | --------------------------------------- |
| `awk '{print $1}'` | Print the 1st column (IP address)       |
| `awk '{print $2}'` | Print the 2nd column (URL)              |
| `awk '{print $9}'` | Print the 9th column (HTTP status code) |
| `awk -F\"`         | Set field separator to double quote     |

**Example:**

```bash
awk '{print $1}' access.log
# Extracts all IP addresses from the log
```

### 🔹 SORT (sort)

Arranges lines of text in order.

| Command    | Explanation                 |
| ---------- | --------------------------- |
| `sort`     | Sort lines alphabetically   |
| `sort -r`  | Sort in reverse order       |
| `sort -n`  | Sort numerically            |
| `sort -rn` | Sort numerically in reverse |
| `sort -u`  | Sort and remove duplicates  |

**Example:**

```bash
sort -rn
# Sorts numbers from highest to lowest
```

### 🔹 UNIQ (uniq)

Reports or removes duplicate lines (requires sorted input).

| Command   | Explanation                    |
| --------- | ------------------------------ |
| `uniq`    | Remove duplicate lines         |
| `uniq -c` | Count occurrences of each line |

**Example:**

```bash
sort | uniq -c
# Counts how many times each line appears
```

### 🔹 GREP (grep)

Searches for patterns in text.

| Command               | Explanation                                       |
| --------------------- | ------------------------------------------------- |
| `grep "pattern"`      | Find lines containing "pattern"                   |
| `grep -E`             | Use extended regex                                |
| `grep -E "^[0-9]{3}"` | Match lines starting with 3 digits (status codes) |

**Example:**

```bash
grep -E "^[0-9]{3}"
# Matches: 200, 404, 500, etc.
```

### 🔹 WC (wc)

Word, line, character count.

| Command | Explanation      |
| ------- | ---------------- |
| `wc -l` | Count lines      |
| `wc -w` | Count words      |
| `wc -c` | Count characters |

**Example:**

```bash
wc -l access.log
# Counts total number of lines (requests)
```

### 🔹 HEAD (head)

Output the first part of files.

| Command    | Explanation         |
| ---------- | ------------------- |
| `head -10` | Show first 10 lines |

**Example:**

```bash
head -10
# Display top 10 results
```

## 🧩 Pipeline Breakdown

### Example 1: Top 10 IPs

```bash
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10
```

**Step-by-step:**

1. `awk '{print $1}'` → Extract IP addresses (column 1)
2. `sort` → Sort IPs alphabetically
3. `uniq -c` → Count occurrences of each IP
4. `sort -rn` → Sort by count (highest first)
5. `head -10` → Show top 10

### Example 2: Top 10 URLs

```bash
awk -F\" '{print $2}' access.log | awk '{print $2}' | sort | uniq -c | sort -nr | head -10
```

**Step-by-step:**

1. `awk -F\" '{print $2}'` → Extract request line (between quotes)
2. `awk '{print $2}'` → Extract URL (2nd field of request)
3. `sort` → Sort URLs
4. `uniq -c` → Count each URL
5. `sort -nr` → Sort by count
6. `head -10` → Top 10 URLs

### Example 3: Unique Visitors

```bash
awk '{print $1}' access.log | sort -u | wc -l
```

**Step-by-step:**

1. `awk '{print $1}'` → Extract IPs
2. `sort -u` → Sort and remove duplicates
3. `wc -l` → Count unique IPs

## 📝 Sample Nginx Log Format

```
192.168.1.100 - - [10/Jan/2024:13:55:36 +0000] "GET /index.html HTTP/1.1" 200 1024
```

**Columns:**

- `$1` → IP Address (192.168.1.100)
- `$2-$3` → Identity/User (- -)
- `$4-$5` → Timestamp ([10/Jan/2024:13:55:36 +0000])
- `$6` → Request ("GET /index.html HTTP/1.1")
- `$9` → Status Code (200)
- `$10` → Bytes Sent (1024)

## 🛠️ Common Use Cases

### During Production Incident

```bash
# Quick analysis of today's logs
./analyze_logs.sh /var/log/nginx/access.log
```

### Finding Attack Sources

```bash
# Check for excessive requests from single IPs
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -20
```

### Monitoring 404 Errors

```bash
# Find broken links
awk '$9==404' access.log | awk -F\" '{print $2}' | sort | uniq -c | sort -rn
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

Venkata Bhargav vuyyuru

- GitHub: [@munnavuyyuru](https://github.com/munnavuyyuru)
- LinkedIn: [@v venkata bhargav](https://www.linkedin.com/in/v-venkata-bhargav-3723b4275)
