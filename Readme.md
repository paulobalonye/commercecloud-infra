# AWS Infrastructure Deployment
Deployment of AWS Infrastructure (demonstration of HIPAA compliant modules)

## How to use environment modules

- Install [tfenv](https://github.com/tfutils/tfenv)
- Install the terraform version of the module by running: `tfenv install`.
- Use the terraform version: `tfenv use <terraform-version>`

## Initial Remote Backend Setup

- Apply `aws_infrastructure/dev/us-west-1/s3-backend/` without `backend {}` in `backend.tf`.
- Uncomment/Add `backend {}` in `backend.tf` file afterwards. On next apply, terraform will refresh backend ask us to copy local state to S3. 
```
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "s3" backend. No existing state was found in the newly
  configured "s3" backend. Do you want to copy this state to the new "s3"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: yes
```
- Enter `yes` to move local backend to remote.