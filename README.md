## Docker

```bash
brew install terraform
brew cask install chef/chef/inspec

terraform init
terraform plan
terraform apply   --auto-approve
terraform destroy --auto-approve
```

## Inspect

```bash
inspec exec container_test.rb
```