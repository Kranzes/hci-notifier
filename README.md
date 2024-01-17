# hci-notifier

A simple service for logging and notifying about Hercules CI job status changes

## Usage

A simple service for logging and notifying about Hercules CI job status changes

Usage: hci-notifier [OPTIONS] --account <ACCOUNT>

Options:
  -a, --account <ACCOUNT>    The Hercules CI account (GitHub account or organization) to notify about
  -i, --interval <INTERVAL>  How often (in seconds) to check for new job statuses [default: 15]
  -n, --notify               Whether to send a desktop notification about status changes via dbus
  -h, --help                 Print help
  -V, --version              Print version
