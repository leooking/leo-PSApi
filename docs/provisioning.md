### Provisioning new customers

1. Create org
1. Create group(s)
1. Load users.csv `org_pid, group_pid, fname, lname, email`
1. Create upload bucket `psci-bis-<org_pid>` in the proper project
   - gsutil mb -p pscibis-prod gs://psci-bis-psci
