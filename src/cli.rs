#[derive(clap::Parser)]
#[command(version, about)]
pub struct Args {
    /// The Hercules CI account (GitHub account or organization) to notify about
    #[arg(short, long, required = true)]
    pub account: String,

    /// How often (in seconds) to check for new job statuses
    #[arg(short, long, default_value_t = 15)]
    pub interval: u8,

    /// Whether to send a desktop notification about status changes via dbus
    #[arg(short, long)]
    pub notify: bool,
}
