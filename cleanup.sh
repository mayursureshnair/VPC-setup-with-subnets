#!/bin/bash
# =============================================================
# AWS VPC Cleanup Script — Delete all created resources
# WARNING: This will terminate EC2 instances and delete network resources
# =============================================================

set -e
REGION="us-east-1"

echo "========================================"
echo " AWS VPC Cleanup Starting..."
echo " WARNING: This will delete all resources!"
echo "========================================"

# Replace these with your actual resource IDs
VPC_ID="vpc-XXXXXXXXXXXXXXXXX"
PUBLIC_SUBNET_ID="subnet-XXXXXXXXXXXXXXXXX"
PRIVATE_SUBNET_ID="subnet-XXXXXXXXXXXXXXXXX"
IGW_ID="igw-XXXXXXXXXXXXXXXXX"
PUBLIC_RT_ID="rtb-XXXXXXXXXXXXXXXXX"
PRIVATE_RT_ID="rtb-XXXXXXXXXXXXXXXXX"
PUBLIC_SG_ID="sg-XXXXXXXXXXXXXXXXX"
PRIVATE_SG_ID="sg-XXXXXXXXXXXXXXXXX"
WEB_INSTANCE_ID="i-XXXXXXXXXXXXXXXXX"
APP_INSTANCE_ID="i-XXXXXXXXXXXXXXXXX"

echo "[1] Terminating EC2 instances..."
aws ec2 terminate-instances --instance-ids $WEB_INSTANCE_ID $APP_INSTANCE_ID --region $REGION
echo "    Waiting for termination..."
aws ec2 wait instance-terminated --instance-ids $WEB_INSTANCE_ID $APP_INSTANCE_ID --region $REGION
echo "    Done."

echo "[2] Deleting Security Groups..."
aws ec2 delete-security-group --group-id $PRIVATE_SG_ID --region $REGION
aws ec2 delete-security-group --group-id $PUBLIC_SG_ID --region $REGION

echo "[3] Disassociating and Deleting Route Tables..."
aws ec2 delete-route-table --route-table-id $PUBLIC_RT_ID --region $REGION
aws ec2 delete-route-table --route-table-id $PRIVATE_RT_ID --region $REGION

echo "[4] Detaching and Deleting Internet Gateway..."
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --region $REGION
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID --region $REGION

echo "[5] Deleting Subnets..."
aws ec2 delete-subnet --subnet-id $PUBLIC_SUBNET_ID --region $REGION
aws ec2 delete-subnet --subnet-id $PRIVATE_SUBNET_ID --region $REGION

echo "[6] Deleting VPC..."
aws ec2 delete-vpc --vpc-id $VPC_ID --region $REGION

echo "========================================"
echo " Cleanup Complete! All resources deleted."
echo "========================================"
