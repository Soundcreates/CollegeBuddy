import re
import os

file_path = '/home/shantanav/code/self-projects/Somaiya_ext/backend/service/data.go'

try:
    with open(file_path, 'r') as f:
        content = f.read()

    # Extract strings inside double quotes
    # The regex r'"(.*?)"' captures the content inside the quotes
    matches = re.findall(r'"(.*?)"', content)

    # Deduplicate while preserving order
    unique_emails = []
    seen = set()
    for email in matches:
        if email not in seen:
            unique_emails.append(email)
            seen.add(email)

    # Format into Go file content
    go_content = 'package service\n\n'
    go_content += 'var Faculty_mails = []string{\n'
    for email in unique_emails:
        go_content += f'    "{email}",\n'
    go_content += '}\n'

    # Overwrite the file
    with open(file_path, 'w') as f:
        f.write(go_content)

    print(f"Successfully processed {len(unique_emails)} unique emails.")

except Exception as e:
    print(f"Error: {e}")
