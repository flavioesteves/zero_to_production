# Builder Stage

# We use the lastest Rust stable release as base image
FROM lukemathwalker/cargo-chef:latest-rust-1.72.0 as chef
WORKDIR /app

# Install the required system dependencies for our linking configuration
RUN apt update && apt install lld clang -y
# Copy all files from our working environment to our Docker image

FROM chef as planner
COPY . .

# Compute a lock-file file for our project
RUN cargo chef prepare --recipe-path recipe.json

FROM chef as builder
COPY --from=planner /app/recipe.json recipe.json
# Build our project dependencies, not our application!
RUN cargo chef cook --release --recipe-path recipe.json
# Up to this point, if our dependecy tree stays the same,
# all layers should be cached
COPY . .
ENV SQLX_OFFLINE true
# Let's build our binary
RUN cargo build --release --bin zero_to_production


# Runtime stage
FROM debian:bookworm-slim AS runtime

WORKDIR /app
# Install OpenSSL - it is dyanmically linked by some of our dependencies
# Install ca-certificates - it is needed to verify TLS ca-certificates
# when establishing HTPPS Connections

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends openssl ca-certificates \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Copy the compiled binary from the builder environment
# to our runtime environment
COPY --from=builder /app/target/release/zero_to_production zero_to_production

# WE need the configuration file at runtime!
COPY configuration configuration
ENV APP_ENVIRONMENT production

# When `docker run` is executed, lauch binary!
ENTRYPOINT ["./zero_to_production"]
