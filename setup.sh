#!/bin/bash
# =============================================================
# AWS VPC Setup Script
# Project: VPC with Public & Private Subnets + EC2 Instances
# Author: Mayur Suresh Nair
# =============================================================

set -e

REGION="us-east-1"
VPC_CIDR="10.0.0.0/16"
PUBLIC_SUBNET_CIDR="10.0.1.0/24"
PRIVATE_SUBNET_CIDR="10.0.2.0/24"
AZ_PUBLIC="us-east-1a"
AZ_PRIVATE="us-east-1b"
AMI_ID="ami-0c02fb55956c7d316"
INSTANCE_TYPE="t2.micro"
KEY_NAME="my-vpc-key"

echo "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --region $REGION --query Vpc.VpcId --output text)
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=My-VPC --region $REGION
echo "VPC: $VPC_ID"

echo "Creating Subnets..."
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PUBLIC_SUBNET_CIDR --availability-zone $AZ_PUBLIC --region $REGION --query Subnet.SubnetId --output text)
aws ec2 create-tags --resources $PUBLIC_SUBNET_ID --tags Key=Name,Value=Public-Subnet-1 --region $REGION
aws ec2 modify-subnet-attribute --subnet-id $PUBLIC_SUBNET_ID --map-public-ip-on-launch --region $REGION

PRIVATE_SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PRIVATE_SUBNET_CIDR --availability-zone $AZ_PRIVATE --region $REGION --query Subnet.SubnetId --output text)
aws ec2 create-tags --resources $PRIVATE_SUBNET_ID --tags Key=Name,Value=Private-Subnet-1 --region $REGION

echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway --region $REGION --query InternetGateway.InternetGatewayId --output text)
aws ec2 create-tags --resources $IGW_ID --tags Key=Name,Value=My-IGW --region $REGION
aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --region $REGION

echo "Creating Route Tables..."
PUBLIC_RT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --region $REGION --query RouteTable.RouteTableId --output text)
aws ec2 create-tags --resources $PUBLIC_RT_ID --tags Key=Name,Value=Public-RT --region $REGION
aws ec2 create-route --route-table-id $PUBLIC_RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --region $REGION
aws ec2 associate-route-table --route-table-id $PUBLIC_RT_ID --subnet-id $PUBLIC_SUBNET_ID --region $REGION

PRIVATE_RT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --region $REGION --query RouteTable.RouteTableId --output text)
aws ec2 create-tags --resources $PRIVATE_RT_ID --tags Key=Name,Value=Private-RT --region $REGION
aws ec2 associate-route-table --route-table-id $PRIVATE_RT_ID --subnet-id $PRIVATE_SUBNET_ID --region $REGION

echo "Creating Security Groups..."
PUBLIC_SG_ID=$(aws ec2 create-security-group --group-name Public-Web-SG --description "Allow SSH and HTTP" --vpc-id $VPC_ID --region $REGION --query GroupId --output text)
aws ec2 authorize-security-group-ingress --group-id $PUBLIC_SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $REGION
aws ec2 authorize-security-group-ingress --group-id $PUBLIC_SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $REGION

PRIVATE_SG_ID=$(aws ec2 create-security-group --group-name Private-App-SG --description "Allow SSH access from Public Web SG" --vpc-id $VPC_ID --region $REGION --query GroupId --output text)
aws ec2 authorize-security-group-ingress --group-id $PRIVATE_SG_ID --protocol tcp --port 22 --source-group $PUBLIC_SG_ID --region $REGION

echo "Launching EC2 Instances..."
WEB_INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type $INSTANCE_TYPE --key-name $KEY_NAME --subnet-id $PUBLIC_SUBNET_ID --security-group-ids $PUBLIC_SG_ID --associate-public-ip-address --region $REGION --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Web-Server}]" --query Instances[0].InstanceId --output text)

APP_INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type $INSTANCE_TYPE --key-name $KEY_NAME --subnet-id $PRIVATE_SUBNET_ID --security-group-ids $PRIVATE_SG_ID --no-associate-public-ip-address --region $REGION --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=App-Server}]" --query Instances[0].InstanceId --output text)

echo "Done! Web-Server: $WEB_INSTANCE_ID | App-Server: $APP_INSTANCE_ID"
