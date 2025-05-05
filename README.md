# Dynamic String API Project

## Overview
A serverless API that serves a dynamically updatable encrypted string from AWS SSM Parameter Store.

## Architecture
![Architecture diagram](https://mermaid.ink/svg/pako:eNptkE1Lw0AQxr9KmLNQm9pE8FAEwYN4EPEgHmR3mo9NdpVsNlGkfvdutk0plB7mYWZ3nvnPM-MqGtC6zrNwYl3mBQ3UxY4J0JXk4r1h9gH5wj1FJz0g2l6jC3C3q7Qb6C3m5Qr6C3m7Q7yD3m5QH5C3m9QX5C3m9Q35D3m7QH5APy4Zv8D7m5kds=)

```mermaid
graph TD
    A[API Gateway] --> B[Lambda Function]
    B --> C[SSM Parameter Store]
    C --> D[KMS Encryption]
```

## Key Components
- AWS Lambda (Python 3.12 runtime)
- API Gateway HTTP API
- SSM Parameter Store with KMS encryption
- IAM roles with least-privilege permissions
- Terraform infrastructure as code

## Prerequisites
- AWS account credentials configured
- OpenTofu 1.6+ installed
- AWS CLI v2 installed

## Deployment
```bash
# Initialize Terraform
tofu init

# Apply configuration (auto-approve for CI/CD)
tofu apply -auto-approve
```

## Usage
### Access API Endpoint
```bash
curl https://d5pmh5sua1.execute-api.eu-west-1.amazonaws.com
```

### Update Dynamic String
```bash
aws ssm put-parameter \
  --name "/merapar/dynamicString" \
  --value "NewStringValue" \
  --type SecureString \
  --overwrite
```

### Destroy Resources
```bash
tofu destroy
```

## Security
- All parameters stored as SecureString with KMS encryption
- IAM roles grant least privilege access
- Automatic key rotation enabled
- Infrastructure changes tracked in version control