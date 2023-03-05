# AWS Backup Check Script based on the Provided JobID's.

This script is used to check the status of AWS backup jobs and send an email notification if there are jobs with PercentDone greater than 0.0. The script uses the AWS CLI tool to retrieve backup job details and filter for relevant fields such as BackupJobId, State, PercentDone, and ResourceName.

The script reads job ids from a file named "job_ids" and for each job id, it gets the backup job details and checks if the PercentDone is greater than 0.0. If it is, then it accumulates the job details into an email body file located at "/tmp/email_body" in a table format.

After processing all the job ids, the script checks if the email body file has any data by checking its size using "-s" option. If it has data, it generates an HTML table from the email body file and sends an email notification using the "sendmail" command.

The email notification contains a table with backup job details such as BackupJobId, State, PercentDone, and ResourceName. The table is formatted using CSS styles to make it more readable. The email also includes a subject, sender, and recipient address.

Here is step-by-step breakdown of the script:

1. Set the email subject as a variable:

  `email_subject="Running Backup Jobs status of offline disk"`

2. Iterate over each line in the file 'job_ids' and execute an AWS Backup command for each job ID:
   
  ```
   while read i; do
    backup_details=$(aws backup describe-backup-job --backup-job-id $i)
    ...
   done < job_ids
  ```

3. Extract relevant fields from the AWS Backup command output using the 'jq' command:

```
backup_job_id=$(echo $backup_details | jq -r '.BackupJobId')
state=$(echo $backup_details | jq -r '.State')
percent_done=$(echo $backup_details | jq -r '.PercentDone')
resource_name=$(echo $backup_details | jq -r '.ResourceName')
```

4. If the backup job has a percentage complete greater than 0, accumulate its details in a temporary file '/tmp/email_body':

```
if (( $(echo "$percent_done > 0.0" | bc -l) )); then
    printf "%-40s %-9s %-9s %-20s\n" "$backup_job_id" "$state" "$percent_done" "$resource_name" >> /tmp/email_body
fi
```

5. If there are any backup jobs with a percentage complete greater than 0, generate an HTML table and email it to the specified recipient:

```
if [[ -s /tmp/email_body ]]; then
    table_html=...
    (cat << EOM
To: some.emailaddress@example.com
From: backupChkr@example.com
Subject: $email_subject
Mime-Version: 1.0
Content-type: text/html
...
EOM
) | /usr/sbin/sendmail -t
    rm /tmp/email_body
fi

```

6. This above block of code reads a list of job ids from a file named `job_ids` and for each `job id`, it gets the backup job details using the AWS CLI command `describe-backup-job`. The details are filtered for relevant fields such as `BackupJobId`, `State`, `PercentDone`, and `ResourceName` using jq command.

The if statement checks if the job has a PercentDone greater than 0.0. If it does, the script accumulates the backup job details into an email body file located at `/tmp/email_body` in a table format using the printf command.



```
while read i; do
    # Get the backup job details and filter for relevant fields
    backup_details=$(aws backup describe-backup-job --backup-job-id $i)
    backup_job_id=$(echo $backup_details | jq -r '.BackupJobId')
    state=$(echo $backup_details | jq -r '.State')
    percent_done=$(echo $backup_details | jq -r '.PercentDone')
    resource_name=$(echo $backup_details | jq -r '.ResourceName')

    # Accumulate the details for jobs with PercentDone > 0.0 into the email body
    if (( $(echo "$percent_done > 0.0" | bc -l) )); then
        echo "Adding backup job $backup_job_id to the email notification"
        # Add the backup job details to the email body in table format
        printf "%-40s %-9s %-9s %-20s\n" "$backup_job_id" "$state" "$percent_done" "$resource_name" >> /tmp/email_body

    fi
done < job_ids
```

7. We need to keep a record file to have `job_ids` that need to be passed to the script as above or you can pass as an argument, below is  how it look like:

```
$ cat job_ids
4d9fe4e0-3f0e-4c3f-9b0c-2a30b0976eb2
8206d1ba-f91f-4e13-ba6b-eb7f78701a22
2f6e9d6b-91b1-44ce-bf0a-10d55c81e60f
07eb6184-88d4-4f78-b186-3c3aa641d330
3b0fdd1a-9cb9-48d2-8c11-d8de32d92b1f
```

8. To run the script if it has been hard-coded within script above.

`$ bash check_backup_status_script.sh`

9. If you want to run the script as an argument in the command-line then you just modify the script and replace `job_ids` with `$1` and run like below..

```
$ check_backup_status_script.sh <file_containing_job_ids>

Example:

$ heck_backup_status_script.sh job_ids
```
10. It will simply run and will send you HTML body atched ion the e-mail.
