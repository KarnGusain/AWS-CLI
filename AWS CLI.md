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


<==


(awscliv2) $ aws cloudwatch list-metrics --namespace AWS/EC2 --metric-name CPUUtilization --query  'Metrics[].{Namespace:Namespace, MetricName:MetricName, InstanceId: Dimensions[0].Value}' --profile dev --output table --no-cli-pager
--------------------------------------------------------
|                      ListMetrics                     |
+----------------------+------------------+------------+
|      InstanceId      |   MetricName     | Namespace  |
+----------------------+------------------+------------+
|  i-0df3cc311acfccca0 |  CPUUtilization  |  AWS/EC2   |
|  i-0c356f7cc19be4139 |  CPUUtilization  |  AWS/EC2   |
|  i-0ed8a1cb6de852a2e |  CPUUtilization  |  AWS/EC2   |
|  i-022c959391397d35e |  CPUUtilization  |  AWS/EC2   |
|  i-01593da06848a922f |  CPUUtilization  |  AWS/EC2   |
|  i-03a5dd4131bfec0fb |  CPUUtilization  |  AWS/EC2   |
|  i-0aea6a3fa7d65a7df |  CPUUtilization  |  AWS/EC2   |
+----------------------+------------------+------------+

(awscliv2) $ aws cloudwatch list-metrics --query 'Metrics[].{Namespace:Namespace, MetricName:MetricName, InstanceId: Dimensions[0].Value}' --profile dev --output table --no-cli-pager

$ aws cloudwatch list-metrics --include-linked-accounts --owning-account "111122223333"

Link:: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html

To get the status of all instances with an instance status of ok, use the following command.::

(awscliv2) $ aws ec2 describe-instance-status     --filters Name=instance-status.status,Values=ok  --query 'InstanceStatuses[].{AvailabilityZone: AvailabilityZone, InstanceId: InstanceId, InstanceState: InstanceState.Name, InstanceStatus: InstanceStatus.Details[0].Status, SystemStatus: SystemStatus.Details[0].Status}' --profile dev --output table
------------------------------------------------------------------------------------------------
|                                    DescribeInstanceStatus                                    |
+------------------+----------------------+----------------+------------------+----------------+
| AvailabilityZone |     InstanceId       | InstanceState  | InstanceStatus   | SystemStatus   |
+------------------+----------------------+----------------+------------------+----------------+
|  eu-west-1a      |  i-0a4209dfc5774a2ea |  running       |  passed          |  passed        |
|  eu-west-1a      |  i-0d7aca605032e6ff3 |  running       |  passed          |  passed        |
|  eu-west-1a      |  i-0cb02b3c973b77bf6 |  running       |  passed          |  passed        |
|  eu-west-1a      |  i-0e9e36308d1dad996 |  running       |  passed          |  passed        |
|  eu-west-1a      |  i-0f57b147ea9124344 |  running       |  passed          |  passed        |
|  eu-west-1a      |  i-0bf8c4933a451c3a9 |  running       |  passed          |  passed        |
|  eu-west-1b      |  i-03b9a2b946be51127 |  running       |  passed          |  passed        |
|  eu-west-1b      |  i-0327cf04986086711 |  running       |  passed          |  passed        |
|  eu-west-1b      |  i-0f1baa88774a3ac9d |  running       |  passed          |  passed        |
|  eu-west-1a      |  i-09379cb842ed015f2 |  running       |  passed          |  passed        |
+------------------+----------------------+----------------+------------------+----------------+

Ref-Linjk:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-system-instance-status-check.html

To filter through all output from an array, you can use the wildcard notation. Wildcard expressions are expressions used to return elements using the * notation.
The following example queries all Volumes content.

(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[*]' --profile dev

To view a specific volume in the array by index, you call the array index. For example, the first item in the Volumes array has an index of 0, resulting in the Volumes[0] query. For more information about array indexes, see index expressions on the JMESPath website(https://jmespath.org/specification.html#index-expressions).

To view a specific range of volumes by index, use slice with the following syntax, where start is the starting array index, stop is the index where the filter stops processing, and step is the skip interval.

Syntax


<arrayName>[<start>:<stop>:<step>]
If any of these are omitted from the slice expression, they use the following default values:

Start – The first index in the list, 0.

Stop – The last index in the list.

Step – No step skipping, where the value is 1.

To return only the first two volumes, you use a start value of 0, a stop value of 2, and a step value of 1 as shown in the following example.
(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[0:2:1].Attachments[].{AttachTime: AttachTime, Device: Device, InstanceId: InstanceId, VolumeId: VolumeId, DeleteOnTermination: DeleteOnTermination, State: State}' --profile dev --output table
------------------------------------------------------------------------------------------------------------------------------
|                                                       DescribeVolumes                                                      |
+---------------------------+----------------------+-----------+----------------------+------------+-------------------------+
|        AttachTime         | DeleteOnTermination  |  Device   |     InstanceId       |   State    |        VolumeId         |
+---------------------------+----------------------+-----------+----------------------+------------+-------------------------+
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb |  i-0327cf04986086711 |  attached  |  vol-01ea79cc1c0916b00  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb |  i-03b9a2b946be51127 |  attached  |  vol-02c7682c6cc3d3683  |
+---------------------------+----------------------+-----------+----------------------+------------+-------------------------+

Since this example contains default values, you can shorten the slice from Volumes[0:2:1] to Volumes[:2]

(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[:2].Attachments[].{AttachTime: AttachTime, Device: Device, InstanceId: InstanceId, VolumeId: VolumeId, DeleteOnTermination: DeleteOnTermination, State: State}' --profile dev --output table
------------------------------------------------------------------------------------------------------------------------------
|                                                       DescribeVolumes                                                      |
+---------------------------+----------------------+-----------+----------------------+------------+-------------------------+
|        AttachTime         | DeleteOnTermination  |  Device   |     InstanceId       |   State    |        VolumeId         |
+---------------------------+----------------------+-----------+----------------------+------------+-------------------------+
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb |  i-0327cf04986086711 |  attached  |  vol-01ea79cc1c0916b00  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb |  i-03b9a2b946be51127 |  attached  |  vol-02c7682c6cc3d3683  |
+---------------------------+----------------------+-----------+----------------------+------------+-------------------------+


Filtering nested data
<expression>.<expression>


To narrow the filtering of the Volumes[*] for nested values, you use subexpressions by appending a period and your filter criteria.

(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[*].{AttachTime: Attachments[0].AttachTime, Device: Attachments[0].Device, InstanceId: Attachments[0].InstanceId, VolumeId: Attachments[0].VolumeId, DeleteOnTermination: Attachments[0].DeleteOnTermination, "Volume State": Attachments[0].State, SnapshotId: SnapshotId,  Iops: Iops, Size: Size, Encrypted: Encrypted, "Volume Status": State }' --profile dev --output table
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                                             DescribeVolumes                                                                                             |
+---------------------------+----------------------+------------+------------+----------------------+-------+-------+-------------------------+---------------+-----------------+-------------------------+
|        AttachTime         | DeleteOnTermination  |  Device    | Encrypted  |     InstanceId       | Iops  | Size  |       SnapshotId        | Volume State  |  Volume Status  |        VolumeId         |
+---------------------------+----------------------+------------+------------+----------------------+-------+-------+-------------------------+---------------+-----------------+-------------------------+
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb  |  False     |  i-0327cf04986086711 |  3000 |  60   |  snap-0d9061f781aa26e59 |  attached     |  in-use         |  vol-01ea79cc1c0916b00  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb  |  False     |  i-03b9a2b946be51127 |  3000 |  60   |  snap-0d9061f781aa26e59 |  attached     |  in-use         |  vol-02c7682c6cc3d3683  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sda1 |  False     |  i-0327cf04986086711 |  3000 |  10   |  snap-06216078ef0994eb3 |  attached     |  in-use         |  vol-0aec200671bfcc19c  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sda1 |  False     |  i-0f1baa88774a3ac9d |  3000 |  10   |  snap-06216078ef0994eb3 |  attached     |  in-use         |  vol-0cac708d236f9b678  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb  |  False     |  i-0f1baa88774a3ac9d |  3000 |  60   |  snap-0d9061f781aa26e59 |  attached     |  in-use         |  vol-05fe294544859c37e  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sda1 |  False     |  i-03b9a2b946be51127 |  3000 |  10   |  snap-06216078ef0994eb3 |  attached     |  in-use         |  vol-0e09c8f1c14697206  |
|  2022-06-23T09:58:27+00:00|  True                |  /dev/sda1 |  False     |  i-0a4209dfc5774a2ea |  300  |  100  |  snap-002aa541093a0e2e2 |  attached     |  in-use         |  vol-05f53cf2c46662d8d  |
|  2022-06-24T05:31:56+00:00|  True                |  /dev/sda1 |  False     |  i-09379cb842ed015f2 |  100  |  8    |  snap-075c56b437d722107 |  attached     |  in-use         |  vol-0b54ef040b97682e3  |
|  2022-06-28T12:35:03+00:00|  True                |  /dev/xvdf |  True      |  i-0c9e1155fe0105ed6 |  3000 |  140  |                         |  attached     |  in-use         |  vol-0789abc045cdb2a56  |
|  2022-06-28T12:35:03+00:00|  True                |  /dev/sda1 |  True      |  i-0c9e1155fe0105ed6 |  1250 |  47   |  snap-04755a46429a9e4e0 |  attached     |  in-use         |  vol-08684d2880b2cf22b  |
|  2022-06-28T12:40:34+00:00|  True                |  /dev/sdb  |  True      |  i-0c9e1155fe0105ed6 |  1620 |  540  |                         |  attached     |  in-use         |  vol-0ad69e58bb689838e  |
|  2022-06-28T12:44:35+00:00|  True                |  /dev/xvdg |  True      |  i-0c9e1155fe0105ed6 |  3072 |  500  |                         |  attached     |  in-use         |  vol-0fbe38a5b1656f575  |
|  2022-07-13T13:38:19+00:00|  True                |  /dev/xvda |  False     |  i-0d7aca605032e6ff3 |  100  |  8    |  snap-04b1b9d5c5d2d8495 |  attached     |  in-use         |  vol-00572e3b4a47a6b15  |
|  2022-08-16T14:38:04+00:00|  True                |  /dev/sda1 |  False     |  i-0bf8c4933a451c3a9 |  3000 |  10   |  snap-06216078ef0994eb3 |  attached     |  in-use         |  vol-016f1a958312578e7  |
|  2022-08-16T14:38:04+00:00|  True                |  /dev/sda1 |  False     |  i-0e9e36308d1dad996 |  3000 |  10   |  snap-06216078ef0994eb3 |  attached     |  in-use         |  vol-0a16954434b191c4c  |
|  2022-08-16T14:38:04+00:00|  True                |  /dev/sdb  |  False     |  i-0bf8c4933a451c3a9 |  3000 |  60   |  snap-0d9061f781aa26e59 |  attached     |  in-use         |  vol-0cce47cc4afeb644c  |
|  2022-08-16T14:38:04+00:00|  True                |  /dev/sdb  |  False     |  i-0e9e36308d1dad996 |  3000 |  60   |  snap-0d9061f781aa26e59 |  attached     |  in-use         |  vol-04c7fed89d5e591b0  |
|  2022-08-23T11:13:27+00:00|  True                |  /dev/sdb  |  True      |  i-0f57b147ea9124344 |  3000 |  60   |  snap-03f9e9d542d9359d4 |  attached     |  in-use         |  vol-02b261613c3dde2f6  |
|  2022-08-23T11:13:27+00:00|  True                |  /dev/sda1 |  True      |  i-0f57b147ea9124344 |  3000 |  10   |  snap-040584d0b1ab4ffb9 |  attached     |  in-use         |  vol-0060d2ec85131a87b  |
|  None                     |  None                |  None      |  False     |  None                |  300  |  100  |  snap-0c26d476f059eb3d4 |  None         |  available      |  None                   |
|  None                     |  None                |  None      |  False     |  None                |  300  |  100  |  snap-0c26d476f059eb3d4 |  None         |  available      |  None                   |
|  2022-10-13T07:28:44+00:00|  True                |  /dev/xvda |  False     |  i-02e4cbcbe10cb5e79 |  100  |  8    |  snap-0e428b2088d5f1a7f |  attached     |  in-use         |  vol-0b88f41975ef5cb3f  |
|  2022-10-18T11:10:28+00:00|  True                |  /dev/xvda |  False     |  i-0cb02b3c973b77bf6 |  100  |  30   |  snap-0e428b2088d5f1a7f |  attached     |  in-use         |  vol-09ed8d3e9baa62b0a  |
+---------------------------+----------------------+------------+------------+----------------------+-------+-------+-------------------------+---------------+-----------------+-------------------------+


=> Steps can also use negative numbers to filter in the reverse order of an array as shown in the following example::

(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[::-2].{AttachTime: Attachments[0].AttachTime, Device: Attachments[0].Device, InstanceId: Attachments[0].InstanceId, VolumeId: Attachments[0].VolumeId, DeleteOnTermination: Attachments[0].DeleteOnTermination, "Volume State": Attachments[0].State, SnapshotId: SnapshotId,  Iops: Iops, Size: Size, Encrypted: Encrypted, "Volume Status": State }' --profile dev --output table
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                                             DescribeVolumes                                                                                             |
+---------------------------+----------------------+------------+------------+----------------------+-------+-------+-------------------------+---------------+-----------------+-------------------------+
|        AttachTime         | DeleteOnTermination  |  Device    | Encrypted  |     InstanceId       | Iops  | Size  |       SnapshotId        | Volume State  |  Volume Status  |        VolumeId         |
+---------------------------+----------------------+------------+------------+----------------------+-------+-------+-------------------------+---------------+-----------------+-------------------------+
|  2022-10-18T11:10:28+00:00|  True                |  /dev/xvda |  False     |  i-0cb02b3c973b77bf6 |  100  |  30   |  snap-0e428b2088d5f1a7f |  attached     |  in-use         |  vol-09ed8d3e9baa62b0a  |
|  None                     |  None                |  None      |  False     |  None                |  300  |  100  |  snap-0c26d476f059eb3d4 |  None         |  available      |  None                   |
|  2022-08-23T11:13:27+00:00|  True                |  /dev/sda1 |  True      |  i-0f57b147ea9124344 |  3000 |  10   |  snap-040584d0b1ab4ffb9 |  attached     |  in-use         |  vol-0060d2ec85131a87b  |
|  2022-08-16T14:38:04+00:00|  True                |  /dev/sdb  |  False     |  i-0e9e36308d1dad996 |  3000 |  60   |  snap-0d9061f781aa26e59 |  attached     |  in-use         |  vol-04c7fed89d5e591b0  |
|  2022-08-16T14:38:04+00:00|  True                |  /dev/sda1 |  False     |  i-0e9e36308d1dad996 |  3000 |  10   |  snap-06216078ef0994eb3 |  attached     |  in-use         |  vol-0a16954434b191c4c  |
|  2022-07-13T13:38:19+00:00|  True                |  /dev/xvda |  False     |  i-0d7aca605032e6ff3 |  100  |  8    |  snap-04b1b9d5c5d2d8495 |  attached     |  in-use         |  vol-00572e3b4a47a6b15  |
|  2022-06-28T12:40:34+00:00|  True                |  /dev/sdb  |  True      |  i-0c9e1155fe0105ed6 |  1620 |  540  |                         |  attached     |  in-use         |  vol-0ad69e58bb689838e  |
|  2022-06-28T12:35:03+00:00|  True                |  /dev/xvdf |  True      |  i-0c9e1155fe0105ed6 |  3000 |  140  |                         |  attached     |  in-use         |  vol-0789abc045cdb2a56  |
|  2022-06-23T09:58:27+00:00|  True                |  /dev/sda1 |  False     |  i-0a4209dfc5774a2ea |  300  |  100  |  snap-002aa541093a0e2e2 |  attached     |  in-use         |  vol-05f53cf2c46662d8d  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb  |  False     |  i-0f1baa88774a3ac9d |  3000 |  60   |  snap-0d9061f781aa26e59 |  attached     |  in-use         |  vol-05fe294544859c37e  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sda1 |  False     |  i-0327cf04986086711 |  3000 |  10   |  snap-06216078ef0994eb3 |  attached     |  in-use         |  vol-0aec200671bfcc19c  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb  |  False     |  i-0327cf04986086711 |  3000 |  60   |  snap-0d9061f781aa26e59 |  attached     |  in-use         |  vol-01ea79cc1c0916b00  |
+---------------------------+----------------------+------------+------------+----------------------+-------+-------+-------------------------+---------------+-----------------+-------------------------+

"""
Filtering for specific values
To filter for specific values in a list, you use a filter expression as shown in the following syntax.

Syntax


? <expression> <comparator> <expression>]
Expression comparators include ==, !=, <, <=, >, and >= . The following example filters for the VolumeIds for all Volumes in an AttachedState.


"""
(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[*].Attachments[?State==`attached`].{AttachTime: AttachTime, Device: Device, InstanceId: InstanceId, VolumeId: VolumeId,  "Volume Status": State, DeleteOnTermination: DeleteOnTermination }[]' --profile dev  --no-cli-pager
[
    {
        "AttachTime": "2022-12-22T12:49:14+00:00",
        "Device": "/dev/sdb",
        "InstanceId": "i-0327cf04986086711",
        "VolumeId": "vol-01ea79cc1c0916b00",
        "Volume Status": "attached",
        "DeleteOnTermination": true
    },
    {
        "AttachTime": "2022-12-22T12:49:14+00:00",
        "Device": "/dev/sdb",
        "InstanceId": "i-03b9a2b946be51127",
        "VolumeId": "vol-02c7682c6cc3d3683",
        "Volume Status": "attached",
        "DeleteOnTermination": true
    },

This can then be flattened resulting in the following example.


(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[*].Attachments[?State==`attached`].{AttachTime: AttachTime, Device: Device, InstanceId: InstanceId, VolumeId: VolumeId,  "Volume Status": State, DeleteOnTermination: DeleteOnTermination }[]' --profile dev  --no-cli-pager --output table
------------------------------------------------------------------------------------------------------------------------------------
|                                                          DescribeVolumes                                                         |
+---------------------------+----------------------+------------+----------------------+-----------------+-------------------------+
|        AttachTime         | DeleteOnTermination  |  Device    |     InstanceId       |  Volume Status  |        VolumeId         |
+---------------------------+----------------------+------------+----------------------+-----------------+-------------------------+
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb  |  i-0327cf04986086711 |  attached       |  vol-01ea79cc1c0916b00  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb  |  i-03b9a2b946be51127 |  attached       |  vol-02c7682c6cc3d3683  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sda1 |  i-0327cf04986086711 |  attached       |  vol-0aec200671bfcc19c  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sda1 |  i-0f1baa88774a3ac9d |  attached       |  vol-0cac708d236f9b678  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb  |  i-0f1baa88774a3ac9d |  attached       |  vol-05fe294544859c37e  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sda1 |  i-03b9a2b946be51127 |  attached       |  vol-0e09c8f1c14697206  |
|  2022-06-23T09:58:27+00:00|  True                |  /dev/sda1 |  i-0a4209dfc5774a2ea |  attached       |  vol-05f53cf2c46662d8d  |
|  2022-06-24T05:31:56+00:00|  True                |  /dev/sda1 |  i-09379cb842ed015f2 |  attached       |  vol-0b54ef040b97682e3  |
|  2022-06-28T12:35:03+00:00|  True                |  /dev/xvdf |  i-0c9e1155fe0105ed6 |  attached       |  vol-0789abc045cdb2a56  |
|  2022-06-28T12:35:03+00:00|  True                |  /dev/sda1 |  i-0c9e1155fe0105ed6 |  attached       |  vol-08684d2880b2cf22b  |
|  2022-06-28T12:40:34+00:00|  True                |  /dev/sdb  |  i-0c9e1155fe0105ed6 |  attached       |  vol-0ad69e58bb689838e  |
|  2022-06-28T12:44:35+00:00|  True                |  /dev/xvdg |  i-0c9e1155fe0105ed6 |  attached       |  vol-0fbe38a5b1656f575  |
|  2022-07-13T13:38:19+00:00|  True                |  /dev/xvda |  i-0d7aca605032e6ff3 |  attached       |  vol-00572e3b4a47a6b15  |
|  2022-08-16T14:38:04+00:00|  True                |  /dev/sda1 |  i-0bf8c4933a451c3a9 |  attached       |  vol-016f1a958312578e7  |
|  2022-08-16T14:38:04+00:00|  True                |  /dev/sda1 |  i-0e9e36308d1dad996 |  attached       |  vol-0a16954434b191c4c  |
|  2022-08-16T14:38:04+00:00|  True                |  /dev/sdb  |  i-0bf8c4933a451c3a9 |  attached       |  vol-0cce47cc4afeb644c  |
|  2022-08-16T14:38:04+00:00|  True                |  /dev/sdb  |  i-0e9e36308d1dad996 |  attached       |  vol-04c7fed89d5e591b0  |
|  2022-08-23T11:13:27+00:00|  True                |  /dev/sdb  |  i-0f57b147ea9124344 |  attached       |  vol-02b261613c3dde2f6  |
|  2022-08-23T11:13:27+00:00|  True                |  /dev/sda1 |  i-0f57b147ea9124344 |  attached       |  vol-0060d2ec85131a87b  |
|  2022-10-13T07:28:44+00:00|  True                |  /dev/xvda |  i-02e4cbcbe10cb5e79 |  attached       |  vol-0b88f41975ef5cb3f  |
|  2022-10-18T11:10:28+00:00|  True                |  /dev/xvda |  i-0cb02b3c973b77bf6 |  attached       |  vol-09ed8d3e9baa62b0a  |
+---------------------------+----------------------+------------+----------------------+-----------------+-------------------------+
(awscliv2) $
(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[*].Attachments[?State==`attached`][].{AttachTime: AttachTime, Device: Device, InstanceId: InstanceId, VolumeId: VolumeId,  "Volume Status": State, DeleteOnTermination: DeleteOnTermination }' --profile dev  --no-cli-pager --output table
------------------------------------------------------------------------------------------------------------------------------------
|                                                          DescribeVolumes                                                         |
+---------------------------+----------------------+------------+----------------------+-----------------+-------------------------+
|        AttachTime         | DeleteOnTermination  |  Device    |     InstanceId       |  Volume Status  |        VolumeId         |
+---------------------------+----------------------+------------+----------------------+-----------------+-------------------------+
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb  |  i-0327cf04986086711 |  attached       |  vol-01ea79cc1c0916b00  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb  |  i-03b9a2b946be51127 |  attached       |  vol-02c7682c6cc3d3683  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sda1 |  i-0327cf04986086711 |  attached       |  vol-0aec200671bfcc19c  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sda1 |  i-0f1baa88774a3ac9d |  attached       |  vol-0cac708d236f9b678  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sdb  |  i-0f1baa88774a3ac9d |  attached       |  vol-05fe294544859c37e  |
|  2022-12-22T12:49:14+00:00|  True                |  /dev/sda1 |  i-03b9a2b946be51127 |  attached       |  vol-0e09c8f1c14697206  |
|  2022-06-23T09:58:27+00:00|  True                |  /dev/sda1 |  i-0a4209dfc5774a2ea |  attached       |  vol-05f53cf2c46662d8d  |
|  2022-06-24T05:31:56+00:00|  True                |  /dev/sda1 |  i-09379cb842ed015f2 |  attached       |  vol-0b54ef040b97682e3  |
|  2022-06-28T12:35:03+00:00|  True                |  /dev/xvdf |  i-0c9e1155fe0105ed6 |  attached       |  vol-0789abc045cdb2a56  |
|  2022-06-28T12:35:03+00:00|  True                |  /dev/sda1 |  i-0c9e1155fe0105ed6 |  attached       |  vol-08684d2880b2cf22b  |
|  2022-06-28T12:40:34+00:00|  True                |  /dev/sdb  |  i-0c9e1155fe0105ed6 |  attached       |  vol-0ad69e58bb689838e  |
|  2022-06-28T12:44:35+00:00|  True                |  /dev/xvdg |  i-0c9e1155fe0105ed6 |  attached       |  vol-0fbe38a5b1656f575  |
|  2022-07-13T13:38:19+00:00|  True                |  /dev/xvda |  i-0d7aca605032e6ff3 |  attached       |  vol-00572e3b4a47a6b15  |
|  2022-08-16T14:38:04+00:00|  True                |  /dev/sda1 |  i-0bf8c4933a451c3a9 |  attached       |  vol-016f1a958312578e7  |
|  2022-08-16T14:38:04+00:00|  True                |  /dev/sda1 |  i-0e9e36308d1dad996 |  attached       |  vol-0a16954434b191c4c  |
|  2022-08-16T14:38:04+00:00|  True                |  /dev/sdb  |  i-0bf8c4933a451c3a9 |  attached       |  vol-0cce47cc4afeb644c  |
|  2022-08-16T14:38:04+00:00|  True                |  /dev/sdb  |  i-0e9e36308d1dad996 |  attached       |  vol-04c7fed89d5e591b0  |
|  2022-08-23T11:13:27+00:00|  True                |  /dev/sdb  |  i-0f57b147ea9124344 |  attached       |  vol-02b261613c3dde2f6  |
|  2022-08-23T11:13:27+00:00|  True                |  /dev/sda1 |  i-0f57b147ea9124344 |  attached       |  vol-0060d2ec85131a87b  |
|  2022-10-13T07:28:44+00:00|  True                |  /dev/xvda |  i-02e4cbcbe10cb5e79 |  attached       |  vol-0b88f41975ef5cb3f  |
|  2022-10-18T11:10:28+00:00|  True                |  /dev/xvda |  i-0cb02b3c973b77bf6 |  attached       |  vol-09ed8d3e9baa62b0a  |
+---------------------------+----------------------+------------+----------------------+-----------------+-------------------------+

The following example filters for the VolumeIds of all Volumes that have a size greater than 100.

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

(awscliv2) $ aws ec2 describe-volumes --query 'Volumes[?Size >=`100`].{AttachTime: Attachments[0].AttachTime, Device: Attachments[0].Device, InstanceId: Attachments[0].InstanceId, VolumeId: Attachments[0].VolumeId, DeleteOnTermination: Attachments[0].DeleteOnTermination, "Volume State": Attachments[0].State, SnapshotId: SnapshotId,  Iops: Iops, Size: Size, Encrypted: Encrypted, "Volume Status": State }' --profile dev --output table
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                                             DescribeVolumes                                                                                             |
+---------------------------+----------------------+------------+------------+----------------------+-------+-------+-------------------------+---------------+-----------------+-------------------------+
|        AttachTime         | DeleteOnTermination  |  Device    | Encrypted  |     InstanceId       | Iops  | Size  |       SnapshotId        | Volume State  |  Volume Status  |        VolumeId         |
+---------------------------+----------------------+------------+------------+----------------------+-------+-------+-------------------------+---------------+-----------------+-------------------------+
|  2022-06-23T09:58:27+00:00|  True                |  /dev/sda1 |  False     |  i-0a4209dfc5774a2ea |  300  |  100  |  snap-002aa541093a0e2e2 |  attached     |  in-use         |  vol-05f53cf2c46662d8d  |
|  2022-06-28T12:35:03+00:00|  True                |  /dev/xvdf |  True      |  i-0c9e1155fe0105ed6 |  3000 |  140  |                         |  attached     |  in-use         |  vol-0789abc045cdb2a56  |
|  2022-06-28T12:40:34+00:00|  True                |  /dev/sdb  |  True      |  i-0c9e1155fe0105ed6 |  1620 |  540  |                         |  attached     |  in-use         |  vol-0ad69e58bb689838e  |
|  2022-06-28T12:44:35+00:00|  True                |  /dev/xvdg |  True      |  i-0c9e1155fe0105ed6 |  3072 |  500  |                         |  attached     |  in-use         |  vol-0fbe38a5b1656f575  |
|  None                     |  None                |  None      |  False     |  None                |  300  |  100  |  snap-0c26d476f059eb3d4 |  None         |  available      |  None                   |
|  None                     |  None                |  None      |  False     |  None                |  300  |  100  |  snap-0c26d476f059eb3d4 |  None         |  available      |  None                   |
+---------------------------+----------------------+------------+------------+----------------------+-------+-------+-------------------------+---------------+-----------------+-------------------------+

ref: https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-filter.html !!!

aws ec2 describe-images --owners self --query 'reverse(sort_by(Images,&CreationDate))[:5].{id:ImageId,date:CreationDate}' --profile dev


(awscliv2) $ aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn*gp2" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs" --query "sort_by(Images, &CreationDate)[-1].ImageId"     --output text --profile dev
ami-0d49bee5baa9964b7
(awscliv2) $ aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn*gp2" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs" --query "sort_by(Images, &CreationDate)[-1].ImageId"     --output text --profile phx
ami-0ee1fbb81d97398d2
(awscliv2) $

The following example displays the number of available volumes that are more than 1000 IOPS by using length to count how many are in a list.

(awscliv2) $ aws ec2 describe-volumes --filters "Name=status,Values=in-use" --query 'Volumes[?Iops > `300`].{Iops: Iops, VolumeId: VolumeId}' --profile dev --output table
-----------------------------------
|         DescribeVolumes         |
+------+--------------------------+
| Iops |        VolumeId          |
+------+--------------------------+
|  3000|  vol-01ea79cc1c0916b00   |
|  3000|  vol-02c7682c6cc3d3683   |
|  3000|  vol-0aec200671bfcc19c   |
|  3000|  vol-0cac708d236f9b678   |
|  3000|  vol-05fe294544859c37e   |
|  3000|  vol-0e09c8f1c14697206   |
|  3000|  vol-0789abc045cdb2a56   |
|  1250|  vol-08684d2880b2cf22b   |
|  1620|  vol-0ad69e58bb689838e   |
|  3072|  vol-0fbe38a5b1656f575   |
|  3000|  vol-016f1a958312578e7   |
|  3000|  vol-0a16954434b191c4c   |
|  3000|  vol-0cce47cc4afeb644c   |
|  3000|  vol-04c7fed89d5e591b0   |
|  3000|  vol-02b261613c3dde2f6   |
|  3000|  vol-0060d2ec85131a87b   |
+------+--------------------------+
(awscliv2) $ aws ec2 describe-volumes --filters "Name=status,Values=in-use" --query 'length(Volumes[?Iops > `300`])' --profile dev
16


https://github.com/awsdocs/aws-doc-sdk-examples/tree/main/aws-cli/bash-linux/ec2/change-ec2-instance-type
https://github.com/aws/aws-cli
https://jmespath.org/specification.html#multiselectlist
https://github.com/tim-finnigan/boto3
https://gist.github.com/avoidik/214399e234582f685197cde92d996aac

aws dynamodb get-item --consistent-read --table-name DDNS --key '{ "InstanceId": {"S": "InstanceId"}, "InstanceAttributes": {"S": "awvw1030261.nxdi.ie-awsc1.nxp.com"}}'

150631904550
aws cloudformation create-stack --stack-name "aws-backup-test-for-retention-and-lock" --template-body file://aws_backup_poc.yaml --capabilities CAPABILITY_NAMED_IAM --profile dev

aws fsx update-file-system --file-system-id fs-0d5e022912689767c  --storage-capacity 102400 --profile phx

aws fsx update-file-system --file-system-id fs-0bb890bd2a272c090  --ontap-configuration ThroughputCapacity=256 --profile phx


==================================>
for i in $(cat /tmp/aws.instances); 
	do 
	host=$(echo $i | awk -F, '{print $1}'); id=$(echo $i | awk -F, '{print $2}') ; aws ec2 create-tags --resources ${id} --tags Key=ARECORDNAME,Value=${host}. --region eu-west-1 ; done
	
	(awscliv2) $ for i in $(cat /tmp/aws2.instances); do host=$(echo $i | awk -F, '{print $1}'); insid=$(echo $i | awk -F, '{print $2}') ; aws ec2 create-tags --resources ${insid} --tags Key=DNSImport,Value=True --profile nlpr; done
(awscliv2) $ ./aws_list_instance_names nlpr table
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                         DescribeInstances                                                                        |
+-------------------------------------------------------+-------------+-------------+----------------------+-------------------------------------------------------+
|                       A-RECORD                        |     AZ      | IMPORT-TAG  |     Instance ID      |                     Instance Name                     |
+-------------------------------------------------------+-------------+-------------+----------------------+-------------------------------------------------------+
|  invw103storage-management06.nxdi.ie-awsc1.nxp.com.   |  eu-west-1c |  True       |  i-0172f5f8a43ebfb8c |  invw103storage-management06.nxdi.ie-awsc1.nxp.com    |
|  invw103storage-management.nxdi.ie-awsc1.nxp.com.     |  eu-west-1c |  True       |  i-075b6eda7301c11fe |  invw103storage-management.nxdi.ie-awsc1.nxp.com      |
|  invw103-storage-management-01.nxdi.ie-awsc1.nxp.com. |  eu-west-1c |  True       |  i-02d34ee11675ce00c |  invw103-storage-management-01.nxdi.ie-awsc1.nxp.com  |
|  invw103-storage-automation-01.nxdi.ie-awsc1.nxp.com. |  eu-west-1c |  True       |  i-0f6fd005d1a4cf5fb |  invw103-storage-automation-01.nxdi.ie-awsc1.nxp.com  |
|  NetAppCloudManagerConnector.nxdi.ie-awsc1.nxp.com.   |  eu-west-1c |  True       |  i-0aab8239c40efc0d7 |  NetAppCloudManagerConnector.nxdi.ie-awsc1.nxp.com    |
+-------------------------------------------------------+-------------+-------------+----------------------+-------------------------------------------------------+

(awscliv2) $ aws ec2 delete-tags --resources i-0aab8239c40efc0d7 --tags Key=DNSImport,Value=True --profile nlpr
(awscliv2) $ aws ec2 create-tags --resources i-0aab8239c40efc0d7 --tags Key=DNSImport,Value=True --profile nlpr
<================

<==>
(awscliv2) $ aws fsx describe-file-systems --query "FileSystems[*].{Name:Tags[?Key=='Name']|[0].Value, Storagecapacity:StorageCapacity,FS_ID:FileSystemId,Type:FileSystemType, Mount:LustreConfiguration.MountName, Throughput:LustreConfiguration.PerUnitStorageThroughput, Maintainancewindow:LustreConfiguration.WeeklyMaintenanceStartTime}" --profile phx --output table --no-cli-pager
--------------------------------------------------------------------------------------------------------------------------------------------
|                                                            DescribeFileSystems                                                           |
+----------------------+---------------------+-----------+-------------------------------------+------------------+-------------+----------+
|         FS_ID        | Maintainancewindow  |   Mount   |                Name                 | Storagecapacity  | Throughput  |  Type    |
+----------------------+---------------------+-----------+-------------------------------------+------------------+-------------+----------+
|  fs-077d0612bf36c377e|  1:10:00            |  knjlfbmv |  USAWSC201-userhome-00000001        |  9600            |  50         |  LUSTRE  |
|  fs-05d9d44787e5bb109|  1:10:00            |  6rjlfbmv |  USAWSC201-userscratch-00000001     |  4800            |  50         |  LUSTRE  |
|  fs-0901c3c2250135b03|  1:10:00            |  bo43fbmv |  USAWSC201-application-00000001     |  1200            |  50         |  LUSTRE  |
|  fs-01ef43bb9188b0911|  1:10:00            |  jg63fbmv |  USAWSC201-dscache-00000001         |  74400           |  50         |  LUSTRE  |
|  fs-093d61e8fca63f65c|  1:10:00            |  s3a3fbmv |  USAWSC201-tools-00000001           |  249600          |  200        |  LUSTRE  |
|  fs-0ba6d40d78ba28c88|  1:10:00            |  ceklhbmv |  USAWSC201-project-00000001         |  12000           |  50         |  LUSTRE  |
|  fs-0200c83e16342829c|  1:10:00            |  gjiizbmv |  USAWSC201-projectscratch-00000001  |  271200          |  50         |  LUSTRE  |
|  fs-00eb435abffd1efb5|  1:10:00            |  es5yrbmv |  USAWSC201-project-00000002         |  19200           |  50         |  LUSTRE  |
|  fs-0528940d151a3f123|  1:10:00            |  rdqyvbmv |  USAWSC201-project-00000003         |  62400           |  50         |  LUSTRE  |
|  fs-04c01eb6e0e987179|  1:10:00            |  34mj3bmv |  USAWSC201-projectscratch-00000002  |  69600           |  50         |  LUSTRE  |
|  fs-0c2857e73cc66a394|  1:10:00            |  4izz5bmv |  USAWSC201-project-00000004         |  12000           |  50         |  LUSTRE  |
|  fs-0abf65fbc91abe1d7|  1:10:00            |  taej5bmv |  USAWSC201-project-00000005         |  21600           |  50         |  LUSTRE  |
|  fs-0f4b0785b8ba46fe2|  1:10:00            |  i4cz5bmv |  USAWSC201-project-00000006         |  26400           |  50         |  LUSTRE  |
|  fs-039288c689e53ce3f|  1:10:00            |  f6t63bmv |  USAWSC201-project-00000007         |  38400           |  50         |  LUSTRE  |
|  fs-0d7c4334f6e7d9f5d|  1:10:00            |  kxwo3bmv |  USAWSC201-project-00000008         |  26400           |  50         |  LUSTRE  |
|  fs-0038f6d384178f8e1|  1:10:00            |  xdoo3bmv |  USAWSC201-project-00000009         |  36000           |  50         |  LUSTRE  |
|  fs-058b891a76555eca1|  1:10:00            |  h4do7bmv |  USAWSC201-project-00000010         |  19200           |  50         |  LUSTRE  |
|  fs-051b7dcf73f4f56a3|  1:10:00            |  g5ootbmv |  USAWSC201-projectscratch-00000003  |  9600            |  50         |  LUSTRE  |
|  fs-0a6f6aadfb04509b8|  1:10:00            |  7ig6pbmv |  USAWSC201-project-00000011         |  12000           |  50         |  LUSTRE  |
|  fs-0b4ad830925677665|  1:10:00            |  k5445bmv |  USAWSC201-project-00000012         |  36000           |  50         |  LUSTRE  |
|  fs-0f2fe5cee39317959|  1:10:00            |  mjfmrbmv |  USAWSC201-project-00000013         |  36000           |  50         |  LUSTRE  |
|  fs-06a5a1ceed32f752f|  1:10:00            |  eiqmxbmv |  USAWSC201-projectscratch-00000004  |  12000           |  50         |  LUSTRE  |
|  fs-0531244d4f7d1e22a|  1:10:00            |  zas4xbmv |  USAWSC201-project-00000014         |  55200           |  50         |  LUSTRE  |
|  fs-09a97856106e7c257|  1:10:00            |  mu4mxbmv |  USAWSC201-project-00000015         |  19200           |  50         |  LUSTRE  |
|  fs-0269acd9e3fac5a60|  1:10:00            |  6m54xbmv |  USAWSC201-project-00000016         |  12000           |  50         |  LUSTRE  |
|  fs-0f5960dc8556a3a96|  1:10:00            |  gu5mxbmv |  USAWSC201-userhome-00000001        |  9600            |  50         |  LUSTRE  |
|  fs-0bd931c64d0ff7363|  1:10:00            |  xa5mxbmv |  USAWSC201-userscratch-00000001     |  1200            |  50         |  LUSTRE  |
|  fs-0e909a96775f2a4da|  1:10:00            |  tyg4xbmv |  USAWSC201-projectscratch-00000001  |  1200            |  50         |  LUSTRE  |
|  fs-0b837a7156287f591|  1:10:00            |  v4gmxbmv |  USAWSC201-projectscratch-00000002  |  9600            |  50         |  LUSTRE  |
|  fs-004bfa8b9c73fa3d0|  1:10:00            |  qigmxbmv |  USAWSC201-project-00000017         |  12000           |  50         |  LUSTRE  |
|  fs-053353f7decc28598|  1:10:00            |  pymmxbmv |  USAWSC201-project-00000018         |  12000           |  50         |  LUSTRE  |
|  fs-0e65e30e1e2e2cf73|  1:10:00            |  rqo4xbmv |  USAWSC201-project-00000019         |  12000           |  50         |  LUSTRE  |
|  fs-0d9c2de794f9d0f5e|  1:10:00            |  xuomxbmv |  USAWSC201-project-00000020         |  12000           |  50         |  LUSTRE  |
|  fs-0edb070f42c297dcf|  1:10:00            |  ryp4xbmv |  USAWSC201-project-00000021         |  19200           |  50         |  LUSTRE  |
|  fs-0617299ae872ada3a|  1:10:00            |  rqj4xbmv |  USAWSC201-project-00000022         |  43200           |  50         |  LUSTRE  |
|  fs-0888dc938e959c727|  1:10:00            |  sfn4xbmv |  USAWSC201-projectscratch-00000005  |  9600            |  50         |  LUSTRE  |
|  fs-0542d9faf979c7e39|  1:10:00            |  x2m4xbmv |  USAWSC201-project-00000023         |  19200           |  50         |  LUSTRE  |
|  fs-0882eea6cb1323137|  1:10:00            |  5mimlbmv |  USAWSC201-project-00000024         |  12000           |  50         |  LUSTRE  |
|  fs-05b0c605bfd4d99f5|  1:10:00            |  en7mlbmv |  USAWSC201-project-00000025         |  12000           |  50         |  LUSTRE  |
|  fs-0704d05c55989a72c|  1:10:00            |  uhnmlbmv |  USAWSC201-project-00000026         |  12000           |  50         |  LUSTRE  |
|  fs-0e5344966a71dc67a|  1:10:00            |  wgo4nbmv |  USAWSC201-project-00000027         |  26400           |  50         |  LUSTRE  |
|  fs-0bc30bf7efc6a6cd6|  1:10:00            |  3gomnbmv |  USAWSC201-project-00000028         |  12000           |  50         |  LUSTRE  |
|  fs-0b6015847cad2a3d8|  1:10:00            |  dlgmnbmv |  USAWSC201-project-00000029         |  33600           |  50         |  LUSTRE  |
|  fs-0d5e022912689767c|  None               |  None     |  stcl101_staging01                  |  153600          |  None       |  ONTAP   |
|  fs-0bb890bd2a272c090|  None               |  None     |  stcl101_staging02                  |  153600          |  None       |  ONTAP   |
|  fs-0a7765c981e8c5f8c|  1:10:00            |  64r4fbmv |  USAWSC201-project-00000030         |  12000           |  50         |  LUSTRE  |
|  fs-0425eb5893281e047|  1:10:00            |  tm255bmv |  USAWSC201-project-00000031         |  19200           |  50         |  LUSTRE  |
|  fs-02e3667179daef6d7|  1:10:00            |  l765rbmv |  USAWSC201-project-00000032         |  12000           |  50         |  LUSTRE  |
|  fs-0c22e7a652613cf80|  6:21:00            |  kpoczbev |  USAWSC201-project-00000033         |  12000           |  50         |  LUSTRE  |
|  fs-0d115083c345f282f|  6:21:00            |  h3jszbev |  USAWSC201-project-00000034         |  12000           |  50         |  LUSTRE  |
|  fs-0451d3423e8a3effd|  1:10:00            |  6yus3bev |  USAWSC201-project-00000035         |  12000           |  50         |  LUSTRE  |
+----------------------+---------------------+-----------+-------------------------------------+------------------+-------------+----------+

(awscliv2) $ aws fsx describe-file-systems --query "FileSystems[?FileSystemType=='ONTAP'].{Name:Tags[?Key=='Name']|[0].Value, Storagecapacity:StorageCapacity,FS_ID:FileSystemId,Type:FileSystemType, Mount:LustreConfiguration.MountName, Throughput:LustreConfiguration.PerUnitStorageThroughput, Maintainancewindow:LustreConfiguration.WeeklyMaintenanceStartTime}" --profile phx --output table --no-cli-pager
------------------------------------------------------------------------------------------------------------------------
|                                                  DescribeFileSystems                                                 |
+----------------------+---------------------+--------+--------------------+------------------+--------------+---------+
|         FS_ID        | Maintainancewindow  | Mount  |       Name         | Storagecapacity  | Throughput   |  Type   |
+----------------------+---------------------+--------+--------------------+------------------+--------------+---------+
|  fs-0d5e022912689767c|  None               |  None  |  stcl101_staging01 |  153600          |  None        |  ONTAP  |
|  fs-0bb890bd2a272c090|  None               |  None  |  stcl101_staging02 |  153600          |  None        |  ONTAP  |
+----------------------+---------------------+--------+--------------------+------------------+--------------+---------+

(awscliv2) $ aws fsx describe-file-systems --query "FileSystems[?FileSystemType=='LUSTRE'].{Name:Tags[?Key=='Name']|[0].Value, Storagecapacity:StorageCapacity,FS_ID:FileSystemId,Type:FileSystemType, Mount:LustreConfiguration.MountName, Throughput:LustreConfiguration.PerUnitStorageThroughput, Maintainancewindow:LustreConfiguration.WeeklyMaintenanceStartTime}" --profile phx --output table --no-cli-pager
--------------------------------------------------------------------------------------------------------------------------------------------
|                                                            DescribeFileSystems                                                           |
+----------------------+---------------------+-----------+-------------------------------------+------------------+-------------+----------+
|         FS_ID        | Maintainancewindow  |   Mount   |                Name                 | Storagecapacity  | Throughput  |  Type    |
+----------------------+---------------------+-----------+-------------------------------------+------------------+-------------+----------+
|  fs-077d0612bf36c377e|  1:10:00            |  knjlfbmv |  USAWSC201-userhome-00000001        |  9600            |  50         |  LUSTRE  |
|  fs-05d9d44787e5bb109|  1:10:00            |  6rjlfbmv |  USAWSC201-userscratch-00000001     |  4800            |  50         |  LUSTRE  |
|  fs-0901c3c2250135b03|  1:10:00            |  bo43fbmv |  USAWSC201-application-00000001     |  1200            |  50         |  LUSTRE  |
|  fs-01ef43bb9188b0911|  1:10:00            |  jg63fbmv |  USAWSC201-dscache-00000001         |  74400           |  50         |  LUSTRE  |
|  fs-093d61e8fca63f65c|  1:10:00            |  s3a3fbmv |  USAWSC201-tools-00000001           |  249600          |  200        |  LUSTRE  |
|  fs-0ba6d40d78ba28c88|  1:10:00            |  ceklhbmv |  USAWSC201-project-00000001         |  12000           |  50         |  LUSTRE  |
|  fs-0200c83e16342829c|  1:10:00            |  gjiizbmv |  USAWSC201-projectscratch-00000001  |  271200          |  50         |  LUSTRE  |
|  fs-00eb435abffd1efb5|  1:10:00            |  es5yrbmv |  USAWSC201-project-00000002         |  19200           |  50         |  LUSTRE  |
|  fs-0528940d151a3f123|  1:10:00            |  rdqyvbmv |  USAWSC201-project-00000003         |  62400           |  50         |  LUSTRE  |
|  fs-04c01eb6e0e987179|  1:10:00            |  34mj3bmv |  USAWSC201-projectscratch-00000002  |  69600           |  50         |  LUSTRE  |
|  fs-0c2857e73cc66a394|  1:10:00            |  4izz5bmv |  USAWSC201-project-00000004         |  12000           |  50         |  LUSTRE  |
|  fs-0abf65fbc91abe1d7|  1:10:00            |  taej5bmv |  USAWSC201-project-00000005         |  21600           |  50         |  LUSTRE  |
|  fs-0f4b0785b8ba46fe2|  1:10:00            |  i4cz5bmv |  USAWSC201-project-00000006         |  26400           |  50         |  LUSTRE  |
|  fs-039288c689e53ce3f|  1:10:00            |  f6t63bmv |  USAWSC201-project-00000007         |  38400           |  50         |  LUSTRE  |
|  fs-0d7c4334f6e7d9f5d|  1:10:00            |  kxwo3bmv |  USAWSC201-project-00000008         |  26400           |  50         |  LUSTRE  |
|  fs-0038f6d384178f8e1|  1:10:00            |  xdoo3bmv |  USAWSC201-project-00000009         |  36000           |  50         |  LUSTRE  |
|  fs-058b891a76555eca1|  1:10:00            |  h4do7bmv |  USAWSC201-project-00000010         |  19200           |  50         |  LUSTRE  |
|  fs-051b7dcf73f4f56a3|  1:10:00            |  g5ootbmv |  USAWSC201-projectscratch-00000003  |  9600            |  50         |  LUSTRE  |
|  fs-0a6f6aadfb04509b8|  1:10:00            |  7ig6pbmv |  USAWSC201-project-00000011         |  12000           |  50         |  LUSTRE  |
|  fs-0b4ad830925677665|  1:10:00            |  k5445bmv |  USAWSC201-project-00000012         |  36000           |  50         |  LUSTRE  |
|  fs-0f2fe5cee39317959|  1:10:00            |  mjfmrbmv |  USAWSC201-project-00000013         |  36000           |  50         |  LUSTRE  |
|  fs-06a5a1ceed32f752f|  1:10:00            |  eiqmxbmv |  USAWSC201-projectscratch-00000004  |  12000           |  50         |  LUSTRE  |
|  fs-0531244d4f7d1e22a|  1:10:00            |  zas4xbmv |  USAWSC201-project-00000014         |  55200           |  50         |  LUSTRE  |
|  fs-09a97856106e7c257|  1:10:00            |  mu4mxbmv |  USAWSC201-project-00000015         |  19200           |  50         |  LUSTRE  |
|  fs-0269acd9e3fac5a60|  1:10:00            |  6m54xbmv |  USAWSC201-project-00000016         |  12000           |  50         |  LUSTRE  |
|  fs-0f5960dc8556a3a96|  1:10:00            |  gu5mxbmv |  USAWSC201-userhome-00000001        |  9600            |  50         |  LUSTRE  |
|  fs-0bd931c64d0ff7363|  1:10:00            |  xa5mxbmv |  USAWSC201-userscratch-00000001     |  1200            |  50         |  LUSTRE  |
|  fs-0e909a96775f2a4da|  1:10:00            |  tyg4xbmv |  USAWSC201-projectscratch-00000001  |  1200            |  50         |  LUSTRE  |
|  fs-0b837a7156287f591|  1:10:00            |  v4gmxbmv |  USAWSC201-projectscratch-00000002  |  9600            |  50         |  LUSTRE  |
|  fs-004bfa8b9c73fa3d0|  1:10:00            |  qigmxbmv |  USAWSC201-project-00000017         |  12000           |  50         |  LUSTRE  |
|  fs-053353f7decc28598|  1:10:00            |  pymmxbmv |  USAWSC201-project-00000018         |  12000           |  50         |  LUSTRE  |
|  fs-0e65e30e1e2e2cf73|  1:10:00            |  rqo4xbmv |  USAWSC201-project-00000019         |  12000           |  50         |  LUSTRE  |
|  fs-0d9c2de794f9d0f5e|  1:10:00            |  xuomxbmv |  USAWSC201-project-00000020         |  12000           |  50         |  LUSTRE  |
|  fs-0edb070f42c297dcf|  1:10:00            |  ryp4xbmv |  USAWSC201-project-00000021         |  19200           |  50         |  LUSTRE  |
|  fs-0617299ae872ada3a|  1:10:00            |  rqj4xbmv |  USAWSC201-project-00000022         |  43200           |  50         |  LUSTRE  |
|  fs-0888dc938e959c727|  1:10:00            |  sfn4xbmv |  USAWSC201-projectscratch-00000005  |  9600            |  50         |  LUSTRE  |
|  fs-0542d9faf979c7e39|  1:10:00            |  x2m4xbmv |  USAWSC201-project-00000023         |  19200           |  50         |  LUSTRE  |
|  fs-0882eea6cb1323137|  1:10:00            |  5mimlbmv |  USAWSC201-project-00000024         |  12000           |  50         |  LUSTRE  |
|  fs-05b0c605bfd4d99f5|  1:10:00            |  en7mlbmv |  USAWSC201-project-00000025         |  12000           |  50         |  LUSTRE  |
|  fs-0704d05c55989a72c|  1:10:00            |  uhnmlbmv |  USAWSC201-project-00000026         |  12000           |  50         |  LUSTRE  |
|  fs-0e5344966a71dc67a|  1:10:00            |  wgo4nbmv |  USAWSC201-project-00000027         |  26400           |  50         |  LUSTRE  |
|  fs-0bc30bf7efc6a6cd6|  1:10:00            |  3gomnbmv |  USAWSC201-project-00000028         |  12000           |  50         |  LUSTRE  |
|  fs-0b6015847cad2a3d8|  1:10:00            |  dlgmnbmv |  USAWSC201-project-00000029         |  33600           |  50         |  LUSTRE  |
|  fs-0a7765c981e8c5f8c|  1:10:00            |  64r4fbmv |  USAWSC201-project-00000030         |  12000           |  50         |  LUSTRE  |
|  fs-0425eb5893281e047|  1:10:00            |  tm255bmv |  USAWSC201-project-00000031         |  19200           |  50         |  LUSTRE  |
|  fs-02e3667179daef6d7|  1:10:00            |  l765rbmv |  USAWSC201-project-00000032         |  12000           |  50         |  LUSTRE  |
|  fs-0c22e7a652613cf80|  6:21:00            |  kpoczbev |  USAWSC201-project-00000033         |  12000           |  50         |  LUSTRE  |
|  fs-0d115083c345f282f|  6:21:00            |  h3jszbev |  USAWSC201-project-00000034         |  12000           |  50         |  LUSTRE  |
|  fs-0451d3423e8a3effd|  1:10:00            |  6yus3bev |  USAWSC201-project-00000035         |  12000           |  50         |  LUSTRE  |
+----------------------+---------------------+-----------+-------------------------------------+------------------+-------------+----------+

(awscliv2) $ aws fsx describe-file-systems --query "FileSystems[?FileSystemType=='LUSTRE']| reverse(sort_by(@, &LustreConfiguration.PerUnitStorageThroughput))[].{Name:Tags[?Key=='Name']|[0].Value, Storagecapacity:StorageCapacity,FS_ID:FileSystemId,Type:FileSystemType, Mount:LustreConfiguration.MountName, Throughput:LustreConfiguration.PerUnitStorageThroughput, Maintainancewindow:LustreConfiguration.WeeklyMaintenanceStartTime}" --profile phx --output table --no-cli-pager

(awscliv2) $ aws fsx describe-file-systems --query 'FileSystems[?StorageCapacity >=`12000` && FileSystemType==`ONTAP` ].{FileSystemType: FileSystemType, StorageCapacity: StorageCapacity}' --profile phx --output table
---------------------------------------
|         DescribeFileSystems         |
+-----------------+-------------------+
| FileSystemType  |  StorageCapacity  |
+-----------------+-------------------+
|  ONTAP          |  153600           |
|  ONTAP          |  153600           |
+-----------------+-------------------+

(awscliv2) $ aws fsx describe-file-systems --query 'FileSystems[?StorageCapacity >=`12000` && FileSystemType==`LUSTRE` ].{FileSystemType: FileSystemType, StorageCapacity: StorageCapacity}' --profile phx --output table
---------------------------------------
|         DescribeFileSystems         |
+-----------------+-------------------+
| FileSystemType  |  StorageCapacity  |
+-----------------+-------------------+
|  LUSTRE         |  74400            |
|  LUSTRE         |  249600           |
|  LUSTRE         |  12000            |
|  LUSTRE         |  12000            |
+-----------------+-------------------+

(awscliv2) $ aws fsx describe-file-systems --query 'FileSystems[?StorageCapacity >`25000` && FileSystemType==`LUSTRE`]|reverse(sort_by(@, &StorageCapacity))[].{Name:Tags[?Key==`Name`]|[0].Value,FileSystemType: FileSystemType, StorageCapacity: StorageCapacity, FS_ID:FileSystemId, Mount:LustreConfiguration.MountName, Throughput:LustreConfiguration.PerUnitStorageThroughput, Maintainancewindow:LustreConfiguration.WeeklyMaintenanceStartTime}' --profile phx --output table --no-cli-pager
----------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                DescribeFileSystems                                                               |
+----------------------+-----------------+---------------------+-----------+-------------------------------------+------------------+--------------+
|         FS_ID        | FileSystemType  | Maintainancewindow  |   Mount   |                Name                 | StorageCapacity  | Throughput   |
+----------------------+-----------------+---------------------+-----------+-------------------------------------+------------------+--------------+
|  fs-0200c83e16342829c|  LUSTRE         |  1:10:00            |  gjiizbmv |  USAWSC201-projectscratch-00000001  |  271200          |  50          |
|  fs-093d61e8fca63f65c|  LUSTRE         |  1:10:00            |  s3a3fbmv |  USAWSC201-tools-00000001           |  249600          |  200         |
|  fs-01ef43bb9188b0911|  LUSTRE         |  1:10:00            |  jg63fbmv |  USAWSC201-dscache-00000001         |  74400           |  50          |
|  fs-04c01eb6e0e987179|  LUSTRE         |  1:10:00            |  34mj3bmv |  USAWSC201-projectscratch-00000002  |  69600           |  50          |
|  fs-0528940d151a3f123|  LUSTRE         |  1:10:00            |  rdqyvbmv |  USAWSC201-project-00000003         |  62400           |  50          |
|  fs-0531244d4f7d1e22a|  LUSTRE         |  1:10:00            |  zas4xbmv |  USAWSC201-project-00000014         |  55200           |  50          |
|  fs-0617299ae872ada3a|  LUSTRE         |  1:10:00            |  rqj4xbmv |  USAWSC201-project-00000022         |  43200           |  50          |
|  fs-039288c689e53ce3f|  LUSTRE         |  1:10:00            |  f6t63bmv |  USAWSC201-project-00000007         |  38400           |  50          |
|  fs-0f2fe5cee39317959|  LUSTRE         |  1:10:00            |  mjfmrbmv |  USAWSC201-project-00000013         |  36000           |  50          |
|  fs-0b4ad830925677665|  LUSTRE         |  1:10:00            |  k5445bmv |  USAWSC201-project-00000012         |  36000           |  50          |
|  fs-0038f6d384178f8e1|  LUSTRE         |  1:10:00            |  xdoo3bmv |  USAWSC201-project-00000009         |  36000           |  50          |
|  fs-0b6015847cad2a3d8|  LUSTRE         |  1:10:00            |  dlgmnbmv |  USAWSC201-project-00000029         |  33600           |  50          |
|  fs-0e5344966a71dc67a|  LUSTRE         |  1:10:00            |  wgo4nbmv |  USAWSC201-project-00000027         |  26400           |  50          |
|  fs-0d7c4334f6e7d9f5d|  LUSTRE         |  1:10:00            |  kxwo3bmv |  USAWSC201-project-00000008         |  26400           |  50          |
|  fs-0f4b0785b8ba46fe2|  LUSTRE         |  1:10:00            |  i4cz5bmv |  USAWSC201-project-00000006         |  26400           |  50          |
+----------------------+-----------------+---------------------+-----------+-------------------------------------+------------------+--------------+


https://www.stuartellis.name/articles/aws-cli/
https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-parameters-quoting-strings.html

https://github.com/LeeroyHannigan/aws-cloudformation-user-guide/tree/main/doc_source

(awscliv2) $ aws backup list-recovery-points-by-backup-vault --backup-vault-name stor-fsx-backup-vault --query 'RecoveryPoints[*].{RecoveryPointArn: RecoveryPointArn, BackupVaultName: BackupVaultName, ResourceType: ResourceType, IamRoleArn: IamRoleArn, Status: Status, Lifecycle: Lifecycle.DeleteAfterDays, Encryption: IsEncrypted}' --profile dev --output table
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                                                  ListRecoveryPointsByBackupVault                                                                                                 |
+-----------------------+-------------+---------------------------------------------------------------------------+------------+----------------------------------------------------------------------+---------------+------------+
|    BackupVaultName    | Encryption  |                                IamRoleArn                                 | Lifecycle  |                          RecoveryPointArn                            | ResourceType  |  Status    |
+-----------------------+-------------+---------------------------------------------------------------------------+------------+----------------------------------------------------------------------+---------------+------------+
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-0825165a1f802d7ec  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-009e9cc630278bb48  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-0fa4b78c349152759  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-0afeb97a6d8d34459  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-02c15dd845ba030f0  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-04f59564ea2e8a0bc  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-0bd5e7bcefb18838c  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-07a92c5231b81952d  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-03ad64581953ad5cb  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-0fb7ae53c9c11c467  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-062d1f24bfab6827f  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-038f01a861d278c40  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-0631c88129ebfa570  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-08c105162905ef124  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-0c4ebab916d8d9f6c  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-08b41f3490950e8ad  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-0f7d82721a0250f6d  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-050a8a0ae7254e76f  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-068e9550edc3feae0  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-0555bf71532e5c0d1  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-0189e3e27ac62e624  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-066298935dfbb04c6  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-0fade04f1251f975f  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-0e99724229ed1c999  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-042b9326b02d9a050  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-0abf1d797bb5a5f28  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-072b5aa012e8b5c3e  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/stor-fsx-backup-role                      |  7         |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-09fdd2fd4ae8646eb  |  FSx          |  COMPLETED |
|  stor-fsx-backup-vault|  True       |  arn:aws:iam::356906773483:role/service-role/AWSBackupDefaultServiceRole  |  14        |  arn:aws:fsx:eu-west-1:356906773483:backup/backup-069ded14866854661  |  FSx          |  COMPLETED |
+-----------------------+-------------+---------------------------------------------------------------------------+------------+----------------------------------------------------------------------+---------------+------------+



(awscliv2) $ aws ec2 describe-instances --query 'Reservations[].Instances[].[PrivateIpAddress,InstanceId,InstanceType,LaunchTime,Tags[?Key==`Name`]| [0].Value] | sort_by(@, &[4]) ' --output table --profile dev
-----------------------------------------------------------------------------------------------------------------------------------------------
|                                                              DescribeInstances                                                              |
+--------------+----------------------+-------------+----------------------------+------------------------------------------------------------+
|  10.28.64.72 |  i-0c9e1155fe0105ed6 |  m5.xlarge  |  2022-07-12T03:31:17+00:00 |  CloudVolumeOntap-Restore                                  |
|  10.28.65.12 |  i-0a4209dfc5774a2ea |  t3.xlarge  |  2022-08-08T10:05:04+00:00 |  NetApp Cloud Manager                                      |
|  10.28.64.13 |  i-0cb02b3c973b77bf6 |  t2.medium  |  2022-10-18T11:10:28+00:00 |  nxp80287_docker_build                                     |
|  10.28.66.13 |  i-03b9a2b946be51127 |  c6i.large  |  2022-12-22T12:49:14+00:00 |  stvt101-storage-management-01.nxdi-dev.ie-awsc1.nxp.com   |
|  10.28.66.28 |  i-0f1baa88774a3ac9d |  c6i.large  |  2022-12-22T12:49:14+00:00 |  stvt101-storage-management-02.nxdi-dev.ie-awsc1.nxp.com   |
|  10.28.67.143|  i-0327cf04986086711 |  c6i.large  |  2022-12-22T12:49:14+00:00 |  stvt101-storage-migration-01.nxdi-dev.ie-awsc1.nxp.com    |
|  10.28.64.193|  i-0e9e36308d1dad996 |  c6i.large  |  2022-08-16T14:38:03+00:00 |  stvw101-storage-management-01.nxdi-dev.ie-awsc1.nxp.com   |
|  10.28.65.63 |  i-0bf8c4933a451c3a9 |  c6i.large  |  2022-08-16T14:38:04+00:00 |  stvw101-storage-management-02.nxdi-dev.ie-awsc1.nxp.com   |
|  10.28.65.166|  i-0f57b147ea9124344 |  c6i.xlarge |  2022-08-23T11:13:26+00:00 |  stvw101-storage-test001.nxdi-dev.ie-awsc1.nxp.com         |
|  10.28.65.47 |  i-09379cb842ed015f2 |  t2.small   |  2022-06-24T05:31:55+00:00 |  test_Sriman                                               |
|  10.28.65.17 |  i-02e4cbcbe10cb5e79 |  t1.micro   |  2022-11-24T11:01:22+00:00 |  test_fsx                                                  |
|  10.28.65.106|  i-0d7aca605032e6ff3 |  t4g.small  |  2022-07-13T13:38:19+00:00 |  test_hrvoje                                               |
+--------------+----------------------+-------------+----------------------------+------------------------------------------------------------+

(awscliv2) $ aws fsx describe-volumes --query 'Volumes[?OntapConfiguration.SizeInMegabytes >`1536000`].{ VolumeName:Name, FSID:FileSystemId, SVMID:OntapConfiguration.StorageVirtualMachineId, VolumeId:VolumeId, Size:OntapConfiguration.SizeInMegabytes, JunctionPath:OntapConfiguration.JunctionPath, Type:OntapConfiguration.OntapVolumeType }|reverse(sort_by(@, &Size))' --output table --profile dev --no-cli-pager
-------------------------------------------------------------------------------------------------------------------------------------------
|                                                             DescribeVolumes                                                             |
+----------------------+--------------------+------------------------+-----------+-------+---------------------------+--------------------+
|         FSID         |   JunctionPath     |         SVMID          |   Size    | Type  |         VolumeId          |    VolumeName      |
+----------------------+--------------------+------------------------+-----------+-------+---------------------------+--------------------+
|  fs-09cd3a383479d3d5c|  /userscratch_0000 |  svm-0ebc9e2ed2f6dd532 |  12281856 |  RW   |  fsvol-09dbaefbc013418c5  |  userscratch_0000  |
|  fs-06ce8e1172d6cab4e|  /userscratch_0000 |  svm-09743f8272f0e29cc |  12281856 |  RW   |  fsvol-0023f239f7cf9396d  |  userscratch_0000  |
|  fs-0d9a202f6ea248359|  /userscratch_0000 |  svm-000c1de422a6b414e |  9517056  |  RW   |  fsvol-0382d5abb37a4c417  |  userscratch_0000  |
|  fs-0d9a202f6ea248359|  /userscratch_0001 |  svm-000c1de422a6b414e |  6144000  |  RW   |  fsvol-0edf546643939fc21  |  userscratch_0001  |
|  fs-023d78d53f61e0ea6|  /etx              |  svm-07e3b9e055e0b6f4b |  2457600  |  RW   |  fsvol-09945d83c0d9409a9  |  etx               |
|  fs-0c3eda9976da35490|  /etx              |  svm-003b50595b37bfeef |  2457600  |  RW   |  fsvol-0a8083465e8720d1e  |  etx               |
|  fs-09cd3a383479d3d5c|  /userscratch_0001 |  svm-0ebc9e2ed2f6dd532 |  1996800  |  RW   |  fsvol-05b7de39c11c66eb4  |  userscratch_0001  |
|  fs-0f9dfb2cf9d1349ad|  /userhome_0001    |  svm-0e585e69bb06aa9b9 |  1996800  |  RW   |  fsvol-01a4e5f10efa63029  |  userhome_0001     |
|  fs-06ce8e1172d6cab4e|  /userscratch_0001 |  svm-09743f8272f0e29cc |  1689600  |  RW   |  fsvol-0cb5185b4fe979b7e  |  userscratch_0001  |
+----------------------+--------------------+------------------------+-----------+-------+---------------------------+--------------------+
OR
(awscliv2) $ aws fsx describe-volumes --query 'Volumes[?OntapConfiguration.SizeInMegabytes >`1536000`].{ VolumeName:Name, FSID:FileSystemId, SVMID:OntapConfiguration.StorageVirtualMachineId, VolumeId:VolumeId, Size:OntapConfiguration.SizeInMegabytes, JunctionPath:OntapConfiguration.JunctionPath, Type:OntapConfiguration.OntapVolumeType }|reverse(sort_by([], &Size))' --output table --profile dev --no-cli-pager

-----------------------------------------------------------------------------------------------------------------------------------------------------
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-----------------------------------------------------------------------------------------------------------------------------------------------------

 To describe all instances with Tag "NAME" Use:

    aws ec2 describe-instances --filters "Name=tag-key,Values=Name"
or

This Gives InstanceId with Particular Tag "Name"

    aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId, Tags[?Key==`Name`].Value[0]]'
or

This Gives InstanceId with Particular Tag "Name" and Value of Tag

    aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId, Tags[?Key==`Name`], Tags[?Key==`Name`].Value[]]'

To describe all instances with Tag "Purpose" and its value as "test" Use:

    aws ec2 describe-instances --filters "Name=tag:Purpose,Values=test"

If you already know the Instance id:

    aws ec2 describe-instances --instance-ids i-1234567890abcdef0

To find every instance which doesn't contain a tag named "Purpose":

    aws ec2 describe-instances | jq '.Reservations[].Instances[] | select(contains({Tags: [{Key: "Purpose"} ]}) | not)'

To filter against the value of the tag, instead of the name of the tag:

    aws ec2 describe-instances | jq '.Reservations[].Instances[] | select(contains({Tags: [{Key: "Name"}, {Value: "testbox1"}]}) | not)'

To find every instance which doesn't contain a tag:

    aws ec2 describe-instances | jq '.Reservations[].Instances[] | select(contains({Tags: [{Key: ""}, {Value: ""}]}) | not)'
	
    aws ec2 describe-instances --filters "Name=tag:Name,Values=instance_name" | jq .Reservations[0].Instances[0].InstanceId
    
    Download jq::
   https://stedolan.github.io/jq/download/
-----------------------------------------------------------------------------------------------------------------------------------------------------
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-----------------------------------------------------------------------------------------------------------------------------------------------------

(awscliv2) $ aws resourcegroupstaggingapi get-resources --tag-filters "Key=Created_By,Values=Karn Kumar" --query 'ResourceTagMappingList[].{ResourceARN: ResourceARN, Name:Tags[?Key==`Created_By`]|[0].Value}' --output table --profile dev
-------------------------------------------------------------------------------------------------------------------------
|                                                     GetResources                                                      |
+------------+----------------------------------------------------------------------------------------------------------+
|    Name    |                                               ResourceARN                                                |
+------------+----------------------------------------------------------------------------------------------------------+
|  Karn Kumar|  arn:aws:fsx:eu-west-1:356906773483:file-system/fs-0988722292eac6e04                                     |
|  Karn Kumar|  arn:aws:fsx:eu-west-1:356906773483:volume/fs-0af9794f3b2573ead/fsvol-0a4cbe1e6b541a73a                  |
|  Karn Kumar|  arn:aws:fsx:eu-west-1:356906773483:storage-virtual-machine/fs-0af9794f3b2573ead/svm-0524816479dbbe473   |
|  Karn Kumar|  arn:aws:fsx:eu-west-1:356906773483:volume/fs-00b53d85e294370cb/fsvol-092338640bf2bf541                  |
|  Karn Kumar|  arn:aws:fsx:eu-west-1:356906773483:storage-virtual-machine/fs-00b53d85e294370cb/svm-08c5e3580ff41023e   |
|  Karn Kumar|  arn:aws:fsx:eu-west-1:356906773483:file-system/fs-0af9794f3b2573ead                                     |
|  Karn Kumar|  arn:aws:fsx:eu-west-1:356906773483:storage-virtual-machine/fs-0988722292eac6e04/svm-004031d7b663c2946   |
|  Karn Kumar|  arn:aws:fsx:eu-west-1:356906773483:volume/fs-0988722292eac6e04/fsvol-0a6c09bc0c32daac9                  |
+------------+----------------------------------------------------------------------------------------------------------+

(awscliv2) $ aws resourcegroupstaggingapi get-resources --tag-filters "Key=Created_By,Values=Jeroen Dekker" --query 'ResourceTagMappingList[].{ResourceARN: ResourceARN, Name:Tags[?Key==`Created_By`]|[0].Value, Name2: Tags[?Key==`Assigned_Support_Group`]|[0].Value}' --output table --profile dev
--------------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                        GetResources                                                                        |
+---------------+-----------------------------+--------------------------------------------------------------------------------------------------------------+
|     Name      |            Name2            |                                                 ResourceARN                                                  |
+---------------+-----------------------------+--------------------------------------------------------------------------------------------------------------+
|  Jeroen Dekker|  RD-DI-Cloud-Infra-Services |  arn:aws:codebuild:eu-west-1:356906773483:project/hwde-storage-codebuild-cicd-iecsst101-postconfig-project   |
|  Jeroen Dekker|  RD-DI-Cloud-Infra-Services |  arn:aws:codebuild:eu-west-1:356906773483:project/hwde-storage-codebuild-cicd-ieawsc101-postconfig-project   |
|  Jeroen Dekker|  RD-DI-Cloud-Infra-Services |  arn:aws:lambda:eu-west-1:356906773483:function:hwde-storage-lambda-cicd-iecsst101-cfn-check-function        |
|  Jeroen Dekker|  RD-DI-Cloud-Infra-Services |  arn:aws:lambda:eu-west-1:356906773483:function:hwde-storage-lambda-cicd-ieawsc101-cfn-check-function        |
|  Jeroen Dekker|  RD-DI-Cloud-Infra-Services |  arn:aws:ec2:eu-west-1:356906773483:security-group/sg-02527fcac4c785ed6                                      |
|  Jeroen Dekker|  RD-DI-Cloud-Infra-Services |  arn:aws:ec2:eu-west-1:356906773483:security-group/sg-080e8e3e5dcbfc5c2                                      |
+---------------+-----------------------------+--------------------------------------------------------------------------------------------------------------+

-----------------------------------------------------------------------------------------------------------------------------------------------------
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-----------------------------------------------------------------------------------------------------------------------------------------------------

To create a resource with the AWS CLI and specify tags, you can use the --tags option. This option takes a list of tags in the form Key=Value. You can specify multiple tags by separating them with a space.
Here's an example of how to use the --tags option to create an Amazon EC2 instance with the AWS CLI:


$ aws ec2 run-instances --image-id ami-12345678 --instance-type t2.micro --key-name MyKeyPair --security-group-ids sg-12345678 --subnet-id subnet-12345678 --tags Key=Environment,Value=Production Key=Application,Value=MyApp

This command will create an EC2 instance with the specified AMI ID, instance type, key pair, security group, and subnet, and it will also apply the tags Environment=Production and Application=MyApp to the instance.
You can also specify tags when creating other resource types with the AWS CLI, such as Amazon S3 buckets, Amazon RDS databases, and so on. The syntax for specifying tags is the same for all resource types.
For more information about using tags with the AWS CLI, you can refer to the AWS CLI documentation.


You can use the --tags option to specify key-value pairs to assign as tags to the resource that you are creating. The --tags option takes a list of strings in the format Key=Value, and you can specify multiple key-value pairs by separating them with a comma.

Here is an example of using the --tags option to create an Amazon Elastic Compute Cloud (Amazon EC2) instance with the AWS CLI:

aws ec2 run-instances \
    --image-id ami-01234567890abcdef \
    --instance-type t2.micro \
    --key-name MyKeyPair \
    --security-group-ids sg-01234567890abcdef \
    --subnet-id subnet-01234567890abcdef \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyInstance},{Key=Environment,Value=Production}]'

In this example, the --tag-specifications option is used to specify two tags for the instance: one with the key Name and the value MyInstance, and another with the key Environment and the value Production.

Note that the --tags option is supported by many AWS resources and services, but the exact syntax and usage may vary depending on the specific resource or service. Consult the AWS CLI documentation or the documentation for the specific resource or service you are working with for more information.
-----------------------------------------------------------------------------------------------------------------------------------------------------
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-----------------------------------------------------------------------------------------------------------------------------------------------------

(awscliv2) $ aws ec2 describe-security-groups --query "SecurityGroups[*].{GroupId:GroupId,GroupName:GroupName,Description:Description}" --profile dev --output table
-----------------------------------------------------------------------------------------------------------------------------------------------
|                                                           DescribeSecurityGroups                                                            |
+--------------------------------------------------------+-----------------------+------------------------------------------------------------+
|                       Description                      |        GroupId        |                         GroupName                          |
+--------------------------------------------------------+-----------------------+------------------------------------------------------------+
|  Security Group for EC2 Storage Mgt Servers            |  sg-0bc431c9204376514 |  EC2 - IEAWSC101                                           |
|  Fsx Ontap POC testing                                 |  sg-06f3acb8f5fd4f17c |  POC-Fsx-Ontap                                             |
|  launch-wizard-1 created 2022-06-24T11:00:54.388+05:30 |  sg-0017e5e23c3d9a182 |  launch-wizard-1                                           |
|  Security Group for FSx for ONTAP based filesystems    |  sg-05a939192e558f915 |  FSx for ONTAP - IECSSD102                                 |
|  Security Group for FSx for Lustre based filesystems   |  sg-0c212b67657ecf6b3 |  FSx for Lustre - IECSSD102                                |
|  launch-wizard-2 created 2022-10-18T11:08:54.026Z      |  sg-04a8525b82f911218 |  launch-wizard-2                                           |
|  Security group for post config AWS CodeBuild          |  sg-080e8e3e5dcbfc5c2 |  hwde-storage-ec2-cicd-ieawsc101-postconfig-codebuild-sgp  |
|  Allowing traffic on port 22 for ssh                   |  sg-09bb7d6663e92ec20 |  stvw101-storage-test001.nxdi-dev.ie-awsc1.nxp.com-nsg     |
|  Security Group for EC2 Storage Mgt Servers            |  sg-01c3e812b1ecc6402 |  EC2 - IECSSD102                                           |
|  Security Group for FSx for Lustre based filesystems   |  sg-0e6470a165fbe1d9f |  FSx for Lustre - IEAWSC101                                |
|  ONTAP                                                 |  sg-009da235754859a44 |  ontap-test                                                |
|  Security Group for FSx for ONTAP based filesystems    |  sg-0dfd60f391ea93d2e |  FSx for ONTAP - IECSST101                                 |
|  Security Group for FSx for Lustre based filesystems   |  sg-0a95b3f91b16d8e34 |  FSx for Lustre - IECSST101                                |
|  No access SG for testing.                             |  sg-01a8f169c4a9ea535 |  no_access_sg                                              |
|  Security Group for EC2 Storage Mgt Servers            |  sg-0a56cbc49626e7dcf |  EC2 - IECSST101                                           |
|  Security Group for FSx for OpenZFS based filesystems  |  sg-0ec3ef780a1b4ebd9 |  FSx for OpenZFS - IEAWSC101                               |
|  Security Group for FSx for OpenZFS based filesystems  |  sg-04bab2d50329e6d5d |  FSx for OpenZFS - IECSSD102                               |
|  Security Group for FSx for ONTAP based filesystems    |  sg-02639ab88a5b819d1 |  FSx for ONTAP - IEAWSC101                                 |
|  Security group for post config AWS CodeBuild          |  sg-02527fcac4c785ed6 |  hwde-storage-ec2-cicd-iecsst101-postconfig-codebuild-sgp  |
|  Lustre ports                                          |  sg-00288b4a893ebe3ce |  FSx for Lustre - IECSST101 - not in a stack               |
|  Security Group for FSx for OpenZFS based filesystems  |  sg-00aa2c5a36ffc6ba4 |  FSx for OpenZFS - IECSST101                               |
|  security group for fsx lustre test                    |  sg-00a948a7ac4606a89 |  Lustre                                                    |
|  Security Group for DataSync task - ONTAP to Lustre    |  sg-0de9f23680d9102d6 |  ontap-lustre-sg-eu-west-1                                 |
+--------------------------------------------------------+-----------------------+------------------------------------------------------------+

-----------------------------------------------------------------------------------------------------------------------------------------------------
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-----------------------------------------------------------------------------------------------------------------------------------------------------
(awscliv2) $ aws ec2 describe-security-groups --filters "Name=tag-value,Values=*SecGrp*" --query 'SecurityGroups[*].{GroupId:GroupId,VpcId:VpcId}' --output table --profile dev
---------------------------------------------------
|             DescribeSecurityGroups              |
+-----------------------+-------------------------+
|        GroupId        |          VpcId          |
+-----------------------+-------------------------+
|  sg-0bc431c9204376514 |  vpc-045f870a38a7aed6c  |
|  sg-05a939192e558f915 |  vpc-045f870a38a7aed6c  |
|  sg-0c212b67657ecf6b3 |  vpc-045f870a38a7aed6c  |
|  sg-080e8e3e5dcbfc5c2 |  vpc-045f870a38a7aed6c  |
|  sg-01c3e812b1ecc6402 |  vpc-045f870a38a7aed6c  |
|  sg-0e6470a165fbe1d9f |  vpc-045f870a38a7aed6c  |
|  sg-0dfd60f391ea93d2e |  vpc-045f870a38a7aed6c  |
|  sg-0a95b3f91b16d8e34 |  vpc-045f870a38a7aed6c  |
|  sg-0a56cbc49626e7dcf |  vpc-045f870a38a7aed6c  |
|  sg-0ec3ef780a1b4ebd9 |  vpc-045f870a38a7aed6c  |
|  sg-04bab2d50329e6d5d |  vpc-045f870a38a7aed6c  |
|  sg-02639ab88a5b819d1 |  vpc-045f870a38a7aed6c  |
|  sg-02527fcac4c785ed6 |  vpc-045f870a38a7aed6c  |
|  sg-00aa2c5a36ffc6ba4 |  vpc-045f870a38a7aed6c  |
+-----------------------+-------------------------+


-----------------------------------------------------------------------------------------------------------------------------------------------------
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-----------------------------------------------------------------------------------------------------------------------------------------------------
(awscliv2) $ aws ec2 describe-security-groups --filters Name=tag-key,Values="*" --query 'SecurityGroups[*].Tags[?contains(Value, `SecGrp`)][].{Key: Key, Value: Value}' --profile dev

(awscliv2) $ aws ec2 describe-security-groups --filters Name=tag-key,Values="*" --query 'SecurityGroups[*].Tags[?contains(Value, `SecGrp`)][].{Key: Key, Value: Value}' --profile dev  --output table
-----------------------------------------------------------------------
|                       DescribeSecurityGroups                        |
+--------------------------------+------------------------------------+
|               Key              |               Value                |
+--------------------------------+------------------------------------+
|  aws:cloudformation:logical-id |  IEAWSC101SecGrpec2                |
|  aws:cloudformation:logical-id |  IECSSD102SecGrpfsxontap           |
|  aws:cloudformation:logical-id |  IECSSD102SecGrpfsxlustre          |
|  aws:cloudformation:logical-id |  HWDESecGrpPostConfigAWSCodeBuild  |
|  aws:cloudformation:logical-id |  IECSSD102SecGrpec2                |
|  aws:cloudformation:logical-id |  IEAWSC101SecGrpfsxlustre          |
|  aws:cloudformation:logical-id |  IECSST101SecGrpfsxontap           |
|  aws:cloudformation:logical-id |  IECSST101SecGrpfsxlustre          |
|  aws:cloudformation:logical-id |  IECSST101SecGrpec2                |
|  aws:cloudformation:logical-id |  IEAWSC101SecGrpfsxopenzfs         |
|  aws:cloudformation:logical-id |  IECSSD102SecGrpfsxopenzfs         |
|  aws:cloudformation:logical-id |  IEAWSC101SecGrpfsxontap           |
|  aws:cloudformation:logical-id |  HWDESecGrpPostConfigAWSCodeBuild  |
|  aws:cloudformation:logical-id |  IECSST101SecGrpfsxopenzfs         |
+--------------------------------+------------------------------------+


https://gist.github.com/magnetikonline/6a382a4c4412bbb68e33e137b9a74168
https://www.w3schools.com/aws
-----------------------------------------------------------------------------------------------------------------------------------------------------
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-----------------------------------------------------------------------------------------------------------------------------------------------------
Find Tag and Private IP for given Instance-Id::

(awscliv2) $ aws ec2 describe-instances --instance-id=i-0f57b147ea9124344 --query='Reservations[].Instances[].[PrivateIpAddress,Tags[?Key==`Name`]|[0].Value]' --out text --pro dev
10.28.65.166    stvw101-storage-test001.nxdi-dev.ie-awsc1.nxp.com


List unassigned volumes::
(awscliv2) $ aws ec2 describe-volumes  --filters Name=status,Values=available --query 'Volumes[*].{a1:VolumeId,b2:AvailabilityZone,c3:Tags[?Key==`Name`]|[0].Value}' --pro dev --out table
-------------------------------------------------
|                DescribeVolumes                |
+------------------------+--------------+-------+
|           a1           |     b2       |  c3   |
+------------------------+--------------+-------+
|  vol-0252c38cba0f4373c |  eu-west-1a  |  None |
|  vol-0c505e55ec2133e9e |  eu-west-1a  |  None |
+------------------------+--------------+-------+
http://bruxy.regnet.cz/web/programming/EN/awscli/
-----------------------------------------------------------------------------------------------------------------------------------------------------
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-----------------------------------------------------------------------------------------------------------------------------------------------------

JSON to YAML:: https://www.json2yaml.com/
-----------------------------------------------------------------------------------------------------------------------------------------------------
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-----------------------------------------------------------------------------------------------------------------------------------------------------
Enable aDAdvanced Enterprize Deatures While Saving over 50% With FSx ONTAP iSCI Block Serviuce:
CVO = Cloud Volume ONTAP 

SAZ(Single Availability Zone):: 
MAZ(Multi-Availability Zone)::  
-----------------------------------------------------------------------------------------------------------------------------------------------------
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-----------------------------------------------------------------------------------------------------------------------------------------------------
aws fsx describe-file-systems --query "FileSystems[].{ id: FileSystemId, type: FileSystemType, size_g: StorageCapacity, ip: OntapConfiguration.Endpoints.Management.IpAddresses[0], name: (Tags[?Key=='Name'].Value)[0], lifecycle: Lifecycle }" --profile mde fsx --output table
aws fsx describe-file-systems --query "FileSystems[].{ id: FileSystemId, type: FileSystemType, size_g: StorageCapacity, ip: OntapConfiguration.Endpoints.Management.IpAddresses[0], name: (Tags[?Key=='Name'].Value)[0], lifecycle: Lifecycle }" --profile mde fsx --output table
aws codepipeline start-pipeline-execution --name pipeline-356906773483-NxDIDevOpsPipeline-1G510F6G89IMD --profile dev 

for fsid in $(development_work_area/aws-cli-scripts/fsx-fs-detailsGlobal.sh phx|awk '/stcl/{print $1}');do  echo "++++ $fsid ++++";aws fsx update-file-system --file-system-id "$fsid"  --ontap-configuration ThroughputCapacity=512 --profile phx;done

for fsid in $(development_work_area/aws-cli-scripts/fsx-fs-detailsGlobal.sh phx|awk '/ONTAP/{print $1}'|grep -v "fs-0bb890bd2a272c090");
do  
aws fsx update-file-system --file-system-id "$fsid" --ontap-configuration ThroughputCapacity=256 --profile phx;
done


