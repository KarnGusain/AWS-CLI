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

✍ One can even `sort` the resource attributed using by `sort_by` function and use additional options like `--output` or `no-cli-pager` to get output in a tabular form and full output without having pagination stoppage.

```Shell
(awscliv2) $ aws ec2 describe-volumes  --query 'sort_by(Volumes, &VolumeId)[].{VolumeId: VolumeId, VolumeType: VolumeType, InstanceId: Attachments[0].InstanceId, State: Attachments[0].State}' --profile dev --output table --no-cli-pager
----------------------------------------------------------------------------
|                              DescribeVolumes                             |
+----------------------+-----------+-------------------------+-------------+
|      InstanceId      |   State   |        VolumeId         | VolumeType  |
+----------------------+-----------+-------------------------+-------------+
|  i-06253db1de27a1472 |  attached |  vol-0034927f6d89a987c  |  gp3        |
|  i-0c9e0188fe0105ed6 |  attached |  vol-0ad69e58bb689838e  |  gp2        |
|  i-081d9511ae174ebb2 |  attached |  vol-0cf1ecc29edae56d4  |  gp3        |
|  i-0c9e1235fe0666ed6 |  attached |  vol-0fbe38a5b1656f575  |  gp3        |
+----------------------+-----------+-------------------------+-------------+
```
2- What is difrence while using `--query` and `--filter` in aws cli?

✍ Essentially `--filter` is the condition used to select which resources you want described, listed, etc. On the other hand `--query` is the list of fields that you want returned in the response. You can do some simple filtering with `--query` as well but `--filter` tends to be more powerful.
Below is an example

```Shell
(awscliv2) $ aws ec2 describe-instances --filters Name=instance-state-name,Values=stopped  --query 'Reservations[].Instances[*].{"Instance Name":Tags[?Key==`Name`]|[0].Value, ImageId: ImageId, InstanceType: InstanceType, InstanceId: InstanceId, State: State.Name}' --profile dev --output table
---------------------------------------------------------------------------------------------------------
|                                           DescribeInstances                                           |
+-----------------------+----------------------------+----------------------+---------------+-----------+
|        ImageId        |       Instance Name        |     InstanceId       | InstanceType  |   State   |
+-----------------------+----------------------------+----------------------+---------------+-----------+
|  ami-00f34c5f953801a74|  MyVolumeOntap-Restore     |  i-0c9e1155fe0105ed6 |  m5.xlarge    |  stopped  |
|  ami-0ea0f26a6d50235c5|  mhy_test_fsx              |  i-02e4cbcbe10cb5e79 |  t1.micro     |  stopped  |
+-----------------------+----------------------------+----------------------+---------------+-----------+
```

3- How list your Backups which has resource type FsxN?

```Shell
(awscliv2) $ aws fsx describe-backups  --query 'Backups[*].{ "Backup ID":BackupId, "ResourceARN":ResourceARN, "FS ID":FileSystem.FileSystemId, "Volume Type": Volume.VolumeType  }' --profile dev --output table
-------------------------------------------------------------------------------------------------------------------------------------------
|                                                             DescribeBackups                                                             |
+--------------------------+-----------------------+----------------------------------------------------------------------+---------------+
|         Backup ID        |         FS ID         |                             ResourceARN                              |  Volume Type  |
+--------------------------+-----------------------+----------------------------------------------------------------------+---------------+
|  backup-0eac1234565e31820|  None                 |  arn:aws:fsx:eu-west-1:<acc_number>:backup/backup-0eac1234565e31820  |  ONTAP        |
|  backup-0123cef1239a726e9|  None                 |  arn:aws:fsx:eu-west-1:<acc_number>:backup/backup-0123cef1239a726e9  |  ONTAP        |
|  backup-005a111af5e86d3da|  None                 |  arn:aws:fsx:eu-west-1:<acc_number>:backup/backup-005a111af5e86d3da  |  ONTAP        |
+--------------------------+-----------------------+----------------------------------------------------------------------+---------------+
```

4- How to get details  of a Particulat restore Job?
```Shell
(awscliv2) $ aws backup describe-restore-job --restore-job-id 8E7C420E-5BF7-84AA-E277-D30C00ABA56D --profile slpr
{
    "AccountId": "079149401785",
    "RestoreJobId": "1E7C150E-0BF7-84AA-E11111-D30C00ABA56D",
    "RecoveryPointArn": "arn:aws:fsx:ap-northeast-2:079149401785:backup/backup-058c1234ce8432982",
    "CreationDate": "2022-12-21T19:33:25.183000+05:30",
    "Status": "RUNNING",
    "PercentDone": "0.00%",
    "BackupSizeInBytes": 0,
    "IamRoleArn": "arn:aws:iam::<acc_number>:role/mytest-iam-backup-fsx-role",
    "CreatedResourceArn": "arn:aws:fsx:ap-northeast-2:<acc_number>:volume/fs-02f3ad08977f01234/fsvol-0dcf6a1234f4bcab",
    "ResourceType": "FSx"
}
```


5- How to List Volumes showing attachment using Dictionary/Array Notation?

```Shell
(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[*].{ID:VolumeId,InstanceId:Attachments[0].InstanceId,AZ:AvailabilityZone,Size:Size}' --profile dev --output table
------------------------------------------------------------------------
|                            DescribeVolumes                           |
+------------+-------------------------+-----------------------+-------+
|     AZ     |           ID            |      InstanceId       | Size  |
+------------+-------------------------+-----------------------+-------+
|  eu-west-1b|  vol-01ea79cc1c1234b00  |  i-0327cf04986081234  |  60   |
|  eu-west-1a|  vol-1234abc045cdb2a56  |  i-0c9e1111fe0105ed6  |  140  |
|  eu-west-1a|  vol-0fbe38a5b1234f575  |  i-0c8d1111fe0105ed6  |  500  |
|  eu-west-1a|  vol-09ed5d3e9bac12b0a  |  i-0cb11b3c973b03bf6  |  30   |
+------------+-------------------------+-----------------------+-------+
```

6- HOw to list down the aws `IAM` roles via AWS Cli?

✍ Bleow is how you can get `IAM` roles listing, you have to create `profile` to use that in the CLI as i mentioned below..

```Shell
(awscliv2) $ aws iam list-roles --query 'Roles[?starts_with(RoleName, `hwde`)].RoleName' --output table --profile slpr
---------------------------------------------------------
|                       ListRoles                       |
+-------------------------------------------------------+
|  test-ec2-backup-role                                 |
|  test-stg-ec2-role                                    |
|  test-stg-iam-admin-role                              |
|  test-stg-iam-backup-fsx-role                         |
|  test_infra_iam_ssm_role                              |
+-------------------------------------------------------+
```
7- How to get the list of `ec2` volumes based on the `State` as there are are muliple `State` an `ec2` instance can have for example like `in-use`, `Pending` etc.
 
```Shell
(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[?State==`in-use`].{ID: VolumeId, State: State, InstanceId: Attachments[0].InstanceId}' --profile dev --output table
------------------------------------------------------------
|                      DescribeVolumes                     |
+------------------------+-----------------------+---------+
|           ID           |      InstanceId       |  State  |
+------------------------+-----------------------+---------+
|  vol-01ea79cc1c1234b00 |  i-0327cf04986081234  |  in-use |
|  vol-1234abc045cdb2a56 |  i-0c9e1111fe0105ed6  |  in-use |
|  vol-0fbe38a5b1234f575 |  i-0c8d1111fe0105ed6  |  in-use |
|  vol-09ed5d3e9bac12b0a |  i-0cb11b3c973b03bf6  |  in-use |
+------------------------+-----------------------+---------+
```


`**instance-state-name**` - The state of the instance (pending | running | shutting-down | terminated | stopping | stopped).
`**instance-status.reachability**` - Filters on instance status where the name is reachability (passed | failed | initializing | insufficient-data).
`**instance-status.status**` - The status of the instance (ok | impaired | initializing | insufficient-data | not-applicable).
`**system-status.reachability**` - Filters on system status where the name is reachability (passed | failed | initializing | insufficient-data).
`**system-status.status**` - The system status of the instance (ok | impaired | initializing | insufficient-data | not-applicable).



