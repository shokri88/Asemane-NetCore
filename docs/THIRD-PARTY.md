# Third-party assets

- Bootstrap 5.3.8 CSS RTL and bundled JavaScript are vendored under `wwwroot/lib/bootstrap`. Bootstrap is MIT licensed; upstream: https://github.com/twbs/bootstrap/tree/v5.3.8 . Copyright/license headers are retained. No CDN is required at runtime.
- `wwwroot/theme/logo.png` comes from the user-supplied repository `shokri88/Asemane-UI`, original path `img/main/logo/logo.png`, source commit `5c4149ebfb028c19fea918ec638246889607205b`. Rights are inherited from the supplied project; no new license is asserted for that asset.
- .NET/EF/Identity and other NuGet dependencies retain their upstream licenses. Test-only SQLite and xUnit are not production database choices.
- The original Prague/jQuery/Swiper template CSS, JavaScript, fonts, logo and supporting UI images are preserved byte-for-byte under `wwwroot/template`, from user-supplied `shokri88/Asemane-UI` commit `5c4149ebfb028c19fea918ec638246889607205b`. Original copyright/license headers remain intact; rights are inherited from the supplied project and no new license is asserted. Demo project photographs are not used as published CMS content.
- `docs/template-assets.sha256.json` records SHA256 values for the copied files; the integration suite verifies those values.

- Admin text editor: Summernote Lite 0.9.1 and its Persian localization (MIT), https://github.com/summernote/summernote ; jQuery 3.7.1 (MIT), https://github.com/jquery/jquery . Files are vendored under `wwwroot/lib/summernote` and `wwwroot/lib/jquery`; licenses are included. npm tarball integrity was verified before extraction. Public template dependencies are unchanged.
- Server HTML sanitization: HtmlSanitizer 11.0.26 (MIT), https://github.com/mganss/HtmlSanitizer , with AngleSharp dependencies installed by NuGet.
