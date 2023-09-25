#[derive(serde::Deserialize)]
pub struct Settings {
    pub database: DatabaseSettings,
    pub application_port: u16,
}

#[derive(serde::Deserialize)]
pub struct DatabaseSettings {
    pub username: String,
    pub password: String,
    pub port: u16,
    pub host: String,
    pub database_name: String,
}

impl DatabaseSettings {
    pub fn connection_string(&self) -> String {
        format!(
            "postgres://{}:{}@{}:{}/{}",
            self.username, self.password, self.host, self.port, self.database_name
        )
    }
}

pub fn get_configuration() -> Result<Settings, config::ConfigError> {
    let base_path = std::env::current_dir().expect("Failed to determine the current directory");
    //let configuration_directory = base_path.join("configuration");
    let configuration_directory = base_path.join("");
    let settings = config::Config::builder()
        //.add_source(config::File::from("../configuration.yaml"))
        .add_source(config::File::from(
            //    configuration_directory.join("base.yaml"),
            configuration_directory.join("configuration.yaml"),
        ))
        .build()?;
    settings.try_deserialize::<Settings>()
}