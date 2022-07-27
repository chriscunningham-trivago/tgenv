#!/usr/bin/env bash

set -uo pipefail;

function tgenv-exec() {
  for _arg in ${@:1}; do
    if [[ "${_arg}" == -chdir=* ]]; then
      log 'debug' "Found -chdir arg. Setting TFENV_DIR to: ${_arg#-chdir=}";
      export TFENV_DIR="${PWD}/${_arg#-chdir=}";
    fi;
  done;

  log 'debug' 'Getting version from tgenv-version-name';
  TFENV_VERSION="$(tgenv-version-name)" \
    && log 'debug' "TFENV_VERSION is ${TFENV_VERSION}" \
    || {
      # Errors will be logged from tgenv-version name,
      # we don't need to trouble STDERR with repeat information here
      log 'debug' 'Failed to get version from tgenv-version-name';
      return 1;
    };
  export TFENV_VERSION;

  if [ ! -d "${TFENV_CONFIG_DIR}/versions/${TFENV_VERSION}" ]; then
  if [ "${TFENV_AUTO_INSTALL:-true}" == "true" ]; then
    if [ -z "${TFENV_Terragrunt_VERSION:-""}" ]; then
      TFENV_VERSION_SOURCE="$(tgenv-version-file)";
    else
      TFENV_VERSION_SOURCE='TFENV_Terragrunt_VERSION';
    fi;
      log 'info' "version '${TFENV_VERSION}' is not installed (set by ${TFENV_VERSION_SOURCE}). Installing now as TFENV_AUTO_INSTALL==true";
      tgenv-install;
    else
      log 'error' "version '${TFENV_VERSION}' was requested, but not installed and TFENV_AUTO_INSTALL is not 'true'";
    fi;
  fi;

  TF_BIN_PATH="${TFENV_CONFIG_DIR}/versions/${TFENV_VERSION}/terragrunt";
  export PATH="${TF_BIN_PATH}:${PATH}";
  log 'debug' "TF_BIN_PATH added to PATH: ${TF_BIN_PATH}";
  log 'debug' "Executing: ${TF_BIN_PATH} $@";

  exec "${TF_BIN_PATH}" "$@" \
  || log 'error' "Failed to execute: ${TF_BIN_PATH} $*";

  return 0;
};
export -f tgenv-exec;
