# Builder Stage

# We use the lastest Rust stable release as base image
FROM rust:1.73.0 AS builder

# Let's switch our working directory to `app` (equivalent to `cd app`)
# The `app` folder will be created for us by Docker in case it does not
# exist aready
WORKDIR /app

# Install the required system dependencies for our linking configuration
RUN apt update && apt install lld clang -y
# Copy all files from our working environment to our Docker image
COPY . .

ENV SQLX_OFFLINE true
# Let's build our binary
# We'll use the release profile to make it fast
RUN cargo build --release


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
