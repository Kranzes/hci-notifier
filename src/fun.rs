use crate::data::{Job, ProjectWithJobs};
use anyhow::{bail, Result};
use notify_rust::Notification;
use serde_json::json;
use std::collections::HashMap;

pub fn fetch_latest_jobs_info_info(account: &str) -> Result<Vec<ProjectWithJobs>> {
    let endpoint = "https://hercules-ci.com/api/v1/jobs";
    let params = [("site", "github"), ("latest", "1"), ("account", account)];
    let url = reqwest::Url::parse_with_params(endpoint, params)?;

    let resp: Vec<ProjectWithJobs> = reqwest::blocking::get(url)?.json()?;

    if resp.is_empty() {
        bail!("job info for the account '{}' is empty, perhaps you entered the wrong username? (Check your casing)", account);
    }

    Ok(resp)
}

pub fn log_new_info(
    latest_job_for_project: &mut HashMap<String, Job>,
    info: Vec<ProjectWithJobs>,
    notify: bool,
) -> Result<()> {
    for p in info {
        if let Some(j) = p.jobs.into_iter().next() {
            if let Some(old_job) = latest_job_for_project.get_mut(&p.project.id) {
                if old_job != &j {
                    println!(
                        "{}",
                        json!({
                            "repo": format!("{}/{}", j.owner_name, j.repo_name),
                            "git_rev": j.source.revision,
                            "status": j.status.to_lowercase()
                        })
                    );
                    if notify {
                        Notification::new()
                            .summary("Hercules-CI Job Status")
                            .body(&format!(
                                "Repo: {}/{}\nGit rev: {}\nStatus: {}",
                                j.owner_name,
                                j.repo_name,
                                j.source.revision,
                                j.status.to_lowercase()
                            ))
                            .show()?;
                    }
                    *old_job = j;
                }
            } else {
                latest_job_for_project.insert(p.project.id, j);
            }
        }
    }
    Ok(())
}
