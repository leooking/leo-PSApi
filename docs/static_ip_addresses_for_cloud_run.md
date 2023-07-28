
**Static egress IP for the api:**

- `gcloud compute addresses describe pscibis-stag-api-static-ip --region us-central1`
- `gcloud compute addresses describe pscibis-prod-api-static-ip --region us-central1`
  - stag rails static IP: `34.135.12.101`
  - prod rails static IP: `34.136.210.248`



**Jake setup commands:**

Use named subnet in pscibis-stag-vpc-shared (us-west1)
```
gcloud compute networks subnets create pscibis-stag-vpc-cloudrun-egress \
--range=10.132.0.0/28 --network=pscibis-stag-vpc-shared --region=us-central1
```
ERROR: (gcloud.compute.networks.subnets.create) Could not fetch resource:
 - The resource 'projects/pscibis-prod/global/networks/pscibis-stag-vpc-shared' was not found



Create VPC access connector using shared vpc
```
gcloud compute networks vpc-access connectors create vac-pscibis-stag-api  \
  --region=us-central1 \
  --subnet-project=pscibis-stag \
  --subnet=pscibis-stag-vpc-cloudrun-egress
```

Create Router
```
gcloud compute routers create pscibis-stag-api-nat-router \
  --network=pscibis-stag-vpc-shared \
  --region=us-central1
```

Reserve Static IP
```
gcloud compute addresses create pscibis-stag-api-static-ip --region=us-central1
```

