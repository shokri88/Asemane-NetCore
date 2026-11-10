# Original-template HTML/style audit

Run from the repository root with the sibling `Asemane-UI` checkout available. The public reference is the seven root HTML pages at source commit `5c4149ebfb028c19fea918ec638246889607205b`; `other/` contains unused alternative templates, not app routes.

This optional developer tool uses the existing SQLite integration fixture and a localhost HTTPS Kestrel host. It seeds twelve published projects (nine featured), three articles, six members, a generic page and representative role-specific media copied from the supplied UI. It does not connect to SQL Server, modify production users or seed application databases. It uses the existing test-only administrator credentials from `CmsFactory`.

Prerequisites: .NET 10, an ASP.NET developer HTTPS certificate, Python with `requirements.txt`, and Chromium (override `--chromium` if not `/usr/bin/chromium`). Keep artifacts outside the checkout.

```sh
# Terminal 1; arguments are repository, template checkout, output folder and port.
dotnet run --project tools/TemplateAuditHost -- "$PWD" ../Asemane-UI /tmp/asemane-template-audit 7445

# Terminal 2
python3 tools/template-audit/audit.py --template ../Asemane-UI --repo . --output /tmp/asemane-template-audit
python3 tools/template-audit/runtime.py --output /tmp/asemane-template-audit
```

Stop only this test host with Ctrl+C after the checks. Do not enable it as the production startup workflow. Browser contexts accept the local development certificate and block third-party requests; live Google Maps content is outside the audit.

`audit.py` checks each copied vendor file against both the SHA256 manifest and the original checkout, and checks stylesheet/script order. It builds an independent reference from the original HTML by substituting only text/URLs, content bodies, record counts and category selectors. It preserves the source layout containers; dynamic title links must match the source plain title typography in pixels. It compares Home, About, Contact, projects, project details, blog and article details. Generic page/member details use the original article-detail template as their shared visual reference.

Previously authorized changes are explicit exceptions: the common five-item navigation (built independently from the original index.html header with Project Details removed), invisible SEO headings/pagination, data-specific IDs, non-styling WordPress record classes and content links. Static comparisons remove scripts/loaders on both sides, supply the same media/text and compare full-page PNGs at 1440, 768 and 390 pixels. They validate HTML/CSS appearance, not all possible content or animation states.

`runtime.py` separately runs JavaScript on all nine real pages at all three widths, opens/closes the mobile menu, checks counters/gallery/iframe, duplicate IDs, headings and local resources. It visits all twelve admin views in thirteen states (including new/edit content, login, access denied and password reset) at desktop/mobile widths and checks special error and empty-gallery routes. Admin/error screens have no upstream HTML counterpart, so their results are behavior/responsive inspections, not claims of template parity. Horizontal overflow is measured and reported rather than silently changed; an inherited template layout may itself overflow.

A successful command requires actual comparisons to pass. `results.json`, `runtime-results.json`, rendered HTML and screenshots are written to the selected output folder. Review these and report expected differences/limits without describing absent reference pages as matched.

For only the admin/special checks, pass `--admin-only` to `runtime.py`; that writes `runtime-admin-results.json`. This is useful when extending admin coverage after the public matrix has already passed.
