#!/usr/bin/env bash

# based on https://stackoverflow.com/questions/26340690/delete-default-vpc-via-aws-cli

export REGIONS=$(aws ec2 describe-regions | jq -r ".Regions[].RegionName")

for region in $REGIONS ; do
    echo "Searching for default resources in $region"
    # list vpcs
    export IDs=$(aws --region=$region ec2 describe-vpcs | jq -r ".Vpcs[]|{is_default: .IsDefault, id: .VpcId} | select(.is_default) | .id")
    for id in "$IDs" ; do
        if [ -z "$id" ] ; then
            echo "...nothing found."
            continue
        fi
        echo "Cleaning default resources in $region"

        # kill igws
        for igw in `aws --region=$region ec2 describe-internet-gateways | jq -r ".InternetGateways[] | {id: .InternetGatewayId, vpc: .Attachments[0].VpcId} | select(.vpc == \"$id\") | .id"` ; do
            echo "Killing igw $region $id $igw"
            aws --region=$region ec2 detach-internet-gateway --internet-gateway-id=$igw --vpc-id=$id
            aws --region=$region ec2 delete-internet-gateway --internet-gateway-id=$igw
        done

        # kill subnets
        for sub in `aws --region=$region ec2 describe-subnets | jq -r ".Subnets[] | {id: .SubnetId, vpc: .VpcId} | select(.vpc == \"$id\") | .id"` ; do
            echo "Killing subnet $region $id $sub"
            aws --region=$region ec2 delete-subnet --subnet-id=$sub
        done

        echo "Killing vpc $region $id"
        aws --region=$region ec2 delete-vpc --vpc-id=$id
    done
done
