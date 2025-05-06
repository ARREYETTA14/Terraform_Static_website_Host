‎##📌 Overview
‎This project uses Terraform to set up an AWS S3 bucket as a static website host. It automatically uploads your HTML, CSS, and image files to the bucket and makes them publicly accessible.
‎
‎So basically: write your website → run Terraform → your site is live. 🚀
‎
‎##🧰 Prerequisites
‎Before you begin, make sure you have the following installed:
‎
‎- Terraform (v1.3+ recommended)
‎
‎- AWS CLI
‎
‎AWS account and credentials configured (```aws configure```)
‎
‎A working ```index.html```, ```error.html```, ```styles.css```, and some images in your project directory
‎
‎##Step by step Process
‎
‎```lua
‎.
‎├── main.tf
‎├── variable.tf
‎├── provider.tf
‎├── values.auto.tfvars
‎├── output.tf
‎├── index.html
‎├── error.html
‎├── styles.css
‎├── profile.jpg
‎└── other-images/
‎```
‎
‎###1. Configure Your AWS Provider
‎Set your provider and specify more on your AWS Region and you Profile. save your code as provider.tf
‎
‎###2. Define variables and values.auto.tfvars file
‎ This makes your setup reusable — you can plug in different values later without editing core code.
‎- Check the variable.tf and values.auto.tfvars
‎
‎###3. The ```main.tf``` file
‎Here’s what each block in main.tf does:
‎- Create the Bucket
‎This is where all your website files will go.
‎
‎- Ownership Controls
‎🔒 Ensures you're the rightful owner of your bucket's content. 
‎If you're not the owner of the object...
‎
‎❌ You can’t change its permissions
‎
‎❌ You might not be able to delete it
‎
‎❌ You can’t read or modify its metadata
‎
‎- Make Bucket Public
‎Static websites need to be public — this unlocks access.
‎
‎- Set ACL to ```public-read```
‎👀 So people can actually view your site. 
‎
‎- Upload files:
‎📂 Terraform will push the actual files to your S3 bucket — HTML, CSS, images etc.
‎
‎- Website Hosting Configuration
‎This turns your S3 bucket into a mini web server. Your site will be available via a public URL!
‎
‎
‎- Output
‎In output.tf, it displays the bucket URL so you can test it.
‎
‎###4. Running the Project:
‎In your terminal, do the following:
‎
‎```bash
‎# Step 1: Initialize Terraform (downloads AWS provider)
‎terraform init
‎
‎# Step 2: Plan the deployment
‎terraform plan 
‎
‎# Step 3: Apply the configuration
‎terraform apply 
‎```
‎
‎Notes: All these codes can be obtained from the Terraform official documentation. 
‎
‎
‎#Section Two: Using S3_backend dynamodb lock 
‎
‎##🧭 Overview
‎This section upgrades your Terraform workflow to use a remote backend — storing state in an S3 bucket, and locking it with DynamoDB to prevent multiple people from destroying the code.
‎
‎
‎##Why You Want This
‎
‎- 🧠 Statefile = brain of Terraform. If it gets corrupted? Chaos.
‎
‎- 🛡️ DynamoDB locking = Prevents concurrent runs.
‎
‎- ☁️ S3 = safe & shared storage for team-based workflows.
‎
‎
‎
