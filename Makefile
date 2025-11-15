.PHONY: dev build
dev:
	bun --bun run dev

build:
	bun --bun run build
fmt:
	bunx prettier . --write
