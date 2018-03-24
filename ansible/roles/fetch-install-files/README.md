# fetch-install-files

## Purpose of role

This common role fetches a file from a HTTP/FTP server, and copies it to a remote server.

This is useful when you need to push installation files from an internal file servers to a remote server in the DMZ.

## Variables

The role accepts the following variables.

Variable name                     | Mandatory | Example value                                                                            | Default value
--------------------------------- | --------- | ---------------------------------------------------------------------------------------- | -----------------------------
unarchive_dest                    | yes       | /data/SW/was
owner                             | yes       | root                                                                                     |
group                             | yes       | root                                                                                     |
installer_archive                 | yes       | was-combined_85511_linux.x86.zip                                                         |
unarchive_src                     | yes       | <http://ftp.example.com/ibm-local/com/ibm/was/8.5.5.11/was-combined_85511_linux.x86.zip> |
download_directory_path           | yes       | /data/SW/was/85511                                                                       |
operation                         | no        | extract                                                                                  | copy
temporate_download_directory_path | no        | /tmp                                                                                     | {{ download_directory_path }}

## Example of how to call fetch-install-files from another role

```yaml
- name: Copy installations files
  tags:
    - copy-files
  become: yes
  include_role:
    name: fetch-install-files
  vars:
    operation: "copy"
    unarchive_dest: "/data/SW/was"
    owner: "root"
    group: "root"
    installer_archive: "was-combined_85511_linux.x86.zip"
    unarchive_src: "http://ftp.example.com/ibm-local/com/ibm/was/8.5.5.11/was-combined_85511_linux.x86.zip"
    download_directory_path: "/tmp"
    temporate_download_directory_path: "."
```
