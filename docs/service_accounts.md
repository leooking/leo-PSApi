### CLI Syntax

- gcloud projects add-iam-policy-binding pscibis-prod --member="serviceAccount:pscibis-stag-api-storage@pscibis-stag.iam.gserviceaccount.com" --role="roles/cloudsql.client"
- gcloud projects add-iam-policy-binding pscibis-stag --member="serviceAccount:pscibis-stag-api-storage@pscibis-stag.iam.gserviceaccount.com" --role="roles/storage.buckets.create"
- gcloud alpha iam policies lint-condition
- gcloud projects get-iam-policy pscibis-prod  \
  --flatten="bindings[].members" \
  --format='table(bindings.role)' \
  --filter="bindings.members:153419342863-compute@developer.gserviceaccount.com"
- gcloud projects get-iam-policy pscibis-stag  \
  --flatten="bindings[].members" \
  --format='table(bindings.role)' \
  --filter="bindings.members:pscibis-stag-api-storage@pscibis-stag.iam.gserviceaccount.com"
- gcloud projects get-iam-policy pscibis-prod  \
  --flatten="bindings[].members" \
  --format='table(bindings.role)' \
  --filter="bindings.members:pscibis-prod-api-storage@pscibis-prod.iam.gserviceaccount.com"

## Staging pscibis-stag

- 597763609004-compute@developer.gserviceaccount.com              Default GCR SA
    ROLE
    roles/cloudsql.client
    roles/editor

- pscibis-stag-api-storage@pscibis-stag.iam.gserviceaccount.com
    key_id: 2f9b4144dffd96f9b2fb293ff9173348aa0cb1bd              STORAGE_CREDENTIALS JSON / JK .env JSON
    ROLE
    roles/storage.admin

- psci-stag-vector-storage@pscibis-stag.iam.gserviceaccount.com
    key_id: d5f3605cdefae13445da630b8b2921a20f9fff3d              AH .env JSON
    ROLE
    roles/cloudsql.client
    roles/storage.objectViewer

- rails-api-cloud-run@pscibis-stag.iam.gserviceaccount.com        No usage log entries
    ROLE
    roles/secretmanager.secretAccessor


## Production pscibis-prod

- 153419342863-compute@developer.gserviceaccount.com              Default GCR SA
    ROLE
    roles/cloudsql.client
    roles/editor

- pscibis-prod-api-storage@pscibis-prod.iam.gserviceaccount.com
    key_id: 7cd65813c1d60bb33c94a92334f11cfab24fb84e              STORAGE_CREDENTIALS JSON
    ROLE
    roles/cloudsql.client
    roles/storage.admin


## Observations

- stag POST /orgs goes 500 due to trying to create bucket on non-existent project
- prod POST /orgs goes 500 due to trying to create bucket on json creds file vs a project name