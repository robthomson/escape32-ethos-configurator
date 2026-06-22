@echo off
setlocal

set VERSION=%1
if "%VERSION%"=="" set VERSION=0.1.0

set OUT_DIR=%2
if "%OUT_DIR%"=="" set OUT_DIR=dist

python bin\package\build_package.py --artifact-version "%VERSION%" --output-dir "%OUT_DIR%"

