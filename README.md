# Hackathon 2024 - CloudFormation Templates and SFTP Setup

This repository contains CloudFormation templates and shell scripts used to set up various AWS resources for Hackathon 2024. The resources include a VPC with public and private subnets, EC2 instances, and an SFTP server.

## Project Structure

hackathon-2024-cloudformation/
├── cloudformation/
│   ├── cloudformation-network.yaml
│   ├── cloudformation-ec2-working-public.yaml
│   ├── cloudformation-ec2-sftp.yaml
├── scripts/
│   ├── setup_sftp_with_teams.sh
│   └── team_list.txt
└── README.md


- **CloudFormation Templates**:
  - `cloudformation-network.yaml`: Creates a VPC with customizable resource names, 2 public subnets, 2 private subnets, a NAT Gateway, and associated routing.
  - `cloudformation-ec2-working-public.yaml`: Creates Windows and/or Linux instances with basic tags, IAM role for SSM, and auto-scaling.
  - `cloudformation-ec2-sftp.yaml`: Creates a single SFTP server instance with basic tags, IAM role for SSM, and port 22 access only.

- **Scripts**:
  - `setup_sftp_with_teams.sh`: Shell script that sets up SFTP users based on an input file (`team_list.txt`).
  - `team_list.txt`: Contains the usernames and passwords for each SFTP user.

## How to Use

1. **Clone this repository:**

   git clone https://github.com/anooparora29/aws-cloudformation-hackathon2024.git
   
2. **Deploy CloudFormation Teamplates**

	1. **Create the VPC**:
  	   - Launch the `cloudformation-network.yaml` CloudFormation template to set up a VPC with necessary subnets and routing.

	2. **Launch EC2 Instances**:
  	   - Launch the `cloudformation-ec2-working-public.yaml` CloudFormation template to create EC2 instances (Windows/Linux) with auto-scaling and SSM roles.

	3. **Set Up SFTP Server**:
  	   - Launch the `cloudformation-ec2-sftp.yaml` CloudFormation template to set up a single SFTP server instance with necessary IAM roles and port 22 access.

3. **Setup SFTP Users (Optional)**

	1. Ensure that you have the `team_list.txt` file with the list of usernames and passwords for the SFTP users.
   
	2. Run the `setup_sftp_with_teams.sh` script to create SFTP users:
   	   ```bash
   	   ./setup_sftp_with_teams.sh team_list.txt

