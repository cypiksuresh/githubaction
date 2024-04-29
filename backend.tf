name: Terraform CI/CD

on:
  push:
    branches:
      - #master

jobs:
  terraform_apply:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v1
        with:
          terraform_version: 1.0.0

      - name: Install the gcloud CLI
        uses: google-github-actions/setup-gcloud@v2
        with:
          project_id: ${{ secrets.GOOGLE_PROJECT }}
          service_account_key: ${{ secrets.GOOGLE_APPLICATION_CREDENTIALS }}
          export_default_credentials: true
          version: '>= 363.0.0'

      - name: Use gcloud CLI
        run: gcloud info

      - name: Authenticate with Google Cloud Platform
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GOOGLE_APPLICATION_CREDENTIALS }}

      - name: Configure Terraform Backend
        run: |
          cat <<EOF >backend.tf
          terraform {
            backend "gcs" {
              # Add your GCS backend configuration here
              bucket  = "testtest1111111"
              prefix  = "Terraform"
            }
          }
          EOF

      - name: Terraform Init
        run: terraform init


      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan -out=tfplan

      - name: Terraform Apply
        if: github.ref == 'refs/heads/master' && github.event_name == 'push'
        run: terraform apply -auto-approve tfplan
      - name: Terraform Destroy
        run: terraform destroy -auto-approve
        env:
           credentials_json: ${{ secrets.GOOGLE_APPLICATION_CREDENTIALS }}
