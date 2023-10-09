# Interpretation of the book "Zero To Production in Rust"

# Cargo

1. cargo watch -x check
    *  Will run cargo check after every code change
2. cargo watch -x check -x test -x run
    * Runs cargo check.
    * It it succeds, launches carto test.
    * It tests pass launches the app with cargo run.
3. cargo check
    * check if is possibel to compile
4. cargo expand

# CI

1. Code Coverage
    * cargo tarpaulin --ignore-tests

# Linting - clippy

1. rustup component add clippy
2. cargo clippy
3. cargo clippy -- -D warnings
    * CI pipeline would fail if the linter check clippy emits any warnings

# Formatting

1. rustup component add rustfmt
2. cargo fmt
    * Format the whole project
3. cargo fmt -- --check

# Security Vulnerabilities

1. cargo install cargo-audit    
2. cargo audit
3. cargo cargo-deps // cargo +nightly udeps

# Rust ecosystem for test frameworks

1. rstest
2. test-case

# Database PostgreSQL

        Crate       |   Compile-time safety     |       Query Interface     |   Async   |       
1. tokio-postgres   |           No              |           SQL             |    Yes    |
2. sqlx             |           Yes             |           SQL             |    Yes    |
3. diesel           |           Yes             |           DSL             |    NO     |

# Telemetry

- Instrumented
- Telemetry Data
-[Observability](https://www.honeycomb.io/what-is-observability)
- The Facade Pattern
- Instrumenting Futures

- tracing_subscriber::filter::EnvFilter
- tracing_bunyan_formatter::JsonStorageLayer
- tracing_bunyan_formatter::BunyanFormatterLayer
- tracing-actix-web


1. Logging: crate [log](https://docs.rs/log/0.4.20/log/)
2. Tracing: crate [tracing](https://docs.rs/tracing/0.1.19/tracing/)
3. Subscriber = crate [tracing-subscriber](https://docs.rs/tracing-subscriber/0.3.17/tracing_subscriber/)
4. Tracing Bunyan Formatter = crate [tracing_bunyan_formatter](https://docs.rs/tracing-bunyan-formatter/0.3.9/tracing_bunyan_formatter/)
5. bunyan CLI (The original `bunyan` requires NPM, but can be installed a Rust-port with `cargo install bunyan`)
    - to test: TEST_LOG=true cargo test health_check_works | bunyan


# Secrecy

1. cargo [secrecy](https://docs.rs/secrecy/0.8.0/secrecy/) 
        
# Rust Patterns

- Resource Acquisition Is Initialization (RAII)

# Going Live

- Docker image deployed in [DigitalOcean's APP Platform](https://www.digitalocean.com/docs/app-platform/)
- [cargo-chef](https://github.com/LukeMathWalker/cargo-chef)

- cargo serde-aux


