# AWS CLI usage 

✍ Query a Volume and get `Volume ID` and `VolumeType` in a array format.

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
`rgb(R,G,B)`	
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
`rgb(9, 105, 218)`
✍ What is difference while using `--query` and `--filter` in aws cli?

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

✍ How list your Backups which has resource type FsxN?

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

✍ How to get details  of a Particulat restore Job?
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

✍ How to List Volumes showing attachment using Dictionary/Array Notation?

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

✍ HOw to list down the aws `IAM` roles via AWS Cli?
Bleow is how you can get `IAM` roles listing, you have to create `profile` to use that in the CLI as i mentioned below..

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

✍ How to get the list of `ec2` volumes based on the `State` as there are are muliple `State` an `ec2` instance can have for example like `in-use`, `Pending` etc.
 
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

✍ How to list `cloudwatch` metrics using `namespace` ?

```Shell
(awscliv2) $ aws cloudwatch list-metrics --namespace AWS/EC2 --metric-name CPUUtilization --query  'Metrics[].{Namespace:Namespace, MetricName:MetricName, InstanceId: Dimensions[0].Value}' --profile dev --output table --no-cli-pager
--------------------------------------------------------
|                      ListMetrics                     |
+----------------------+------------------+------------+
|      InstanceId      |   MetricName     | Namespace  |
+----------------------+------------------+------------+
|  i-0327cf04986081234 |  CPUUtilization  |  AWS/EC2   |
|  i-0c9e1111fe0207ed6 |  CPUUtilization  |  AWS/EC2   |
|  i-0c8d2011fe0105ct9 |  CPUUtilization  |  AWS/EC2   |
+----------------------+------------------+------------+
```

✍ List all the `cloudwatch` metrics regardless of `namespace` then you can use below query.

```Shell
(awscliv2) $ aws cloudwatch list-metrics --query 'Metrics[].{Namespace:Namespace, MetricName:MetricName, InstanceId: Dimensions[0].Value}' --profile dev --output table --no-cli-pager`
```

✍ How you can list `cloudwatch` metrics based on the particular `--owning-account` ?

```shell
(awscliv2) $ aws cloudwatch list-metrics --include-linked-accounts --owning-account "111122223333"
```

➜ AWS KB Reference:  https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html

✍ To get the status of all instances with an instance status of `ok`, use the following command.::

```Shell
(awscliv2) $ aws ec2 describe-instance-status --filters Name=instance-status.status,Values=ok  --query 'InstanceStatuses[].{AvailabilityZone: AvailabilityZone, InstanceId: InstanceId, InstanceState: InstanceState.Name, InstanceStatus: InstanceStatus.Details[0].Status, SystemStatus: SystemStatus.Details[0].Status}' --profile dev --output table
------------------------------------------------------------------------------------------------
|                                    DescribeInstanceStatus                                    |
+------------------+----------------------+----------------+------------------+----------------+
| AvailabilityZone |     InstanceId       | InstanceState  | InstanceStatus   | SystemStatus   |
+------------------+----------------------+----------------+------------------+----------------+
|  eu-west-1a      | i-0327cf04986081234  |  running       |  passed          |  passed        |
|  eu-west-1a      | i-0c9e1111fe0207ed6  |  running       |  passed          |  passed        |
|  eu-west-1a      | i-0c8d2011fe0105ct9  |  running       |  passed          |  passed        |
+------------------+----------------------+----------------+------------------+----------------+
```

Note:
-----

> **instance-state-name:**  `The state of the instance (pending | running | shutting-down | terminated | stopping | stopped).`
> 
> **instance-status.reachability:** `Filters on instance status where the name is reachability (passed | failed | initializing | insufficient-data).`
> 
> **instance-status.status:** `The status of the instance (ok | impaired | initializing | insufficient-data | not-applicable).`
> 
> **system-status.reachability:** `Filters on system status where the name is reachability (passed | failed | initializing | insufficient-data).`
> 
> **system-status.status:** `The system status of the instance (ok | impaired | initializing | insufficient-data | not-applicable).`


✍ To filter through all output from an array, you can use the wildcard notation. Wildcard expressions are expressions used to return elements using the * notation.
The following example queries all Volumes content.

`(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[*]' --profile dev`

✍ To view a specific volume in the array by index, you call the array index. For example, the first item in the Volumes array has an index of 0, resulting in the Volumes[0] query. For more information about array indexes, see index expressions on the JMESPath website(https://jmespath.org/specification.html#index-expressions).
✍ To view a specific range of volumes by index, use slice with the following syntax, where start is the starting array index, stop is the index where the filter stops processing, and step is the skip interval.

```Shell
Syntax
<arrayName>[<start>:<stop>:<step>]`
If any of these are omitted from the slice expression, they use the following default values:
Start – The first index in the list, 0.
Stop – The last index in the list.
Step – No step skipping, where the value is 1.
```

✍ How to use index based Selection in AWS CLI?
For an example if you are listing the `ec2` volumes to return only the first two volumes, you use a `start value of 0`, a `stop value of 2`, and a `step value of 1` as shown in the following example.

```Sehll
(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[0:2:1].Attachments[].{AttachTime: AttachTime, Device: Device, InstanceId: InstanceId, VolumeId: VolumeId, DeleteOnTermination: DeleteOnTermination, State: State}' --profile dev --output table
------------------------------------------------------------------------------------------------------------------------------
|                                                       DescribeVolumes                                                      |
+---------------------------+----------------------+-----------+----------------------+------------+-------------------------+
|        AttachTime         | DeleteOnTermination  |  Device   |     InstanceId       |   State    |        VolumeId         |
+---------------------------+----------------------+-----------+----------------------+------------+-------------------------+
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb |  i-06253db1de27a1472 |  attached  |  vol-0034927f6d89a987c  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb |  i-0c9e0188fe0105ed6 |  attached  |  vol-0ad69e58bb689838e  |
+---------------------------+----------------------+-----------+----------------------+------------+-------------------------+
```

✍ Since the above example contains default values, you can shorten the slice from Volumes[0:2:1] to Volumes[:2] this will ensude the same results.

```Shell
(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[:2].Attachments[].{AttachTime: AttachTime, Device: Device, InstanceId: InstanceId, VolumeId: VolumeId, DeleteOnTermination: DeleteOnTermination, State: State}' --profile dev --output table
------------------------------------------------------------------------------------------------------------------------------
|                                                       DescribeVolumes                                                      |
+---------------------------+----------------------+-----------+----------------------+------------+-------------------------+
|        AttachTime         | DeleteOnTermination  |  Device   |     InstanceId       |   State    |        VolumeId         |
+---------------------------+----------------------+-----------+----------------------+------------+-------------------------+
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb |  i-06253db1de27a1472 |  attached  |  vol-0034927f6d89a987c  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb |  i-0c9e0188fe0105ed6 |  attached  |  vol-0ad69e58bb689838e  |
+---------------------------+----------------------+-----------+----------------------+------------+-------------------------+
```

✍ As you see the above example where we are using index basd `--query` to get the listing of our `VolumeId` and other attributes,
Filtering nested data
<expression>.<expression>

To narrow the filtering of the Volumes[*] for nested values, you use subexpressions by appending a period and your filter criteria.

```Shell
(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[*].{AttachTime: Attachments[0].AttachTime, Device: Attachments[0].Device, InstanceId: Attachments[0].InstanceId, VolumeId: Attachments[0].VolumeId, DeleteOnTermination: Attachments[0].DeleteOnTermination, "Volume State": Attachments[0].State, SnapshotId: SnapshotId,  Iops: Iops, Size: Size, Encrypted: Encrypted, "Volume Status": State }' --profile dev --output table
```

✍ Steps can also use negative numbers to filter in the reverse order of an array as shown in the following example ...

```Shell
(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[::-2].{AttachTime: Attachments[0].AttachTime, Device: Attachments[0].Device, InstanceId: Attachments[0].InstanceId, VolumeId: Attachments[0].VolumeId, DeleteOnTermination: Attachments[0].DeleteOnTermination, "Volume State": Attachments[0].State, SnapshotId: SnapshotId,  Iops: Iops, Size: Size, Encrypted: Encrypted, "Volume Status": State }' --profile dev --output table
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                                             DescribeVolumes                                                                                             |
+---------------------------+----------------------+------------+------------+----------------------+-------+-------+-------------------------+---------------+-----------------+-------------------------+
|        AttachTime         | DeleteOnTermination  |  Device    | Encrypted  |     InstanceId       | Iops  | Size  |       SnapshotId        | Volume State  |  Volume Status  |        VolumeId         |
+---------------------------+----------------------+------------+------------+----------------------+-------+-------+-------------------------+---------------+-----------------+-------------------------+
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb  |  True      |  i-06253db1de27a1472 |  100  |  30   |  snap-0e428b2088d5f1a7f |  attached     |  in-use         |  vol-0034927f6d89a987c   |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb  |  True      |  i-0c9e0188fe0105ed6 |  300  |  100  |  snap-0c26d476f059eb3d4 |  attached     |  available      |  vol-0ad69e58bb689838e                   |
+---------------------------+----------------------+------------+------------+----------------------+-------+-------+-------------------------+---------------+-----------------+-------------------------+
```
✍ Filtering for specific values: To filter for specific values in a list, you use a filter expression as shown in the following syntax.
>
> Syntax: `[<expression> <comparator> <expression>]`
>
> Expression comparators include ==, !=, <, <=, >, and >= . The following example filters for the VolumeIds for all Volumes in an AttachedState.

For an example , if we want list only the volumes those have `State` as an `attached` there we shall use expression comparator `==` that says `equals to`, look at the below example ...

```Shell
(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[*].Attachments[?State==`attached`].{AttachTime: AttachTime, Device: Device, InstanceId: InstanceId, VolumeId: VolumeId,  "Volume Status": State, DeleteOnTermination: DeleteOnTermination }[]' --profile dev  --no-cli-pager
[
    {
        "AttachTime": "2022-12-22T12:49:14+00:00",
        "Device": "/dev/sdb",
        "InstanceId": "i-0327cf01234567899",
        "VolumeId": "vol-01ou79cc1c0111b00",
        "Volume Status": "attached",
        "DeleteOnTermination": true
    },
    {
        "AttachTime": "2022-12-22T12:49:14+00:00",
        "Device": "/dev/sdb",
        "InstanceId": "i-03b9a2b946be12345",
        "VolumeId": "vol-02c7682c6cc3d4321",
        "Volume Status": "attached",
        "DeleteOnTermination": true
    },
```

✍ If you want to flattened resulting the in the following example.

```Shell
(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[*].Attachments[?State==`attached`][].{AttachTime: AttachTime, Device: Device, InstanceId: InstanceId, VolumeId: VolumeId,  "Volume Status": State, DeleteOnTermination: DeleteOnTermination }' --profile dev  --no-cli-pager --output table
------------------------------------------------------------------------------------------------------------------------------------
|                                                          DescribeVolumes                                                         |
+---------------------------+----------------------+------------+----------------------+-----------------+-------------------------+
|        AttachTime         | DeleteOnTermination  |  Device    |     InstanceId       |  Volume Status  |        VolumeId         |
+---------------------------+----------------------+------------+----------------------+-----------------+-------------------------+
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb  |  i-0327cf04986086711 |  attached       |  vol-01ea79cc1c0916b00  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb  |  i-03b9a2b946be51127 |  attached       |  vol-02c7682c6cc3d3683  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sda1 |  i-0327cf04986086711 |  attached       |  vol-0aec200671bfcc19c  |
|  2022-10-13T07:28:44+00:00|  True                |  /dev/xvda |  i-02e4cbcbe10cb5e79 |  attached       |  vol-0b88f41975ef5cb3f  |
|  2022-10-18T11:10:28+00:00|  True                |  /dev/xvda |  i-0cb02b3c973b77bf6 |  attached       |  vol-09ed8d3e9baa62b0a  |
+---------------------------+----------------------+------------+----------------------+-----------------+-------------------------+

✍ The another example using comparator(comparisioon operators) for numric validation, in the below example we are filtering for the `VolumeIds` of all Volumes that have a size greater than 100.

```Shell
(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[?Size >`100`].{AttachTime: Attachments[0].AttachTime, Device: Attachments[0].Device, InstanceId: Attachments[0].InstanceId, VolumeId: Attachments[0].VolumeId, DeleteOnTermination: Attachments[0].DeleteOnTermination, "Volume State": Attachments[0].State, SnapshotId: SnapshotId,  Iops: Iops, Size: Size, Encrypted: Encrypted, "Volume Status": State }' --profile dev --output table
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                                       DescribeVolumes                                                                                       |
+---------------------------+----------------------+------------+------------+----------------------+-------+-------+-------------+---------------+-----------------+-------------------------+
|        AttachTime         | DeleteOnTermination  |  Device    | Encrypted  |     InstanceId       | Iops  | Size  | SnapshotId  | Volume State  |  Volume Status  |        VolumeId         |
+---------------------------+----------------------+------------+------------+----------------------+-------+-------+-------------+---------------+-----------------+-------------------------+
|  2022-06-28T12:35:03+00:00|  True                |  /dev/xvdf |  True      |  i-0c9e1155fe0105ed6 |  3000 |  140  |             |  attached     |  in-use         |  vol-0789abc045cdb2a56  |
|  2022-06-28T12:40:34+00:00|  True                |  /dev/sdb  |  True      |  i-0c9e1155fe0105ed6 |  1620 |  540  |             |  attached     |  in-use         |  vol-0ad69e58bb689838e  |
|  2022-06-28T12:44:35+00:00|  True                |  /dev/xvdg |  True      |  i-0c9e1155fe0105ed6 |  3072 |  500  |             |  attached     |  in-use         |  vol-0fbe38a5b1656f575  |
+---------------------------+----------------------+------------+------------+----------------------+-------+-------+-------------+---------------+-----------------+-------------------------+
```

➜ AWS KB Reference: https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-filter.html

aws ec2 describe-images --owners self --query 'reverse(sort_by(Images,&CreationDate))[:5].{id:ImageId,date:CreationDate}' --profile dev

✍ How you can filter the AWS Images with the particular Owner?
You can use `aws ec2 describe-images` and ther you can use filters based on the `Name & Value` further combining with `--query` and even you can sort them using `sort_by()` function.

```Shell
(awscliv2) $ aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn*gp2" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs" --query "sort_by(Images, &CreationDate)[-1].ImageId"   --output text --profile dev
```

✍ How to check the `IOPS` for an `ec2` volume which is active or `in-use` using comparator to filter out the VolumeId with certain `IOPS`.
The following example displays the number of available volumes that are more than 1000 IOPS by using length to count how many are in a list.

```Shell
(awscliv2) $ aws ec2 describe-volumes --filters "Name=status,Values=in-use" --query 'Volumes[?Iops > `300`].{Iops: Iops, VolumeId: VolumeId}' --profile dev --output table
-----------------------------------
|         DescribeVolumes         |
+------+--------------------------+
| Iops |        VolumeId          |
+------+--------------------------+
|  3000|  vol-01ea11tt1c0516b00   |
|  3000|  vol-0952abc017cdbd956   |
|  1250|  vol-01234d2880b2cf90b   |
|  1620|  vol-0ad60e11bb123456e   |
+------+--------------------------+
```

✍ How to add tags to an `ec2` instance? 
You simply achieve that by using `create-tags` command using `--tags` attribute, see the example below.
```Shell
(awscliv2) $ aws ec2 create-tags --resources <ec2_Instnace_Id> --tags Key=DBhost,Value=mybdhost001.example.com --profile dev
```

✍ How to create a stack in cloudformation via AWS CLI?
You can use simplay `create-stack` command with requited attributes such as `--template-body` which contain the Yaml file name having you code, with additional parameter `--capabilities` , else you will encounter an issue like __An error occurred (InsufficientCapabilitiesException) when calling the CreateStack operation: Requires capabilities : [CAPABILITY_NAMED_IAM]__ .

```Shell
(awscliv2) $ aws cloudformation create-stack --stack-name "MyDBStack" --template-body file://test.yaml --capabilities CAPABILITY_NAMED_IAM --profile dev
```

