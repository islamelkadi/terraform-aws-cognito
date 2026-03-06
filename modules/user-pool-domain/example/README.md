# Complete Example - Custom Domain with ACM Certificate

This example demonstrates the complete usage of the Cognito User Pool Domain module with a custom domain, ACM certificate, and Route53 DNS configuration.

## Prerequisites

- You must own a domain registered in Route53 (e.g., `example.com`)
- Replace `example.com` with your actual domain in the configuration

## Usage

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration (this will take 5-10 minutes for certificate validation)
terraform apply

# Get the Hosted UI URL
terraform output hosted_ui_url
```

## What This Creates

1. **ACM Certificate** in us-east-1 region for `auth.example.com`
2. **DNS Validation Records** in Route53 for certificate validation
3. **Cognito User Pool** (for demonstration)
4. **Cognito User Pool Domain** with custom domain
5. **CloudFront Distribution** (automatically created by Cognito)
6. **Route53 Alias Record** pointing to the CloudFront distribution

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  User Browser                                               │
│       │                                                     │
│       │ HTTPS (TLS 1.2+)                                    │
│       ▼                                                     │
│  auth.example.com                                           │
│       │                                                     │
│       │ Route53 Alias                                       │
│       ▼                                                     │
│  CloudFront Distribution                                    │
│       │                                                     │
│       │ ACM Certificate (us-east-1)                         │
│       ▼                                                     │
│  Cognito Hosted UI                                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Accessing the Hosted UI

After applying, you can access the Hosted UI at:

```
https://auth.example.com/login?client_id=<client_id>&response_type=code&redirect_uri=<redirect_uri>
```

## Important Notes

### Certificate Region

The ACM certificate MUST be in the `us-east-1` region, regardless of where your Cognito User Pool is located. This is a requirement for CloudFront distributions.

### DNS Propagation

After creating the domain, it may take up to 60 minutes for the CloudFront distribution to fully deploy and for DNS changes to propagate globally.

### Certificate Validation

The certificate validation process is automated through DNS validation. Terraform will wait for the certificate to be validated before creating the Cognito domain.

## Clean Up

```bash
terraform destroy
```

**Note**: You may need to wait a few minutes between destroying the domain and destroying the certificate, as CloudFront distributions take time to fully delete.

## Troubleshooting

### Certificate Validation Timeout

If certificate validation times out:
1. Verify the Route53 hosted zone is correct
2. Check that DNS validation records were created
3. Wait a few minutes and try again

### Domain Creation Failed

If domain creation fails:
1. Verify the certificate is in `ISSUED` status
2. Verify the certificate is in `us-east-1` region
3. Check CloudWatch Logs for detailed error messages

### CloudFront Distribution Not Accessible

If the CloudFront distribution is not accessible:
1. Wait up to 60 minutes for full deployment
2. Verify the Route53 alias record is correct
3. Check that the domain name matches the certificate

## Cost Estimate

- ACM Certificate: Free
- Route53 Hosted Zone: $0.50/month
- Route53 Queries: $0.40 per million queries
- CloudFront: Free tier includes 1TB data transfer out
- Cognito: Free tier includes 50,000 MAUs

**Estimated monthly cost**: ~$1-5 depending on usage
