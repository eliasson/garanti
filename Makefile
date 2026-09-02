#
# Helper for publishign the TWO packages of Garanti.
#
# First the `garanti` package should be published, then update the `garanti_erlang`
# package to use hex and publish that.
#
# For local development it is convenient to use local paths as dependency from `garanti_erlang`

.PHONY: sync-docs check-garanti-erlang-dep test test-garanti test-garanti-erlang \
        publish-garanti publish-garanti-erlang publish clean-docs tag

GARANTI_VERSION := $(shell grep '^version' garanti/gleam.toml | cut -d '"' -f2)
GARANTI_ERLANG_VERSION := $(shell grep '^version' garanti_erlang/gleam.toml | cut -d '"' -f2)

sync-docs:
	cp README.md LICENSE garanti/
	cp README.md LICENSE garanti_erlang/

check-garanti-erlang-dep:
	@if grep -q 'garanti *= *{ *path' garanti_erlang/gleam.toml; then \
		echo "error: garanti_erlang/gleam.toml still points at garanti via a local path."; \
		echo "Publish garanti first, then change the dependency to a Hex version"; \
		echo "constraint (e.g. \`garanti = \">= 0.1.0 and < 0.2.0\"\`) and run"; \
		echo "\`cd garanti_erlang && gleam deps download\` before publishing."; \
		exit 1; \
	fi

test-garanti:
	cd garanti && gleam test

test-garanti-erlang:
	cd garanti_erlang && gleam test

test: test-garanti test-garanti-erlang

publish-garanti: sync-docs test-garanti
	cd garanti && gleam publish

publish-garanti-erlang: sync-docs check-garanti-erlang-dep test-garanti-erlang
	cd garanti_erlang && gleam publish

publish: publish-garanti

clean-docs:
	rm -f garanti/README.md garanti/LICENSE garanti_erlang/README.md garanti_erlang/LICENSE

# garanti and garanti_erlang are expected to be published in tandem. If not, we'll tag them separately.
tag:
	@if [ "$(GARANTI_VERSION)" != "$(GARANTI_ERLANG_VERSION)" ]; then \
		echo "error: garanti ($(GARANTI_VERSION)) and garanti_erlang ($(GARANTI_ERLANG_VERSION)) versions differ."; \
		echo "Tag each package instead, e.g. \`git tag -a garanti@$(GARANTI_VERSION) ...\`."; \
		exit 1; \
	fi
	git tag -a v$(GARANTI_VERSION) -m "garanti $(GARANTI_VERSION) / garanti_erlang $(GARANTI_ERLANG_VERSION)"
	git push origin v$(GARANTI_VERSION)
