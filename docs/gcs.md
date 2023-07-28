### Google Cloud Storage

- Dedicated GCP prod project for GCS prod
- Limited rights service account
- Unique bucket for each org
- Credentials as a tempfile, built on the fly from ENV

- API needs SA with `Storage Object Creator` and `Storage Object Viewer` roles
  - however I've seen errors saying
  `forbidden: pscibis-stag-api-storage@pscibis-stag.iam.gserviceaccount.com does not have storage.buckets.get access to the Google Cloud Storage bucket.`
    - which is odd 
  - There was a missing legacy thing so needed to go with Storage Admin role
