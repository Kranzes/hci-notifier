use serde::Deserialize;

#[derive(Deserialize, PartialEq)]
pub struct Job {
    #[serde(rename = "jobStatus")]
    pub status: String,
    #[serde(rename = "ownerName")]
    pub owner_name: String,
    #[serde(rename = "repoName")]
    pub repo_name: String,
    pub source: Source,
}

#[derive(Deserialize, PartialEq)]
pub struct Source {
    pub revision: String,
}

#[derive(Deserialize)]
pub struct ProjectWithJobs {
    pub jobs: Vec<Job>,
    pub project: Project,
}

#[derive(Deserialize)]
pub struct Project {
    pub id: String,
}
