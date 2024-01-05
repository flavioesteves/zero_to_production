use zero_to_production::configuration::get_configuration;
use zero_to_production::issue_delivery_worker::run_worker_until_stopped;
use zero_to_production::startup::Application;
use zero_to_production::telemetry::{get_subscriber, init_subscriber};

use std::fmt::{Debug, Display};
use tokio::task::JoinError;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let subscriber = get_subscriber("zero_to_production".into(), "info".into(), std::io::stdout);
    init_subscriber(subscriber);
    let configuration = get_configuration().expect("Failed to read configuration");

    let application = Application::build(configuration.clone()).await?;
    let application_task = tokio::spawn(application.run_until_stopped());
    let worker_task = tokio::spawn(run_worker_until_stopped(configuration));

    tokio::select! {
        _ = application_task =>{},
        _ = worker_task => {},
    }
    Ok(())
}

fn report_exit(task_name: &str, outcome: Result<Result<(), impl Debug + Display>, JoinError>) {
    match outcome {
        Ok(Ok(())) => {
            tracing::info!("{} has exited", task_name)
        }
        Ok(Err(e)) => {
            tracing::error!(
                    error.cause_chain = ?e,
                    error.message = %e,
                    "{} failed", task_name
            )
        }
        Err(e) => {
            tracing::error!(
                    error.cause_chain = ?e,
                    error.message = %e,
                    "{}' task failed to complete",
                    task_name
            )
        }
    }
}
