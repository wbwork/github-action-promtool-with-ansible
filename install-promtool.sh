#!/usr/bin/env bash

function downloadPromtool {
  promtoolVersion=$1
  promUrl="https://github.com/prometheus/prometheus/releases/download/v${promtoolVersion}/prometheus-${promtoolVersion}.linux-amd64.tar.gz"
  status_code=$(curl -s -S -L -w "%{http_code}"  -o /tmp/promtool_${promtoolVersion} ${promUrl})
  echo $status_code
}


function installPromtool {
  promtoolVersion=$1
  if [[ "${promtoolVersion}" == "latest" ]]; then
    echo "Checking the latest version of Promtool"
    promtoolVersion=$(git ls-remote --tags --refs --sort="v:refname"  https://github.com/prometheus/prometheus | grep -v '[-].*' | tail -n1 | sed 's/.*\///' | cut -c 2-)
    if [[ -z "${promtoolVersion}" ]]; then
      echo "Failed to fetch the latest version"
      exit 1
    fi
  fi

  echo "Downloading Promtool v${promtoolVersion}"
  http_code=$(downloadPromtool $promtoolVersion)
  if [ "${?}" -ne 0 ]; then
    echo "Failed to download Promtool v${promtoolVersion}"
    exit 1
  fi
  
  # we should fail 5xx also 
  if [[ $http_code -ge 500 && $status_code -lt 600 ]]; then
    echo "HTTP Status is 5xx. Exiting..."
    exit 1
  fi

  #retry next minor on 404
  counter=2
  while [ $http_code -eq 404 ]
  do
     echo "Release artifact for $promtoolVersion not found, trying previous available version"
     promtoolVersion=$(git ls-remote --tags --refs --sort="v:refname"  https://github.com/prometheus/prometheus | grep -v '[-].*' | tail -n${counter} | head -1 | sed 's/.*\///' | cut -c 2-)
     http_code=$(downloadPromtool $promtoolVersion)
     counter=$(( counter + 1 ))
  done

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
