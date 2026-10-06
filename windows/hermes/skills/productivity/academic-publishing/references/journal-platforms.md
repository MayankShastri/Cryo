# Academic Journal Platform Archetypes & Navigation Quirks

When vetting journals and scraping author guidelines/templates, journal platforms exhibit specific structural patterns:

## 1. Public Knowledge Project Open Journal Systems (PKP OJS 3+)
- **Pattern:** `https://<domain>/index.php/<journal_code>/about/submissions`
- **Common URLs:**
  - Submissions & Checklist: `/about/submissions`
  - Focus & Scope: `/about`
  - Author Guidelines: `/information/authors` or `/about/submissions#authorGuidelines`
- **Templates:** Often stored under `/public/journals/<id>/styles/...` as `.zip`, `.cls`, `.docx`.
- **Examples:** AGH University of Science & Technology (`journals.agh.edu.pl/csci`), BME Periodica Polytechnica (`pp.bme.hu/eecs`).

## 2. Thai Journals Online (ThaiJO / ThaiES)
- **Pattern:** `https://ph01.tci-thaijo.org/index.php/<journal_code>` or `ph02...`
- **Author Guidelines & Templates:**
  - Dedicated pages: `/author-guidelines`, `/For-Authors`, `/about/submissions`
  - Templates often hosted as Google Docs export links (`docs.google.com/document/d/.../export?format=docx`) or OJS article view downloads.
- **Sister Journal Pitfall:** Associations like ECTI publish multiple journals (e.g., ECTI-CIT vs. ECTI-EEC). One transaction may charge page fees ($100+ for ECTI-EEC) while another remains strictly 0-APC ($0 for ECTI-CIT). Always check the exact journal code.

## 3. Custom / ASPX University & Society Portals
- **Pattern:** `http://journal.<domain>/Public/...`
- **Quirk:** Root navigation may return 404 or empty wrappers unless navigated via the `/Public/` virtual directory (e.g. `journal.telfor.rs/Public/InformationForAuthors.aspx`).
- **Templates:** Directly downloadable `.doc` / `.pdf` files linked inside the author instructions page.

## 4. DSpace / Institutional Repositories
- **Pattern:** University publishers often host official templates inside an institutional repository rather than the CMS (e.g., `repozitorium.omikk.bme.hu/bitstreams/<uuid>/download`).
