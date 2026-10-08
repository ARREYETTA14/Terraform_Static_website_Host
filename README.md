
# Deploy a Static Website to AWS S3 Using Terraform


Deploy a Static Website to AWS S3 Using Terraform

📌 Overview
This project uses Terraform to spin up an AWS S3 bucket configured for static website hosting. It automatically uploads your HTML, CSS, and restaurant images to the bucket while configuring the necessary security and bucket policies so your platform is instantly live and publicly accessible over the internet.

So basically: write your website → run Terraform → your site is live. 🚀  

## 🧰 Prerequisites  
Before you begin, make sure you have the following installed:  

- **Terraform** (v1.3+ recommended)  
- **AWS CLI** installed
- **AWS account credentials** configured locally by running ``aws configure`` in your terminal.

A working `index.html`, `error.html`, `styles.css`, and some images in your project directory  

## Project File Structure

Create a folder on your computer named ``Staticwebsite_with_terraform`` and organize your files exactly like this:

```lua
Staticwebsite_with_terraform
├── main.tf
├── variable.tf
├── provider.tf
├── values.auto.tfvars
├── output.tf
├── index.html
├── error.html
├── styles.css
├── cameroonian-dish-1.jpg
└── other-images/
```


## 📝 Step-by-Step Code Configuration

### 1. Configure Your AWS Provider (``provider.tf``)
This file tells Terraform that it needs to connect to AWS to manage your infrastructure, using the region specified in your variables.

### 2. Define variables (``variables.tf``)
- Variables keep your codebase modular and clean. Instead of hardcoding values inside your core deployment scripts, declare them here.

### 3. Set Your Custom Values (``values.auto.tfvars``)
This file automatically injects values into the variables defined in Step 2.

### 4. Write the Infrastructure Logic (``main.tf``)
This is the core script. It builds the bucket, configures modern security blocks to allow public access, updates the bucket policy, and uploads your website files with accurate browser rendering rules.

- Create the Bucket

This is where all your website files will sit once the deployment is up and running.
```hcl
resource "aws_s3_bucket" "static-website-hoster" {
```

- Ownership Controls
🔒 Ensures you're the rightful owner of your bucket's content.

```hcl
resource "aws_s3_bucket_ownership_controls" "example" {}
```

If you're not the owner of the object...


❌ You can’t change its permissions

❌ You might not be able to delete it

❌ You can’t read or modify its metadata

-  Make Bucket Public
Static websites need to be public — this unlocks access.

```hcl
resource "aws_s3_bucket_public_access_block" "example" {}
```

- Create a bucket policy that makes the bucket public
👀 So people can view your site.

```hcl
resource "aws_s3_bucket_policy" "public_access" {}
```
- Upload files:
📂 Terraform will push the actual files to your S3 bucket — HTML, CSS, images, etc.

- Website Hosting Configuration
This turns your S3 bucket into a mini web server. Your site will be available *via* a public URL!

```hcl
resource "aws_s3_object" "index" {}
resource "aws_s3_object" "error" {}
resource "aws_s3_object" "profile_picture" {}
```

- Rendering s3 a static website.

```hcl
resource "aws_s3_bucket_website_configuration" "website" {}
```

- Output
The ```output.tf``` displays the bucket URL so you can grab and test in the browser.

```hcl
output "website_url" {
  value = aws_s3_bucket.static-website-hoster.website_endpoint
}
```

### 5. Running the Project:
In your terminal, do the following:

```bash
# Step 1: Initialise Terraform (downloads AWS provider)
terraform init

# Step 2: Plan the deployment
terraform plan 

# Step 3: Apply the configuration
terraform apply 
```

# Section Two: Using S3_backend and dynamodb lock

## 🧭 Overview
Terraform requires a pre-existing storage location to hold its state database before it can track infrastructure. Therefore, you must provision the S3 Bucket and DynamoDB table first using a bootstrap configuration.

## Why You Want This
- 🧠 Statefile = brain of Terraform. If it gets corrupted? Chaos.
- 🛡️ DynamoDB locking = Prevents concurrent runs.
- ☁️ S3 = safe & shared storage for team-based workflows.

## Step by step Process

### 1. Create a new folder in your present directory called ```s3_backend```
- In this folder, create a file ```main.tf```. The file has code that creates the Dynamodb table and the bucket in which the state file will lie.

This is done because **Terraform doesn’t allow you to declare the backend as a resource in the same config where you use it.**. In other words, Terraform needs the backend before it can know where to even store the plan. So it can’t use itself to create that thing first.

**NB**: The table must have a partition key named ``LockID`` with a type of ``String``. 

### 2. Running the File 
- Execute the ```main.tf``` file. This will create your S3 bucket and DynamoDB lock table separately, so your main project can use them. 

### 3. Creating the ```backend.tf``` file
- In your main project folder(``Staticwebsite_with_terraform``), create a file known as ``dynamodb_lock.tf``, which will contain a code which allows you to call the **Dynamodb** and **S3_backend** created above during the execution of the ```main.tf``` file in the ``s3_backend`` folder.

### 4. Execute the code


# Section Three: Automating Deployment via GitHub Actions (OIDC)

### 🔐 3.1 Establishing the Trust Interface in AWS IAM

Before your GitHub repository can talk to AWS, you must establish an IAM Identity Provider and a dedicated IAM Role that knows how to validate GitHub's secure time signatures.

### Part A: Create the OIDC Identity Provider (If not already created)
- Sign in to your AWS Management Console.
- In the top search bar, look for **IAM** and navigate to the IAM Dashboard.
- In the left-hand navigation pane, click **Identity providers**, then click the **Add provider** button.
- Configure these fields precisely:
    - **Provider type**: Select ``OpenID Connect``.
    - **Provider URL**: Paste ``https://token.actions.githubusercontent.com``.
    - **Audience Type**: Paste ``sts.amazonaws.com``
- Click Add provider.


## Part B: Configure the IAM Role and Trust Relationship Policy

Now, you need to create an AWS role that your GitHub pipeline is allowed to assume.

1. In the left sidebar of the **IAM Console**, click **Roles** and then click **Create role**.
2. Select Custom trust policy under **Trusted entity type**
3. Paste the following JSON block into the policy editor. 🚨 CRITICAL: Replace ``<YOUR_AWS_ACCOUNT_ID>``, ``<YOUR_GITHUB_ORGANIZATION_OR_USER>``, and ``<YOUR_GITHUB_REPO_NAME>`` with your actual deployment details:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<YOUR_AWS_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:<YOUR_GITHUB_USERNAME_OR_ORG>/<YOUR_REPOSITORY_NAME>:*"
        }
      }
    }
  ]
}
```
4. Click **Next**
5. On the **Add permissions screen**, search for and check the box next to ``AmazonS3FullAccess`` (or attach a limited policy that only allows writes to your specific bucket).
6. Click **Next**.
7. **Role name**: Enter ``github-s3-deploy-role``.
8. Review your choices and click **Create role**.
9. Copy the **ARN** string of your new role (it will look like arn:aws:iam::123456789012:role/github-s3-deploy-role).

## 3.2 Creating the Production Pipeline Configuration File

### structure
```text
Staticwebsite_with_terraform/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── provider.tf
├── variable.tf
├── values.auto.tfvars
├── main.tf
├── output.tf
├── index.html
├── error.html
├── styles.css
├── cameroonian-dish-1.jpg
├── cameroonian-dish-2.jpg
├── Kenyan-dish-1.jpg
└── Kenyan-dish-2.jpg
```
Before you configure your workflow, you need to make the Role ARN available to it. You'll store it as a repository variable in GitHub, not a secret, because the ARN itself isn't sensitive data.

- First, open your GitHub repository and click **Settings**.
- In the left sidebar, scroll down to **Secrets and variables**, then click **Actions**.
- Then click the **Variables** tab (not Secrets). Click **New repository variable** – you can put the name as **AWS_GITHUB_ROLE**.
- Set the Value to your **Role ARN**
- Click **Add variable**

With AWS and GitHub fully configured, you now need to update your workflow to request an OIDC token and use it to authenticate.

1. Open your local code workspace directory (``Staticwebsite_with_terraform``).
2. Create a folder named ``.github``, and create a subfolder inside it named ``workflows``.
3. Create a brand new file inside that folder named ``deploy.yml``.
4. Save the following code block inside ``deploy.yml``.

- Your workflow must declare ``id-token: write``. Without this, GitHub won't issue an OIDC token to the runner.

```yaml
 
      - name: Deploy to S3
        run: |
          aws s3 sync ./code s3://your-bucket-name

name: Deploy Static Website with Terraform

on:
  push:
    branches: 
      - main

# Required root permissions to allow OIDC token exchange
permissions:
  id-token: write
  contents: read

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      # 1. Checkout the repository code
      - name: Checkout Code
        uses: actions/checkout@v4

      # 2. Set up modern Terraform CLI
      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.6

      # 3. Securely assume AWS Role using OIDC (No Static Keys Required!)
      - name: Configure AWS Credentials via OIDC
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          aws-region: sa-east-1

      # 🚨 ADDED CHECKPOINT: Verify the assumed role identity before executing code
      - name: Verify AWS identity
        run: aws sts get-caller-identity

      # 4. Initialize Terraform (This automatically reads backend.tf and pulls state)
      - name: Terraform Init
        run: terraform init
        working-directory: Staticwebsite_with_terraform

      # 5. Run Format check to enforce clean styling syntax
      - name: Terraform Format Check
        run: terraform fmt -check
        working-directory: Staticwebsite_with_terraform

      # 6. Run Terraform plan to preview infrastructure changes
      - name: Terraform Plan
        run: terraform plan
        working-directory: Staticwebsite_with_terraform

      # 7. Apply Terraform configuration with the backend lock engaged
      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: Staticwebsite_with_terraform

      # 8. Print out the final live website landing URL
      - name: Output Website URL
        run: |
          echo "🚀 Deployed Successfully!"
          echo "Your live website URL is:"
          terraform output -raw website_url
        working-directory: Staticwebsite_with_terraform

```

Make sure to change the ```aws-region``` to your actual desired region of deployment.

## 3.3 Running and Testing the Combined System
To deploy your infrastructure and launch your updated restaurant website using this automated pipeline, run these commands in your local computer terminal:

```bash
# Stage all updated file changes (HTML, CSS, TF blocks)
git add .

# Create an execution checkpoint commit
git commit -m "feat: integrate secure OIDC workflow and remote state locks"

# Push to your remote tracking branch to trigger the pipeline
git push origin main
```
*Note: This is done if the application code is in your local machine and not in GitHub already. If it were in GitHub already, the moment you committe your workflow, the pipeline will automatically be executed.*

- Once the workflow is committed, the code will be deployed in AWS.
- To track the execution Progress, navigate to the **Actions** tab of the GitHub Repository.
- Click on the, running workflow instance named ``feat: integrate secure OIDC workflow and remote state locks``.
- Click on the terraform job block in the graph to view live build streams
- Get to your **Github Action Logs** and get the **website_url** from there and test.


Now you can intergrate a ``Dynamodb_lock_&_s3_backend`` as shown on **Section two**.


