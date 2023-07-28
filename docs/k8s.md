## Kubernetes 1.25.7-gke.1000

- psci-stag-qdrant-lkwer 35.224.228.243
- psci-prod-qdrant 34.28.10.16
- nginx reverse proxy pod for ssl, api_key  & load balancing
  - BmDzvO71VkG50NirFjXJ
  - of8tLLi2GXicqCvWuoEE
- qdrant-0.2.8 statefulset controller
  - replicas
  - storage
  - node ram

**Commands:**

- gcloud config set project pscibis-prod
- gcloud config set project pscibis-stag
- helm upgrade -f file.yml to modify a chart
- set your context and confirm current context
  - kubectl config get-contexts
  - kubectl config current-context
  - gcloud container clusters get-credentials psci-stag-qdrant-lkwer --region=us-central1 --project=pscibis-stag    # choose cluster
  - gcloud container clusters get-credentials psci-prod-qdrant --region=us-central1 --project=pscibis-prod          # choose cluster
  - kubectl config current-context
  - kubectl config use-context psci-prod-qdrant
- kubectl logs --tail=10 psci-stag-qdrant-0
- kubectl get namespaces
- kubectl config view
- kubectl explain pods                          # get the documentation for pod manifests
- kubectl get pod my-pod -o yaml                # Get a pod's YAML
- kubectl get services                          # List all services in the namespace
- kubectl get pods --all-namespaces             # List all pods in all namespaces
- kubectl get pods -o wide                      # List all pods in the current namespace, with more details
- kubectl get deployment my-dep                 # List a particular deployment
- kubectl get statefulsets                      # List all statefulsets
- kubectl get pods                              # List all pods in the namespace
- kubectl get pod psci-stag-qdrant-0 -o /Users/jk/dev/psci/5_psci-yaml/qdrant/stag_config/qdrant0_stag.yaml
- kubectl get pod psci-stag-qdrant-1 -o /Users/jk/dev/psci/5_psci-yaml/qdrant/stag_config/23-04-09_qdrant1_stag.yaml
- kubectl apply -f /Users/jk/dev/psci/5_psci-yaml/qdrant/stag_config|prod_config/foo.yaml     # create / update resources
- kubectl exec psci-stag-qdrant-0 -- env         # execute any command on the container
- kubectl describe nodes
- kubectl get storageclass                       # storage
- kubectl get storageclass standard-rwo -o yaml > standard-rwo-storageclass-stag.yaml   # if allowVolumeExpansion: true 
- kubectl get pvc                                # persistent volume claim              #   modify the size in the claim

- kubectl get statefulset psci-stag-qdrant-0 -o yaml
- kubectl get statefulset psci-stag-qdrant-1 -o yaml

- kubectl get pod psci-stag-qdrant-0 -o yaml > /Users/jk/dev/psci/5_psci-yaml/qdrant/config/stag/23-04-10_stag_pod.yaml
- kubectl exec psci-stag-qdrant-0 -- cat config/config.yaml  > prod-config.yaml

**Procedure guide:**

- Scale storage
  - kubectl get pvc
  - confirm storageclass has allowVolumeExpansion: true
  - kubectl edit <pvc> changing requested 
- Node planning
  - e2-standard-8 (8vcpu, 32gb)
  - memory
    - request 40% of available
    - limit 80% of available
  - cpu
    - request 40%
    - limit 80%

