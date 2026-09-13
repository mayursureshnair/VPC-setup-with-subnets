# AWS VPC Project — Resource Summary

## VPC Details
- **VPC Name:** My-VPC
- **VPC ID:** vpc-00e114405eeb85106
- **IPv4 CIDR:** 10.0.0.0/16
- **State:** Available
- **Region:** us-east-1 (N. Virginia)

## Subnets
| Name | Subnet ID | CIDR | Type |
|---|---|---|---|
| Public-Subnet-1 | subnet-05e3c2c25c1ba9d0e | 10.0.1.0/24 | Public |
| Private-Subnet-1 | subnet-00d17c1b54971e2ef | 10.0.2.0/24 | Private |

## Internet Gateway
- **Name:** My-IGW
- **IGW ID:** igw-074fabcce5207c728
- **State:** Attached
- **Attached VPC:** vpc-00e114405eeb85106 (My-VPC)

## Route Tables
| Name | Route Table ID | Subnet |
|---|---|---|
| Public-RT | rtb-09f7fcf04bb5bd327 | Public-Subnet-1 |
| Private-RT | rtb-0e976d602fade696d | Private-Subnet-1 |

### Public-RT Routes
| Destination | Target |
|---|---|
| 10.0.0.0/16 | local |
| 0.0.0.0/0 | igw-074fabcce5207c728 |

### Private-RT Routes
| Destination | Target |
|---|---|
| 10.0.0.0/16 | local |

## Security Groups
| Name | Description | VPC |
|---|---|---|
| Public-Web-SG | Allow SSH and HTTP | My-VPC |
| Private-App-SG | Allow SSH access from Public Web SG | My-VPC |

### Public-Web-SG Inbound Rules
| Type | Protocol | Port | Source |
|---|---|---|---|
| SSH | TCP | 22 | 0.0.0.0/0 |
| HTTP | TCP | 80 | 0.0.0.0/0 |

### Private-App-SG Inbound Rules
| Type | Protocol | Port | Source |
|---|---|---|---|
| SSH | TCP | 22 | Public-Web-SG (sg-ID) |
