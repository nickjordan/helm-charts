#!/usr/bin/env bash

trap "exit 1" TERM
export TOP_PID=$$

# Create a unique project name
export project_name="grafana-operator-$(date +'%d%m%Y')"

install() {
  echo "Install - $(pwd)"

  oc new-project "${project_name}"

  # Installs this chart from local directory (.)
  helm upgrade --install grafana-operator -f values.yaml \
    --namespace "${project_name}" \
    .
}

test() {
  echo "Test - $(pwd)"

  # CHANGE these if your chart/deployment names differ
  local deployment_name="grafana-operator-controller-manager"
  local route_name="grafana-route"

  # Wait up to 2 minutes for the operator Deployment to appear
  timeout 2m bash <<"EOT"
  run() {
    echo "Attempting oc get deployment/${deployment_name} in ${project_name} ..."
    while [[ $(oc get deployment/${deployment_name} -n ${project_name} -o name 2>/dev/null) != "deployment.apps/${deployment_name}" ]]; do
      sleep 10
    done
  }
  run
EOT

  # Wait for rollout to complete
  oc rollout status "deployment/${deployment_name}" \
    -n "${project_name}" \
    --watch=true

  # Now wait up to 2 minutes for the Grafana route to return HTTP 200
  timeout 2m bash <<"EOT"
  run() {
    host=$(oc get route/${route_name} -n ${project_name} -o jsonpath='{.spec.host}')
    echo "Checking route host: $host"

    while [[ $(curl -L -k -s -o /dev/null -w '%{http_code}' "http://$host") != "200" ]]; do
      sleep 10
    done
  }
  run
EOT

  # If the above block timed out, show debug info and fail
  if [[ $? != 0 ]]; then
    echo "CURL timed out. Failing."

    host=$(oc get route/${route_name} -n "${project_name}" -o jsonpath='{.spec.host}')
    curl -L -k -vvv "http://${host}"
    exit 1
  fi

  echo "Test complete: Grafana is returning HTTP 200."
}

cleanup() {
  echo "Cleanup - $(pwd)"
  helm uninstall grafana-operator --namespace "${project_name}"
  oc delete project "${project_name}"
}

# Process arguments
case "$1" in
  install)
    install
    ;;
  test)
    test
    ;;
  cleanup)
    cleanup
    ;;
  *)
    echo "Not an option. Use: install | test | cleanup"
    exit 1
    ;;
esac
