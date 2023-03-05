# Check the Status of AWS Backup
#!/bin/bash

email_subject="Running Backup Jobs status of offline disk"
# Run the aws backup command for each line in boid_file
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

# Send an email if there are jobs with PercentDone > 0.0
if [[ -s /tmp/email_body ]]; then
    # Generate the HTML table
    table_html=$(printf "<table><tr><th>Backup Job ID</th><th>State</th><th>Percent Done</th><th>Resource Name</th></tr>")
    while read line; do
        row_html=$(printf "<tr>")
        columns=($line)
        for col in "${columns[@]}"; do
            row_html=$(printf "%s<td>%s</td>" "$row_html" "$col")
        done
        row_html=$(printf "%s</tr>" "$row_html")
        table_html=$(printf "%s%s" "$table_html" "$row_html")
    done < /tmp/email_body
    table_html=$(printf "%s</table>" "$table_html")

    # Add the HTML table to the email body and send the email
    (cat << EOM
To: some.emailaddress@example.com
From: backupChkr@example.com
Subject: $email_subject
Mime-Version: 1.0
Content-type: text/html

<html>
<head>
<style>
table {
  border-collapse: collapse;
  width: 60%; /* set the column width to auto to adjust it dynamically */
}
td, th {
  border: 1px solid #dddddd;
  text-align: left;
  padding: 5px; /* increase or decrease the padding as per your requirement */
}
th {
  background-color: #dddddd;
 font-weight: bold; /* make the header cells bold */
}
</style>
</head>
<body>
<p>Dear Team,<br><br> Please find offline Backup report below .</p>
$table_html
<br></br>
Sincerely,<br>
Backup Team.
</body>
</html>
EOM
) | /usr/sbin/sendmail -t

    rm /tmp/email_body
fi
