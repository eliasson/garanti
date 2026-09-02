#
# Helper for publishign the TWO packages of Garanti.
#
# First the `garanti` package should be published, then update the `garanti_erlang`
# package to use hex and publish that.
#
# For local development it is convenient to use local paths as dependency from `garanti_erlang`

.PHONY: sync-docs check-garanti-erlang-dep test test-garanti test-garanti-erlang \
        publish-garanti publish-garanti-erlang publish clean-docs

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
