# EC2_Cost_Optimization

Project to store code for Automation of Cost Analysis for EC2 . 

```bash
Technology
i. 	CloudWatch : Right-sizing -monitor CPU utilization, network throughput, and disk I&O via Amazon Cloudwatch
ii. 	CloudForamtion/Cost Optization AWS : Building out the underlying Python anlysis code and EC2 instance, S3 , Amazon Redshift infra
iii. 	Lambda : Event Triggered service that reports finding from CloudForamtion/Cost Optization AWS
```
## Summary 

```bash
This solution uses AWS CloudFormation to deploy AWS resources and Python code to provide a right-sizing analysis for all Amazon EC2 instances in a customer account.
AWS Cloud formation (Terraform)
•	Launches a 2 node Amazon Redshift cluster (dc1.large node types)
•	An amazon EC2 instance in VPC network

How it works

The instance hosts a sequence of Python scripts that collect utilization data from Amazon CloudWatch and then run a custom query in a temporary Amazon Redshift cluster to produce the right-sizing analysis
Both the raw CloudWatch data and the analysis (CSV format) are stored in an Amazon S3 bucket.

The logic it uses

step 1
Down load ref pricelist for all EC2 instances
Cloud watch logs are scarpped for all Linux EC2 instances that are running suiting certain crireria in Customer account
step 2
Each instance is looked at and the oricelist searched using following logic to select best fit new EC2 instance
step 3 -Logic
  If max cpu < 50%
      if ln_min_cpu>=ln_cpu_nbr:
                 if ln_min_mem>=ln_mem_size:
                     if ln_min_network_level>=ln_network_level_usage:
                         if ln_min_rate<=ln_rate:

ln_min_cpu =   (new instance)      found from spreadsheet  clipette
ln_cpu_nbr = 1 (calulated for old instance)
ln_min_mem =  (new instance)    found from spreadsheet  clipette
ln_mem_size = 8 (old instance)
ln_min_network_level = (new instance)
ln_network_level_usage = Low to Moderate  (old instance)
ln_rate  = 0.0992000000  (old instance)
ln_min_rate = (new instance)


How we run this code

This code is buolt and run by Terraform
On building the run the Redshift daabase and ec2 instances aRE AUTOMATICALLY deteted after each run to orevent costs
Results are notified to slack channel
Results are sent to designated email address

* Test slack channel = test
* Tests email : michael.ugbechie@capgemini.com

```

## Installation

```bash

Pre-tasks   Get code
	i.  	git clone  https://gitlab.platform-engineering.com/michael.ugbechie/ec2_cost_optimization  (terraform branch)
	ii. 	Template for CloudFormation is kept in bucket capgemini-ec2pricing-auto
	iii. 	Code for Lambda found under module/cost-ec2-lambda/lambda/
```
```bash

Step 1   Pre- Implementation steps 
==================================

Set up Slack amd channel

  1. Navigate to https://<your-team-domain>.slack.com/services/new

  2. Click on Channel : On right "Add App" A select "Incoming WebHooks".

  3. Select "Add to Stack " Incoming WebHooks Integration.

  4. Copy the webhook URL from the setup instructions and use it in the next section.
 

Step 2 Create email address for notification
=============================================

	goto services	
	ses
		Email Addresses
			Verify a new email address
				Enter your email address , a verification will be sent to your email address
       	Verfy via link 
       	
Step 3 Create S3 Bucket
=======================

goto S3
	create bucket
	Give bucket name : capgemini-ec2-pricing-auto
	copy settings from existing bucket	
		select : capgemini-ec2-pricing
			next : next : next
				create

step 4  Adjust the lambda
    Go into the code and adjust email to that of email wanted
    
    
step 5 Adjust slack webhook and channels
    This is done in main terraform input file where var can be changed here
  
    Create slack variables
	
	kmsEncryptedHookUrl = https://hooks.slack.com/services/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
        slackChannel = test
    
```
 
```bash

step 5  setting up test environment
	This application will detct all instances created in your cutomer account
	Set it up in the normal way
	
```

```bash

step 6  Running the Cloud Formation AWS Optmization Product

   Go clone he code
   
   git clone https://gitlab.platform-engineering.com/michael.ugbechie/ec2_cost_optimization.git
   
   cd ec2_cost_optimization
   
   git checkout terraform
   

    Layout
    
        ec2_cost_optimization
	        main.tf
	        .gitignore
        	backend.tf   … empty
        	provider.tf
        	README
        	module
        		cost-opti-cf
        			input.tf
        			main.tf
        		cost-opti-lambda
        			input.tf
        			main.tf
        			output.tf    …empty
        			lambda
        				lambda.py  …..  can be edited [email]  (checked into github)
        				lambda.zip   …..automatically created


    goto ec2-cost-optimisation

    Pre-config steps
    
    Provider.tf need to be updated

        provider "aws" {
            region = "us-east-1"
            profile = "dev"        # profile
        }
        
        Main file  needs to be updated
        
        resource "random_id" "suffix" {
          byte_length = 4
        }
        
        module "cost_opti_lambda" {
          source = "./module/cost-opti-lambda"
           suffix = random_id.suffix.hex
           s3_bucket_store = "capgemini-ec2pricing-auto"
           handler = "lambda.lambda_handler"
           kmsEncryptedHookUrl = "https://hooks.slack.com/services/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"
           slackChannel = "test"
        }
        
        module "cost_opti_cf" {
          source = "./module/cost-opti-cf"
           suffix = random_id.suffix.hex
          #  BucketName = "capgemini-ec2-pricing-london"
        
           BucketName = "capgemini-ec2pricing-auto"
           KeyName = "Michael-N-Virginia"
        }



	    type : terraform apply
	    
	    
		Takes about 20 mins to run
		You will recieve an mail with analysis via the lambda	
		
		
```	
 

## Recommendations

```bash
	i.	Covert notification to Slack
	ii.	Automate creation and stressing of environment
```

	
## Note

```bash
		A link will be added later analysing  the analysis/ results from AWS Cost Optimsation App
```


 