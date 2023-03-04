# Delete DynamoDB Backup Job

This script is used to delete a backup job from a DynamoDB table.

## Usage

The script can be used in the following ways:

- To delete a backup job by providing the BackupJobId and BackupJobArn values as arguments:


- To delete a backup job by providing a file containing the BackupJobId and BackupJobArn values:


## Script Explanation

This script performs the following tasks:

1. Defines a function called "display_help" to display the usage of the script.
2. Defines a function called "delete_items" to delete the items from the DynamoDB table based on the BackupJobId and BackupJobArn values.
3. Checks if the user provided any arguments. If no arguments are provided, the "display_help" function is called and the script exits with an error code of 1.
4. Checks if the user provided the "--help" or "-h" argument. If either argument is provided, the "display_help" function is called and the script exits with a successful code of 0.
5. If a file name and the BackupJobId and BackupJobArn values are provided as arguments, the script creates a new file named "jobid_jobarn" and writes the BackupJobId and BackupJobArn values to it.
6. If the "jobid_jobarn" file exists, the "delete_items" function is called with the "jobid_jobarn" file name as the argument to delete the items from the DynamoDB table.
7. If the "jobid_jobarn" file does not exist, the script extracts the BackupJobId and BackupJobArn values from the second argument by using the "cut" command. It then calls the "aws" command to delete the item from the DynamoDB table based on these values.
