## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

## all: generate docs, lint
.PHONY: all
all: doc lint

venv:
	python3 -m venv venv
	venv/bin/pip install -r scripts/requirements.txt

## doc: generate documentation
.PHONY: doc
doc: scripts/nvim_doc_tools venv
	venv/bin/python scripts/main.py generate
	venv/bin/python scripts/main.py lint

## lint: run linters and LuaLS typechecking
.PHONY: lint
lint: scripts/nvim-typecheck-action fastlint
	./scripts/nvim-typecheck-action/typecheck.sh --workdir scripts/nvim-typecheck-action lua

## fastlint: run only fast linters
.PHONY: fastlint
fastlint: scripts/nvim_doc_tools venv
	venv/bin/python scripts/main.py lint
	luacheck lua --formatter plain
	stylua --check lua

scripts/nvim_doc_tools:
	git clone https://github.com/stevearc/nvim_doc_tools scripts/nvim_doc_tools

scripts/nvim-typecheck-action:
	git clone https://github.com/stevearc/nvim-typecheck-action scripts/nvim-typecheck-action

## clean: reset the repository to a clean state
.PHONY: clean
clean:
	rm -rf scripts/nvim_doc_tools scripts/nvim-typecheck-action venv examples/file_explorers/tmp plugins