#!/bin/bash
# system prep and R package installation
set -eo pipefail

R_VERSION="4.3.3" # default v on bioshell

echo "=========================================="
echo " Environment setup"
echo " R version: ${R_VERSION}"
echo " User library: ${HOME}/.library"
echo "=========================================="

# --- System dependencies ---
echo "[1/4] Installing system dependencies..."
sudo apt install -y -q \
  libhdf5-dev \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev \
  libfontconfig1-dev \
  libharfbuzz-dev \
  libfribidi-dev \
  libfreetype6-dev \
  libpng-dev \
  libtiff5-dev \
  libjpeg-dev \
  libuv1-dev
echo "[1/4] Done."

# --- Check R version ---
# Confirm correct R is on PATH
echo "[2/4] Checking R version..."
LOADED_R=$(R --version | head -1)
echo "Loaded: ${LOADED_R}"

# Bail early if the version doesn't match what we asked for
# TODO: Remove use of modules
# TODO: Bail if R is not executable
if ! echo "${LOADED_R}" | grep -q "${R_VERSION}"; then
  echo "ERROR: Expected R ${R_VERSION} but got: ${LOADED_R}"
  echo "Run 'module spider R' to see available versions."
  exit 1
fi
echo "[2/4] Done."

# --- User library ---
echo "[3/4] Preparing user library..."
export R_LIBS_USER="${HOME}/.library"
mkdir -p "${R_LIBS_USER}"
echo "[3/4] Done."

# --- Run R install script ---
echo "[4/4] Running R package installation..."
Rscript --vanilla "$(dirname "$0")/install_packages.R"
echo "[4/4] Done."

echo ""
echo "=========================================="
echo " Setup complete."
echo "=========================================="

#TODO: Set up .libPaths in .Renviron
# echo "R_LIBS_USER=${R_LIBS_USER}" >> ~/.Renviron

# TODO: move relevant folders and delete repo
