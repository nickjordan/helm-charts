# ⚓️ Grafana Operator Helm Deploy

ArgoCD Helm Chart customizes and deploys the [Grafana Operator](https://github.com/redhat-developer/grafana-operator).

## Installing the chart

To install the chart from source:
```bash
# within this directory charts/grafana-operator
helm upgrade --install argocd -f values.yaml . --create-namespace --namespace labs-grafana
```

The above command creates objects with default naming convention and configuration.

To install the chart from the published chart (with defaults):
```bash
# add the redhat-cop repository
helm repo add redhat-cop https://redhat-cop.github.io/helm-charts

# having added redhat-cop helm repository
helm upgrade --install argocd redhat-cop/grafana-operator --create-namespace --namespace labs-grafana
```

## Removing

To delete the chart:
```bash
helm uninstall grafana-operator --namespace labs-grafana
```

If you wish to use ArgoCD to manage this chart directly (or as a helm chart dependency) you may need to make use of the `ignoreHelmHooks` flag to ignore helm lifecycle hooks.

helm upgrade --install foo redhat-cop/grafana-operator --set operator=null --set ignoreHelmHooks=true
```

Or deploying just the Operator, no helm lifecycle hooks and no team instances.
```bash
helm upgrade --install foo redhat-cop/grafana-operator --set namespaces=null --set ignoreHelmHooks=true
