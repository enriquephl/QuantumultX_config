set -euo pipefail
trap 'rm -f /tmp/all_ips.txt "${ipv4_file:-}" "${ipv6_file:-}"' EXIT
if [[ -z "$BANHTTPDNS_PATH" ]]; then
  echo "::error::BANHTTPDNS_PATH is not set"
  exit 1
fi

outfile="$BANHTTPDNS_PATH"
mkdir -p "$(dirname "$outfile")"

# 分离 IPv4 / IPv6 并去重
ipv4_file=$(mktemp /tmp/ipv4.XXXXXX.txt) # 使用 mktemp 创建唯一文件名
ipv6_file=$(mktemp /tmp/ipv6.XXXXXX.txt) # 使用 mktemp 创建唯一文件名
echo "::group::Processing IPv4 rules"
grep -E '^[0-9]+\.' /tmp/all_ips.txt | sort -u > "$ipv4_file"
# 仅校验 IPv4 文件（粗略 4 段 0-255 可更严，但够用）
if grep -Ev '^[0-9]{1,3}(\.[0-9]{1,3}){3}$' "$ipv4_file" >/dev/null; then
  echo "::error::Invalid IPv4 format in $ipv4_file"
   exit 1
fi
echo "::endgroup::"
# IPv6 允许十六进制与冒号
grep -E '^[0-9A-Fa-f:]+$' /tmp/all_ips.txt | sort -u > "$ipv6_file"

cnt4=$(wc -l < "$ipv4_file" | tr -d ' ')
cnt6=$(wc -l < "$ipv6_file" | tr -d ' ')
total=$((cnt4 + cnt6))

# 时间戳（UTC，ISO8601）
ts=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

# 仓库路径用于头部链接
repo="${GITHUB_REPOSITORY}"

{
  echo "#########################################"
  echo "# https://github.com/${repo}/blob/main/ClashRuleSet/List/ip/banhttpdns.list"
  echo "# Last Updated: ${ts}"
  echo "# Size: ${total}"
  echo "#  IP-CIDR: ${cnt4}"
  echo "#  IP-CIDR6: ${cnt6}"
  echo "#########################################"
  # IPv4: IP-CIDR,<ipv4>
  if [[ $cnt4 -gt 0 ]]; then
    awk '{printf "IP-CIDR,%s/32\n", $0}' "$ipv4_file"
  fi
  # IPv6: IP-CIDR6,<ipv6>
  if [[ $cnt6 -gt 0 ]]; then
    awk '{printf "IP-CIDR6,%s/128\n", $0}' "$ipv6_file"
  fi
} > "$outfile"

echo "Generated: $outfile"
echo "IPv4: $cnt4, IPv6: $cnt6, Total: $total"