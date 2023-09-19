# Interpretation of the book "Zero To Production in Rust"


## Cargo
    1. cargo watch -x check
        *  Will run cargo check after every code change
    2. cargo watch -x check -x test -x run
        * Runs cargo check.
        * It it succeds, launches carto test.
        * It tests pass launches the app with cargo run.

## CI
    1. Code Coverage
        * cargo tarpaulin --ignore-tests
## Linting - clippy
    1. rustup component add clippy
    2. cargo clippy
    3. cargo clippy -- -D warnings
        * CI pipeline would fail if the linter check clippy emits any warnings

## Formatting
    1. rustup component add rustfmt
    2. cargo fmt
        * Format the whole project
    3. cargo fmt -- --check 
        * Add formatting step to the pipeline

## Security Vulnerabilities
    1. cargo install cargo-audit
    2. cargo audit
