#! /bin/bash

# 1. Top 10 IP addresses by number of requests
echo "Top 10 IPs:"
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10

# 2. Top 10 most requested URLs (clean the query strings)
echo "Top 10 URLs (no query strings):"
awk -F\" '{print $2}' access.log | awk '{print $2}' |sort | uniq -c | sort -nr | head -10

# 3. Total number of requests and unique visitors 
res=$(wc -l access.log)
echo "no of reqs : $res"

ans=$(awk '{print $1}' access.log | sort -u | wc -l)
echo "no uniq vis : $ans"

# 4. Requests by HTTP Status Code
echo "Requests by HTTP status code:" 
awk '{print $9}' access.log | grep -E "^[0-9]{3}$" |sort | uniq -c | sort -rn