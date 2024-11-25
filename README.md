# Hackathon 2024 CloudFormation Setup

This repository provides CloudFormation templates and scripts for setting up resources for a hackathon environment, including:

* VPC with customizable resource names, 2 public and 2 private subnets, a NAT Gateway, and routing (CloudFormation template)
* Windows and/or Linux instances with basic tags and IAM role for SSM with auto scaling (CloudFormation template)
* Single SFTP server instance with basic tags, IAM role for SSM, and port 22 access (CloudFormation template)
* Script for setting up SFTP users based on a team list file (`team_list.txt`) (shell script)

## Prerequisites

* AWS account with appropriate permissions to create resources
* Basic knowledge of CloudFormation and Git

## Instructions

1. **Clone this repository:**

   git clone https://github.com/anooparora29/aws-cloudformation-hackathon2024.git
   
2. Deploy CloudFormation Stacks:

    * Customize the CloudFormation templates (optional) to meet your specific needs.
    * Refer to the AWS CloudFormation documentation for instructions on deploying stacks (https://docs.aws.amazon.com/cloudformation/latest/userguide/how-to-deploy-template.html).
    
3. Set Up SFTP Users (Optional):

    * Create a file with the name team_list.txt and include add the users in the user1:password format.
    * Modify the setup_sftp_with_teams.sh script if needed.
    * Ensure the script has execute permissions (chmod +x setup_sftp_with_teams.sh).
    * Run the script with your team list file:

<!-- end list -->
