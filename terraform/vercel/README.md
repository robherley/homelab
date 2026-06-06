# Terraform — Vercel DNS (reb.gg)

Manages `reb.gg` DNS records with the [`vercel/vercel`] provider. State in
Terraform Cloud (`reb-labs/vercel`, **Local execution**); the API token comes from
1Password via the `just tf vercel` recipe.

## Files

```
versions.tf   # TFC backend + vercel provider
providers.tf  # reads VERCEL_API_TOKEN from env
variables.tf  # domain (reb.gg)
records.tf    # the DNS records (generated via import, then maintained by hand)
```

## Use

```sh
just tf vercel plan
just tf vercel apply
```

`just tf vercel` injects `VERCEL_API_TOKEN` from `op://Homelab/vercel/password`.

## Adding a record

Add a `vercel_dns_record` block to `records.tf`:

```hcl
resource "vercel_dns_record" "a_example" {
  domain = var.domain
  name   = "example"
  type   = "A"
  value  = "1.2.3.4"
  ttl    = 60
}
```

## Importing an existing record (the initial 28 were done this way)

1. Add an `import` block (temporary file, e.g. `imports.tf`):
   ```hcl
   import {
     to = vercel_dns_record.<name>
     id = "rec_xxxxxxxx"   # Vercel record ID (GET /v4/domains/reb.gg/records)
   }
   ```
2. `just tf vercel plan -generate-config-out=generated.tf` — Terraform writes the
   matching resource config.
3. Move the resource(s) into `records.tf`, `just tf vercel apply`, then delete the
   `import` block.

## Notes

- All 28 pre-existing records (iCloud mail, SendGrid DKIM, GitHub Pages, A records,
  Minecraft SRVs, CAA, Vercel apex/wildcard ALIASes) were imported with zero drift.
- The Vercel-managed `ALIAS @/*` records are in here too; if you reassign the apex
  to a different Vercel project, expect a diff and reconcile.

[`vercel/vercel`]: https://registry.terraform.io/providers/vercel/vercel/latest/docs
