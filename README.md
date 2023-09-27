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
    4. carrgo expand

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

        1. Logging: crate log

    - [Observability](https://www.honeycomb.io/what-is-observability)

