#!/usr/bin/env bash

function installPromtool {
  promtoolVersion=$1
  if [[ "${promtoolVersion}" == "latest" ]]; then
    echo "Checking the latest version of Promtool"
    promtoolVersion=$(git ls-remote --tags --refs --sort="v:refname"  git://github.com/prometheus/prometheus | grep -v '[-].*' | tail -n1 | sed 's/.*\///' | cut -c 2-)
    if [[ -z "${promtoolVersion}" ]]; then
      echo "Failed to fetch the latest version"
      exit 1
    fi
  fi


  url="https://github.com/prometheus/prometheus/releases/download/v${promtoolVersion}/prometheus-${promtoolVersion}.linux-amd64.tar.gz"

  echo "Downloading Promtool v${promtoolVersion}"
  curl -s -S -L -o /tmp/promtool_${promtoolVersion} ${url}
  if [ "${?}" -ne 0 ]; then
    echo "Failed to download Promtool v${promtoolVersion}"
    exit 1
  fi
  echo "Successfully downloaded Promtool v${promtoolVersion}"

  echo "Unzipping Promtool v${promtoolVersion}"
  tar -zxf /tmp/promtool_${promtoolVersion} --strip-components=1 --directory /usr/local/bin &> /dev/null
  if [ "${?}" -ne 0 ]; then
    echo "Failed to unzip Promtool v${promtoolVersion}"
    exit 1
  fi
  echo "Successfully unzipped Promtool v${promtoolVersion}"
}

promtoolv=${PROMTOOL_VERSION:="latest"}
installPromtool $promtoolv
