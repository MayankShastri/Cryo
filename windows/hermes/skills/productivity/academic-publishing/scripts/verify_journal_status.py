#!/usr/bin/env python3
"""
Verification script for probing academic journal portals (OJS, ThaiJO, BME, ASPX)
to extract APC statements, Scopus indexing claims, author guidelines, and template download links.
"""

import urllib.request
import ssl
import re
from bs4 import BeautifulSoup

def inspect_journal(name, urls):
    print(f"\n==========================================")
    print(f"Checking Journal: {name}")
    print(f"==========================================")
    
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}
    
    for url in urls:
        try:
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=12, context=ctx) as resp:
                html = resp.read().decode("utf-8", errors="ignore")
                soup = BeautifulSoup(html, "html.parser")
                
                print(f"\n[+] URL: {url} (HTTP {resp.status})")
                title = soup.title.string.strip() if soup.title else "No Title"
                print(f"    Title: {title}")
                
                # Check for APC / Fee indications
                text = soup.get_text(separator=" ", strip=True)
                fee_matches = re.findall(r"(?:diamond open access|free of charge|article processing charge|apc|publication fee|\$\d+|\d+\s*usd|\d+\s*eur)", text, re.IGNORECASE)
                if fee_matches:
                    print(f"    [!] Fee Keywords Found: {list(set(fee_matches))[:6]}")
                
                # Check for template links
                templates = []
                for a in soup.find_all("a", href=True):
                    t = a.get_text(strip=True)
                    h = a["href"]
                    if any(k in h.lower() or k in t.lower() for k in ["template", "guidelines", "author", "style", ".docx", ".doc", ".zip"]):
                        templates.append((t, h))
                
                if templates:
                    print("    [*] Relevant Template / Guideline Links:")
                    for t, h in templates[:8]:
                        print(f"        - {t} -> {h}")
        except Exception as e:
            print(f"[-] Failed {url}: {e}")

if __name__ == "__main__":
    # Example probe targets
    sample_targets = {
        "Periodica Polytechnica EECS": [
            "https://pp.bme.hu/eecs/about",
            "https://pp.bme.hu/eecs/about/submissions"
        ],
        "Computer Science (AGH UST)": [
            "https://journals.agh.edu.pl/csci/about",
            "https://journals.agh.edu.pl/csci/about/submissions"
        ],
        "ECTI-CIT": [
            "https://ph01.tci-thaijo.org/index.php/ecticit/about",
            "https://ph01.tci-thaijo.org/index.php/ecticit/author-guidelines"
        ]
    }
    
    for name, urls in sample_targets.items():
        inspect_journal(name, urls)
