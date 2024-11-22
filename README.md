# ansible-role-prometheus-tailscale-discovery

> [!WARNING]  
> This was copypasta'd from an internal repo and may not work stand-alone. We'll work to make this the version we use too so that we know it works!

An ansible role that uses tailscale to generate an inventory of hosts to then render a prometheus config. Used by the Hachyderm team to automatically regenerate our prometheus configuration as our fleet changes.

## Assumptions

- `tailscale` is installed, up, and the `tailscale` binary is in your user's `$PATH`
- `promtool` is installed (it should be if prometheus is installed), and it's also available on your `$PATH`

## Using in your environment

You'll definetly want to update the [prometheus.yml template](files/etc/prometheus-tailscale-discovery/prometheus.yml.tpl) to match your set up. In particular, you'll want the various scrape sections to
match the architecture of your application, and this, in turn, should match how you're tagging hosts in Tailscale.

### Tailscale Tagging

Here is a snippet of our tailscale configuration:

```hujson
	"tagOwners": {
		// For each "type" of tag, there is a "parent tag" (like `tag:env-dev`'s parent is `tag:env`).
		// The parent tag is assigned as an owner so that it allows anyone bearing that tag
		// to attach any of the specific tags in that family.
		// We specifically use this in our OAuth clients so they can bring up any host.
		// Ref: https://login.tailscale.com/admin/settings/oauth
		// One day, we might have distinct OAuth clients for dev & prod for good separation.

		// tag:server indicates this is a persistent host, not a human-controlled machine
		// owns itself so it can assign itself when attached to an oauth client
		"tag:server": ["autogroup:members", "tag:server"],
		// Environments
		"tag:env":      ["autogroup:members"],
		"tag:env-dev":  ["autogroup:members", "tag:env"],
		"tag:env-prod": ["autogroup:members", "tag:env"],
		// Systems
		"tag:system":            ["autogroup:members"],
		"tag:system-hachyderm":  ["autogroup:members", "tag:system"],
		"tag:system-nova-stuff": ["autogroup:members", "tag:system"],
		// Roles
		"tag:role":                    ["autogroup:members"],
		"tag:role-mastodon-web":       ["autogroup:members", "tag:role"],
		"tag:role-mastodon-streaming": ["autogroup:members", "tag:role"],
		"tag:role-mastodon-sidekiq":   ["autogroup:members", "tag:role"],
		"tag:role-redis":              ["autogroup:members", "tag:role"],
		"tag:role-postgres-primary":   ["autogroup:members", "tag:role"],
		"tag:role-postgres-backup":    ["autogroup:members", "tag:role"],
		"tag:role-edge-cdn":           ["autogroup:members", "tag:role"],
		"tag:role-grafana":            ["autogroup:members", "tag:role"],
		"tag:role-prometheus":         ["autogroup:members", "tag:role"],
		"tag:role-elasticsearch":      ["autogroup:members", "tag:role"],
		"tag:role-translation":        ["autogroup:members", "tag:role"],
		// Regions
		"tag:region":               ["autogroup:members"],
		"tag:region-namer-east":    ["autogroup:members", "tag:region"],
		"tag:region-namer-central": ["autogroup:members", "tag:region"],
		"tag:region-samer-east":    ["autogroup:members", "tag:region"],
		"tag:region-samer-west":    ["autogroup:members", "tag:region"],
		"tag:region-namer-west":    ["autogroup:members", "tag:region"],
		"tag:region-emea":          ["autogroup:members", "tag:region"],
		"tag:region-emea-east":     ["autogroup:members", "tag:region"],
		"tag:region-emea-central":  ["autogroup:members", "tag:region"],
		"tag:region-emea-west":     ["autogroup:members", "tag:region"],
		"tag:region-africa-north":  ["autogroup:members", "tag:region"],
		"tag:region-africa-south":  ["autogroup:members", "tag:region"],
		"tag:region-apac":          ["autogroup:members", "tag:region"],
		// Providers
		"tag:provider":               ["autogroup:members"],
		"tag:provider-linode":        ["autogroup:members", "tag:provider"],
		"tag:provider-hetzner-cloud": ["autogroup:members", "tag:provider"],
		"tag:provider-hetzner-robot": ["autogroup:members", "tag:provider"],
		"tag:provider-digitalocean":  ["autogroup:members", "tag:provider"],
		"tag:provider-nova":          ["autogroup:members", "tag:provider"],
	},
```
When we attach a machine to our tailnet, we attach the appropriate tags to the machine, like so:

![image](https://github.com/user-attachments/assets/fea2072c-5054-47d0-946b-a402a27be501)

