# hci-notifier

Simple service for logging and notifying about Hercules CI job status changes

## Usage

```
usage: hci-notifier [-h] --account ACCOUNT [--latest LATEST] [--interval INTERVAL] [--libnotify]

simple service for logging and notifying about Hercules CI job status changes.

options:
  -h, --help           show this help message and exit
  --account ACCOUNT    the Hercules CI account (GitHub account or organization) to notify about
  --latest LATEST      the amount of jobs to check their status and notify about at a time (default: 3)
  --interval INTERVAL  how often (in seconds) to check for new job statuses (default: 15)
  --libnotify          whether to send a desktop notification about status changes via libnotify (default: False)
```
