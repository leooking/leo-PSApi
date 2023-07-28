**Remember this:**

- A sudden and surprising GCR deploy non-boot problem where local testing reveals puma shutdown complaining about a missing `secret_key_base` rails error IS A RED HERRING! Troubleshooting a second occurance of this problem, and doing `docker run --env-file .env boot-fail-test-2` and investigating further revealed an underlying problem which was, in this case, caused by an underlying class naming error caused by updating file name (which was initialized at boot) without modifying the contained class name.

**Shorthand notes to deploy local source to GCR:**

1. Full monty:
    - static IP syntax: `git push origin dev && git checkout master && git merge dev && git push origin master && git checkout dev && date && gcloud run deploy psci-stag-api --project pscibis-stag --vpc-connector=vac-pscibis-stag-api --vpc-egress=all-traffic --source . && date && gcloud beta run jobs execute psci-stag-api-migrate --project pscibis-stag && date`
    - static IP syntax: `git push origin dev && git checkout master && git merge dev && git push origin master && git checkout dev && date && gcloud run deploy psci-prod-api --project pscibis-prod --vpc-connector=vac-pscibis-prod-api --vpc-egress=all-traffic --source . && date && gcloud beta run jobs execute psci-prod-api-migrate --project pscibis-prod && date`
1. Deploy the service to a project:
    - `gcloud run deploy psci-stag-api --project pscibis-stag --source .`
    - `gcloud run deploy psci-prod-api --project pscibis-prod --source .`
    
    - `gcloud run deploy psci-stag-vex --project pscibis-stag --source .`
    - `gcloud run deploy psci-prod-vex --project pscibis-prod --source .`

    - `gcloud run deploy psci-stag-chains --project pscibis-stag --source .`
    - `gcloud run deploy psci-prod-chains --project pscibis-prod --source .`

    - `gcloud run deploy psci-stag-crawl --project pscibis-stag --source .`
    - `gcloud run deploy psci-prod-crawl --project pscibis-prod --source .`

    - `gcloud run deploy psci-stag-caller --project pscibis-stag --source .`
    - `gcloud run deploy psci-prod-caller --project pscibis-prod --source .`
1. Run the jobs:
    - `gcloud beta run jobs execute psci-stag-api-migrate --project pscibis-stag`
    - `gcloud beta run jobs execute psci-stag-api-migrate-status --project pscibis-stag`
    - `gcloud beta run jobs execute psci-prod-api-migrate --project pscibis-prod`
    - `gcloud beta run jobs execute psci-prod-api-migrate-status --project pscibis-prod`
1. Tail logs locally:
    - `gcloud beta run services logs tail psci-stag-api --project pscibis-stag`
    - `gcloud beta run services logs tail psci-prod-api --project pscibis-prod`
1. Confirm bucket cors:
    - `gcloud storage buckets describe gs://psci-bis-iqwed --format="default(cors)"`
1. Firebase Q323:
    - [Summary overview](https://fireship.io/lessons/deploy-multiple-sites-to-firebase-hosting/)
    - `firebase login --reauth`
    - `firebase projects:list`
    - `firebase use psci-stag-app-8c52a` for stag
        - `firebase deploy --only hosting:stag`
    - `firebase use pscibis-9864d` for prod
        - `firebase deploy --only hosting:prod`

**Added my ip address to the allowed public pg connections**
**Ran export `RAILS_ENV=hero_pg_stag` enabled us to migrate**

**Preliminary notes to deploy local source to GCR:**

1. set project
    - `gcloud config set project pscibis-stag`
    - `gcloud config set project pscibis-prod`
1. deploy to a specified GCR service
    - `gcloud run deploy psci-stag-api --source .`
    - `gcloud run deploy psci-prod-api --source .`
    - (Allow unauthenticated invocations)
1. rails commands via cloud run jobs
    - `gcloud beta run jobs execute psci-stag-api-migrate`
    - `gcloud beta run jobs execute psci-stag-api-migrate-status`
1. locally tail logs
    - https://cloud.google.com/logging/docs/setup/ruby
    - `gcloud beta run services logs tail psci-stag-api --project pscibis-stag`
    - `gcloud beta run services logs tail psci-prod-api --project pscibis-prod`
1. export GCR service to yaml
    - `gcloud run services describe psci-stag-api --project pscibis-stag --format export > psci-stag-api.yaml`
    - `gcloud run services describe psci-prod-api --project pscibis-prod --format export > psci-prod-api.yaml`
    - `gcloud run services describe psci-stag-vex --project pscibis-stag --format export > psci-stag-vex.yaml`

---

---

**Notes:**

- A cloudbuild.yaml file enables manually customized setup
- docker run -p 8080:8080 gcr.io/pscibis-stag/psci-stag-api	 -e <list of your required env var>
- Needed to set ENV RAILS_LOG_TO_STDOUT to get rails logging in cloud run as expected
- rails console -e pg_localhost_stag

---

**Study:**

- [Pass DB secrets to postgres from cloud run service](https://cloud.google.com/sql/docs/postgres/connect-run)

---

**See available roles on a service account:**

- https://stackoverflow.com/questions/47006062/how-do-i-list-the-roles-associated-with-a-gcp-service-account

```
# list the roles on this sa in this proj
gcloud projects get-iam-policy pscibis-stag  \
--flatten="bindings[].members" \
--format='table(bindings.role)' \
--filter="bindings.members:pscibis-stag-api-storage"
```

ngrok
UBG42BZ8NB
HTGT4YJPY5
79VVQQDYNQ
95FDZDBVSH
7UJ2JCH8GX
CVAZNBKM7Y
U8X2QR2Y8W
6QU5SQDWVQ
ZW5463MDF8
CB62Y8KTFN