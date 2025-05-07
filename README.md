
# Deploy a Static Website to AWS S3 Using Terraform

## 📌 Overview  
This project uses Terraform to set up an AWS S3 bucket as a static website host. It automatically uploads your HTML, CSS, and image files to the bucket and makes them publicly accessible.  

So basically: write your website → run Terraform → your site is live. 🚀  

## 🧰 Prerequisites  
Before you begin, make sure you have the following installed:  

- Terraform (v1.3+ recommended)  
- AWS CLI  

AWS account and credentials configured (`aws configure`)  

A working `index.html`, `error.html`, `styles.css`, and some images in your project directory  

## Step by step Process  

### File structure 
```lua
.
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
### 1. Configure Your AWS Provider
Set your provider and specify more on your ```AWS Region``` and ```your Profile```. Save your code as ```provider.tf```

### 2. Define variables and values.auto.tfvars file
- This makes your setup reusable — you can plug in different values later without editing the core code.
- Store your codes as **variable.tf** and **values.auto.tfvars**

### 3. The main.tf file
Here’s what each block in ```main.tf``` does:

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

- Rendering s3 a static website

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

### 4. Running the Project:
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
This section upgrades your Terraform workflow to use a remote backend — storing state in an S3 bucket, and locking it with DynamoDB to prevent multiple people from accessing your infrastructure at the same time.

## Why You Want This
- 🧠 Statefile = brain of Terraform. If it gets corrupted? Chaos.
- 🛡️ DynamoDB locking = Prevents concurrent runs.
- ☁️ S3 = safe & shared storage for team-based workflows.

## Step by step Process

### 1. Create a new folder in your present directory called ```create_dynamondblock_&_s3_backend```
- In this folder, create a file ```main.tf```. The file has code that creates the Dynamodb table and the bucket in which the state file will lie.

This is done because **Terraform doesn’t allow you to declare the backend as a resource in the same config where you use it.**. In other words, Terraform needs the backend before it can know where to even store the plan. So it can’t use itself to create that thing first.

**NB**: The table must have a partition key named ```LockID``` with a type of ```String```. 

### 2. Running the File 
- Execute the ```main.tf``` file. This will create your S3 bucket and DynamoDB lock table separately, so your main project can use them. 

### 3. Creating the ```backend.tf``` file
- In your main project folder, create a file known as ```backend.tf```, which contains code which allows you to call the **Dynamodb** and **S3_backend** created above during the execution of the ```main.tf``` in the **s3_backend** folder.

### 4. Execute the code
