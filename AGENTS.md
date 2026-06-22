# AGENTS.md

This repository contains an Ethos Lua tool for configuring ESCape32 speed controllers.

## Project Map

- Entry point: `src/escape32/main.lua`
- VS Code/Ethos deployment helpers: `.vscode/`
- ETHOS Suite package tooling: `bin/package/`

## Change Rules

- Keep the install folder as `escape32` unless the deployment and packaging config are changed together.
- Avoid runtime allocations in `wakeup` and `paint` paths where practical.
- Keep radio-facing Lua simple and explicit; prefer small modules once behavior grows.
- Do not commit generated ZIP packages or simulator staging folders.

## Validation

- Syntax check Lua changes when `luac` is available: `luac -p src/escape32/main.lua`
- Build and validate the ETHOS package:
  - `python3 bin/package/build_package.py --artifact-version 0.1.0 --output-dir /tmp`
  - `python3 bin/package/validate_ethos_manifest_zip.py /tmp/escape32-0.1.0.zip`

