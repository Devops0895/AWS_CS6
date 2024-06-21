#!/bin/bash

#this script is for access the s3 bucket objects present in the appropriate account
s3_bucket=$(aws s3 ls | awk '{print $3}')
aws s3 $s3_bucket ls