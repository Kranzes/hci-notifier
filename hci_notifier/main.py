from typing import Any
import httpx
import logging
import sys
import subprocess
import textwrap
import time
import argparse


def fetch_latest_job_statuses(
    account: str, latest: int
) -> list[dict[str, dict | list]]:
    # Function to fetch the latest job statuses from the API
    params: dict[str, str | int] = {
        "site": "github",
        "account": account,
        "latest": latest,
    }
    logging.getLogger("httpx").disabled = True  # httpx likes to talk a lot
    response = httpx.get("https://hercules-ci.com/api/v1/jobs", params=params)
    if response.json():
        return response.json()
    else:
        logging.error(
            "unable to fetch the latest job statuses, perhaps you entered the wrong account name?"
        )
        sys.exit(1)


def check_new_job_statuses(
    account: str, latest: int, interval: int, libnotify: bool
) -> None:
    # Dictionary to store job IDs as keys and their statuses as values
    previous_job_statuses: dict[str, str] = {}

    # Fetch initial job statuses as reference when the script starts
    initial_statuses = fetch_latest_job_statuses(account, latest)

    if initial_statuses:
        # Create a dictionary with job IDs as keys and their statuses as values
        previous_job_statuses = {
            job_info["jobs"][0]["id"]: job_info["jobs"][0]["jobStatus"]
            for job_info in initial_statuses
        }

    while True:
        # Fetch the latest job statuses at intervals
        latest_statuses = fetch_latest_job_statuses(account, latest)

        if latest_statuses:
            for job_info in latest_statuses:
                job: dict[str, Any] = job_info["jobs"][0]
                job_id: str = job["id"]
                job_status: str = job["jobStatus"]
                job_repo_name: str = job["repoName"]
                job_owner_name: str = job["ownerName"]
                job_git_rev: str = job["source"]["revision"]

                # Check if the job ID is new or if its status has changed
                if (
                    job_id not in previous_job_statuses
                    or previous_job_statuses[job_id] != job_status
                ):
                    # If it's a new or updated status log it
                    logging.info(
                        f"repo: {job_owner_name}/{job_repo_name}, git rev: {job_git_rev}, status: {job_status}"
                    )
                    # Send desktop notification if enabled
                    if libnotify:
                        subprocess.run(
                            [
                                "notify-send",
                                "Hercules-CI Job Status",
                                textwrap.dedent(
                                    f"""
                                    Repo: {job_owner_name}/{job_repo_name}
                                    Git rev: {job_git_rev}
                                    Status: {job_status}
                                    """
                                ),
                            ]
                        )
                    # Update the dictionary with the new or changed status
                    previous_job_statuses[job_id] = job_status

        # Wait for the specified interval before fetching statuses again
        time.sleep(interval)


def main() -> None:
    parser = argparse.ArgumentParser(
        argument_default=argparse.SUPPRESS,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        description="simple service for logging and notifying about Hercules CI job status changes",
    )
    parser.add_argument(
        "--account",
        required=True,
        type=str,
        action="store",
        help="the Hercules CI account (GitHub account or organization) to notify about",
    )
    parser.add_argument(
        "--latest",
        default=3,
        type=int,
        action="store",
        help="the amount of jobs to check their status and notify about at a time",
    )
    parser.add_argument(
        "--interval",
        default=15,
        type=int,
        action="store",
        help="how often (in seconds) to check for new job statuses",
    )
    parser.add_argument(
        "--libnotify",
        default=False,
        action="store_true",
        help="whether to send a desktop notification about status changes via libnotify",
    )
    args = parser.parse_args()

    # Set log level
    logging.basicConfig(level=logging.INFO)

    check_new_job_statuses(args.account, args.latest, args.interval, args.libnotify)
