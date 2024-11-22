# ansible-role-prometheus-tailscale-discovery

> [!WARNING]  
> This was copypasta'd from an internal repo and may not work stand-alone. We'll work to make this the version we use too so that we know it works!

An ansible role that uses tailscale to generate an inventory of hosts to then render a prometheus config. Used by the Hachyderm team to automatically regenerate our prometheus configuration as our fleet changes.

## Assumptions

- `tailscale` is installed, up, and the `tailscale` binary is in your user's `$PATH`
- `promtool` is installed (it should be if prometheus is installed), and it's also available on your `$PATH`

## Using in your environment

You'll definetly want to update the [prometheus.yml template](files/etc/prometheus-tailscale-discovery/prometheus.yml.tpl) to match your environment.
