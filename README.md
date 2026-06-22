# ESCape32 Lua Ethos Tool

Ethos Lua tool bootstrap for configuring ESCape32 speed controllers from FrSky Ethos radios.

Requires ESCape32 firmware with the S.Port Lua config protocol enabled. The protocol uses
Rotorflight-style MSP chunks over S.Port (`0x30` requests, `0x32` replies) to read and
write the ESCape32 config image. Current 32 KB STM32F051 ESCape32 builds do not include
the config protocol due to ROM limits.

## Layout

- `src/escape32/` is the installable script folder copied to `SCRIPTS:/escape32`.
- `.vscode/` contains deployment tasks adapted from Rotorflight Lua Ethos Suite.
- `bin/package/` builds and validates ETHOS Suite installable ZIP packages.

## VS Code Deployment

The deployment target is configured in `.vscode/deploy.json`:

```json
{
  "tgt_name": "escape32"
}
```

Useful tasks:

- `Deploy & Launch [SIM]` copies `src/escape32` into the configured local simulator folder.
- `Deploy Radio` copies `src/escape32` to the connected radio.
- `Deploy Radio [Fast]` mirrors only changed files.
- `Deploy Radio + Serial Debug` deploys, then tails the radio serial debug output.

The simulator destination is built from `.vscode/settings.json`, defaulting to:

```text
simulators/X20S_FCC@nightly26/scripts/escape32
```

## Packaging

Build an ETHOS Suite installable ZIP:

```sh
python3 bin/package/build_package.py --artifact-version 0.2.0 --output-dir /tmp
python3 bin/package/validate_ethos_manifest_zip.py /tmp/escape32-0.2.0.zip
```

The package manifest installs into `SCRIPTS:/escape32`.

