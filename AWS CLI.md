# AWS CLI usage 

1- Query a Volume and get `Volume ID` and `VolumeType` in a array format.

```Shell
(awscliv2) $  aws ec2 describe-volumes --query "Volumes[0].{Id:VolumeId,Type:VolumeType}" --profile dev --output table
-----------------------------------
|         DescribeVolumes         |
+-------------------------+-------+
|           Id            | Type  |
+-------------------------+-------+
|  vol-0888de7b0f1c7ea28  |  gp3  |
+-------------------------+-------+
```

