#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json, sys, urllib.parse, urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed

ENDPOINT = "http://223.5.5.5/resolve"   # 可改为 https://dns.alidns.com/resolve
TIMEOUT = 5
RETRIES = 2
CONCURRENCY = 16

# 中国三大运营商常见 /24（可按需增删）
ECS_LIST = (
    # CMCC
    "223.104.1.0/24","117.136.1.0/24","120.204.1.0/24","112.97.1.0/24","211.136.1.0/24",
    "183.240.1.0/24","120.196.1.0/24","111.13.1.0/24","218.200.1.0/24","221.131.1.0/24",
    # CU
    "123.112.1.0/24","106.120.1.0/24","111.206.1.0/24","114.248.1.0/24","221.192.1.0/24",
    "60.169.1.0/24","110.242.1.0/24","120.52.1.0/24","124.65.1.0/24","36.110.1.0/24",
    # CT
    "61.139.1.0/24","58.240.1.0/24","59.172.1.0/24","222.240.1.0/24","218.104.1.0/24",
    "61.151.1.0/24","61.49.1.0/24","222.173.1.0/24","115.231.1.0/24","222.186.1.0/24",
)

def fqdn(name: str) -> str:
    name = name.strip()
    if not name or name.startswith("#"):
        return ""
    return name if name.endswith(".") else name + "."

def doh_once(domain: str, qtype: int, ecs: str):
    qs = urllib.parse.urlencode({
        "name": domain,
        "type": str(qtype),
        "edns_client_subnet": ecs
    })
    req = urllib.request.Request(
        f"{ENDPOINT}?{qs}",
        headers={"accept": "application/dns-json"}
    )
    with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
        return json.loads(r.read().decode("utf-8"))

def doh(domain: str, qtype: int, ecs: str):
    for _ in range(RETRIES + 1):
        try:
            return doh_once(domain, qtype, ecs)
        except Exception:
            pass
    return None

def read_domains_from_file(path: str):
    domains = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            d = fqdn(line)
            if d:
                domains.append(d)
    return sorted(set(domains))

def main(domains_file: str):
    domains = read_domains_from_file(domains_file)
    if not domains:
        print("No valid domains found in file.", file=sys.stderr)
        sys.exit(1)

    A, AAAA = set(), set()
    QTYPES = (1, 28)  # A, AAAA

    with ThreadPoolExecutor(max_workers=CONCURRENCY) as ex:
        futs = []
        for d in domains:
            for q in QTYPES:
                for ecs in ECS_LIST:
                    futs.append(ex.submit(doh, d, q, ecs))

        for f in as_completed(futs):
            resp = f.result()
            if not resp or resp.get("Status") != 0:
                continue
            for a in resp.get("Answer") or []:
                t = a.get("type")
                data = a.get("data")
                if not data:
                    continue
                if t == 1:
                    A.add(data)
                elif t == 28:
                    AAAA.add(data)

    # 只输出最终 IP（先 A 后 AAAA）
    for ip in sorted(A):
        print(ip)
    for ip in sorted(AAAA):
        print(ip)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 ecs_scan_file.py domains.txt", file=sys.stderr)
        sys.exit(1)
    main(sys.argv[1])