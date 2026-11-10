# Explicit-role sample package

This generator creates development-only SQL/JSON and 67 image assets using the supplied Asemane-UI photos. It never executes SQL. Requires Pillow (the audit environment uses 12.3.0).

First generate `docs/samples/v2/01-current-schema.sql` from the current migrations:

```sh
dotnet ef migrations script --idempotent --project src/Asemane.Web --output docs/samples/v2/01-current-schema.sql
python3 tools/sample-package/build.py --repo . --template ../Asemane-UI --output /tmp/asemane-demo-v2
```

The output ZIP contains reset, current schema and sample scripts, Persian instructions, an image manifest and `App_Data/Uploads`. Photos are cropped only for the generated sample assets: home 2:3, list/portrait 1:1, banner/gallery 16:9. No production app image-processing behavior is added. SQL contains no credentials and no admin account. All sample content is NoIndex. Use the latest code and apply migrations before loading the sample.

Reset must be deliberately executed on the chosen development database: it deletes application data and users, keeps migration history, does not delete physical files and does not disable foreign keys. Do not run it on an active database containing work to preserve. `SamplePackageTests` loads the manifest into the real EF/SQLite model and renders sample routes; ZIP CRC, SHA256, dimensions and byte lengths are verified by the generator. Native SQL Server execution remains a separate validation step.
