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
├── profile.jpg
└── other-images/
```
