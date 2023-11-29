# Interpretation of the book "Zero To Production in Rust"

# Cargo

1. cargo watch -x check
   - Will run cargo check after every code change
2. cargo watch -x check -x test -x run
   - Runs cargo check.
   - It it succeeds, launches carto test.
   - It tests pass launches the app with cargo run.
3. cargo check
   - check if is possibel to compile
4. cargo expand

# CI

1. Code Coverage
   - cargo tarpaulin --ignore-tests

# Linting - clippy

1. rustup component add clippy
2. cargo clippy
3. cargo clippy -- -D warnings
   - CI pipeline would fail if the linter check clippy emits any warnings

# Formatting

1. rustup component add rustfmt
2. cargo fmt
   - Format the whole project
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

1. tokio-postgres | No | SQL | Yes |
2. sqlx | Yes | SQL | Yes |
3. diesel | Yes | DSL | NO |

# Telemetry

- Instrumented
- Telemetry Data -[Observability](https://www.honeycomb.io/what-is-observability)
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

# Testing

- crate [fake](https://crates.io/crates/fake)
- crate [quickcheck](https://crates.io/crates/quickcheck)
- crate [proptest](https://crates.io/crates/proptest)

  - REST API:
    - crate[wiremock](https://crates.io/crates/wiremock)

# Email Delivery Component

- [SMTP](https://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol)
- Email providers: [AWS SES](https://aws.amazon.com/ses/), [SendGrid](https://sendgrid.com/), [MailGun](https://mailgun.com), [Mailchimp](https://mailchimp.com), [Postmark](https://postmarkapp.com)
- For this porject: Postmark

# REST API

- crate [reqwest](https://crates.io/crates/reqwest)

# Deployment Strategies

- Naive Deployment  
   Version A of our service is running in production and we want to roll out version B:
  _We switch off all instances of version A running the cluster;
  _ We spin up new instances of our application running version B; \* We start serving traffic using version B.

- Load Balancers  
   We have multiple copies of our application running behind a load balancer.
  _Load balanceers usually support adding (and removing) backends dyanamically.
  _ Horizontal Scaling
  We can add more capacity when experiencing a traffic spike by spinning up more replicas of our application
  _Health Checks
  _ Passive - the load balancer looks at the distribuition of status codes/latency for each backend
  to determine if they are healthy or not; \* Active - the load balancer is configured to send a health check request to each backend on a schedule.
  If a backend fails to respond with a success status code for a long enough time period it is marked as unhealthy
  and removed.

- Rolling Update Deployments  
   We have x copies of Version A, we add a copy of Version B and then we start to remove/replace Version A into Version B until all running version are Version B.

# Database Migrations

- State Is Kept Outside The Application  
   In the Load Balacing all the backends are talking to the same database to query and manipulate the same state.

- Deployments And Migrations  
   The old and the new version of the application are using the same database at the same time.

  - Multi-step Migrations

- Example: A New Mandatory Column
  1. Add as Optional
  2. Start Using The New Column
  3. Backfill And Mark As NOT NULL

# Databse Transactions

- Transactions are a way to group together related operations in a single unit of work.The database guarantees that all operations within a transaction will succeed
  or fail together: the database will never be left in a state where the effect of only a subset of the queries in a transaction is visible.

- Start of a transaction in Postgres: BEGIN
- End of a transaction in Postgres: COMMIT
- Trigger a rollback in Postgres: ROLLBACK

- To dive deep in this topic, was recommended this book ["Designing Data Intensive Applications"](https://www.oreilly.com/library/view/designing-data-intensive-applications/9781491903063/)
- Sqlx provides a dedicated API.

# Errors

- Error should be logged when they are handled. To avoid reporting the same information in more than 1 place.

- Errors serve two main purposes:

  1. Control flow (i.e. determine what to next): is scripted, all information required to take a decision on what to do next must be accessible to a machine.  
     We use type(e.g. enum variants), methos and fields for internal errors.  
     We rely on status codes for errors at the edge.

  2. Reporting (e.g investigate, after the fact , what went wrong on): are primarily consumed by humans. The content has to be tuned depending on the audience.  
     An operator has access to the internals of the system - they should be provided with as much context as possible ont the failure mode
     We rely on "Logs/trace" internal and at the edge "Response Body"

- Can be also distinguish erros based on their location:

  1. Internal (i.e. a function calling another function within our application);
  2. At the edge (i.e. an API request that we failed to fulfill)

- The Error trait is, first and foremost, a way to semantically mark our type as being an error. It helps a reader of our codebase to immediately spot its purpose.
  It is also a way for the Rust community to standardise on the minimum requirements for a good error:
  _it should provide different representations (Debug and Display), tuned to different audiences;
  _ it should be possible to look at the underlying cause of the error, if any (source).

      |----------------------------------------------------|
      |             |         Internal       | At the edge |
      |----------------------------------------------------|
      |Control Flow | Types, methods, fields | Status Codes|
      |Reporting    | Logs/traces            | Respose body|

# Trait Objects

- dyn Error is a trait object -> Trait objects, just like generic type parameters, are way to archieve polymorphism in Rust: invoke
  different implementations of the same interface. Generic types are resolved at compile-time (static dispatch), trait objects incur a runtime cost (dynamic dispatch)

# Securing API

- Basic authentication
- Session based authentication
- OAuth 2.0
- OpendId Connect
- JSON Web Tokens (JWTs)

1.  Verify identity of API callers:

    - Something the know (passwords, PINs, security questions)
    - Something they have (smartphone, using an authenticator app)
    - Something they are (fingerprints, Apple's Face ID)

    - Drawbacks:

      1. Something they Know: Passwords must be long - short ones are vulnerable to brute-force.
      2. Something they Have: Smartphones and U2F keys can be lost, locking the user out of their accounts and can be stolen.
      3. Something they Are: Biometrics cannot be changed.

    - Multi-factor Authentication(MFA)
      1. Provide the user at least with two different tyes of authentication factors in order to get access

2.  Password-based Authentication  
     _Basic Authentication: RFC 2617, RFC 7617
    _ The API must look for the Authorization header in incoming request, - Authorization: Basic <enconded credentials> - where <enconded credentials> is the base64-encoding of {username}:{password}.

        * Use Cryptographic hash function: MD5, SHA-1, SHA-2. SHA-3, KangarooTwelve
        * Output Size options: 224, 256, 384, 512
        * Selected for this usecase: SHA3-256
        * crate sha3

        * Implementation of the crate Argon2: The Open Web Application Security Project (OWASP)
        - Use Argon2id with a minimum configuration of 15 MiB of memory, an iteration count of 2, and 1 degree of parallelism.
        - If Argon2id is not available use bcrypt with a work factor of 10 or more and with a password limit of 72 bytes.
        - For Legacy systems usnig scrypt, use a minimum CPU/memory cost parameterof(2^16), a minimum block size of 8 (1024 bytes),
        and a parallelization parameter of 1.
        - IF FIPS-140 compliance is required, use PBKDF2 with a work factor a 310.000 or more and set with an internal hash function
        of HMAC-SHA-256.
        - Consider using a pepper to provide additional defense in depth (though alone, it provides no additional secure characteristics).

        * PHC string format
        * TLS: Transport Layer Security

    P319

3.  Password Reset

    - Interaction Types

    - Other APIs (machine-to-machine)
    - A Person, via a browser
    - Another API, on behalf of a person

    - Machine To Machine

    - Same organization mutual TLS (mTLS)

    - Client Credentials via OAuth2: [client credentials flow](https://auth0.com/docs/get-started/authentication-and-authorization-flow/client-credentials-flow)

    - JWT validation [riddled with dangerous edge cases](https://blog.mathpresso.com/jwts-and-their-pitfalls-ffe8c9dba927)

    - Person Via Browser

    - Session-base authentication

    - Federeted identity

    - Machine to machine, on behalf of a person

# Cross-Site Scripting (XSS)

- Crate htmlescape

# Message Authentication Codes

- Adding an HMAC Tag To Protect Query parameters

- crate hmac, sha2

# Cookies

- A small piece of data that a server to a user's web browser. The browser may store the cookie and send it back to the same server
  with later requests (MDN).

# FlashMessages

- Each flash messages has a level and a string of content. The message level can be usef for filtering and rendering
[FlashMessages](https://docs.rs/actix-web-flash-messages/latest/actix_web_flash_messages/struct.FlashMessage.html)


# Sessions

- Session-base authentication is a strategy to avoid asking users to provide their password on every single page.
Useers are asked to authenticate once, via a login form: id successful, the server generates a one-time secret - an authenticated session token.

- [OWASP](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) provides extensive guidante on how to secure sessions.

## Session Store

- OWASP recommends using cryptographically secure pseudorandom number generator (CSPRNG)
- Session state

## Choosing A Session Store

- During a lifecycle of a session we need o perform the following operations (CRUD: create, read, update, delete):
    * creation: when a user logs in;
    * retrieval: using the session tokens extracted from the cookie attached to the incoming requests;
    * update: when a logged-in user performs some actions that lead to a change in their session state;
    * deletion: when user logs out


## REDIS
- Redis is an in-memory database: it uses RAM instead of disk for storage, trading off durability for speed.
- Rust Dependencies: actix-session = {version="0.8", features =["redis-rs-tls-session"]}


