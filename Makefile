.PHONY: render
render:
	gomplate -f files/etc/prometheus-tailscale-discovery/prometheus.yml.tpl -d tailscale=files/sample/tailscale-status.json > files/sample/prometheus.rendered.yml

.PHONY: repl
repl:
	# If you're focusing on a specific part of the file, grep out the header
	watch 'gomplate -f files/etc/prometheus-tailscale-discovery/prometheus.yml.tpl -d tailscale=files/sample/tailscale-status.json'

.PHONY: lint
lint: render
	promtool check config files/sample/prometheus.rendered.yml

/usr/local/bin/promtool:
	VERSION=$(curl -Ls https://api.github.com/repos/prometheus/prometheus/releases/latest | jq ".tag_name" | xargs | cut -c2-)
	wget -qO- "https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-$VERSION.linux-amd64.tar.gz" \
	| tar xvzf - "prometheus-$VERSION.linux-amd64"/promtool --strip-components=1
	sudo mv promtool /usr/local/bin/promtool
