use anyhow::Result;
use clap::Parser;
mod cli;
use cli::Args;
use std::{collections::HashMap, thread::sleep, time::Duration};
mod data;
use data::Job;
mod fun;
use fun::{fetch_latest_jobs_info_info, log_new_info};

fn main() -> Result<()> {
    let args = Args::parse();

    // holds the latest status per project ID
    let mut latest_job_for_project: HashMap<String, Job> = HashMap::new();

    loop {
        let info = fetch_latest_jobs_info_info(&args.account)?;
        log_new_info(&mut latest_job_for_project, info, args.notify)?;
        sleep(Duration::from_secs(args.interval.into()));
    }
}
