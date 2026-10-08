
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


# Section Three: Using GitAction to Trigger deployment

### 🔐 3.1 Setting Up AWS Credentials in GitHub
Before your workflow can deploy to AWS, GitHub needs permission to access your AWS account. This is done securely through GitHub Secrets.

### Step-by-step: Add AWS credentials to GitHub
- Go to your GitHub repo
- Click on the **Settings** tab
- In the left sidebar, scroll to:
```nginx
Secrets and variables → Actions
```
- Click the **“New repository secret”** button
- Add two secrets:
```txt
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```
Using the Principle of **Least Privilege**, to deploy to S3, the IAM user should have the ``AmazonS3FullAccess`` policy.

- Based on my above file structure, make sure the **Staticwebsite_with_terraform** directory has all the main code files, media files, html and css files. Except the ``dynamodb_lock.tf`` file.

- Create a workflow file in the directory ``.github/workflows/deploy.yml`` and paste in the following code
```yml
name: Deploy Static Website with Terraform

on:
  push:
    branches: 
      - main

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      # Checkout the repository code
      - name: Checkout Code
        uses: actions/checkout@v3

      # Set up Terraform CLI
      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.6.6

      # Configure AWS credentials from GitHub secrets
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: sa-east-1  # or your region

      # Initialize Terraform in the working directory
      - name: Terraform Init
        run: terraform init
        working-directory: Staticwebsite_with_terraform

      # Run Terraform fmt to ensure files are properly formatted
      - name: Terraform Format Check
        run: terraform fmt 
        working-directory: Staticwebsite_with_terraform

      # Run Terraform plan to preview infrastructure changes
      - name: Terraform Plan
        run: terraform plan
        working-directory: Staticwebsite_with_terraform

      # Apply Terraform configuration to deploy resources
      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: Staticwebsite_with_terraform

      # Output the website URL from Terraform outputs
      - name: Output Website URL
        run: terraform output website_url
        working-directory: Staticwebsite_with_terraform

      # Output the website URL from Terraform outputs
      - name: Output Website URL
        run: |
          echo "🚀 Website URL:"
          terraform output website_url
        working-directory: Staticwebsite_with_terraform
```

Make sure to change the ```aws-region``` to your actual desired region of deployment.

- Once the workflow is committed, the code will be deployed in AWS 
- Get to your **Github Action Logs** and get the **website_url** from there and test.


Now you can intergrate a ``Dynamodb_lock_&_s3_backend`` as shown on **section two**.


