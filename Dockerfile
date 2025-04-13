# Specify the Rust version
ARG RUST_VERSION=1.86
FROM rust:${RUST_VERSION} AS base

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/home/root/app/target \
    cargo install cargo-chef

# ----------------- #
# ---- Planner ---- #
# ----------------- #
FROM base AS planner
WORKDIR /app

COPY Cargo.toml Cargo.lock ./
COPY src/ src/

RUN cargo chef prepare --recipe-path recipe.json

# ----------------- #
# ---- Builder ---- #
# ----------------- #
FROM base AS builder
WORKDIR /app

COPY --from=planner /app/recipe.json recipe.json

RUN cargo chef cook --release --recipe-path recipe.json

COPY . .

RUN cargo build --profile release

# ----------------- #
# ---- Runtime ---- #
# ----------------- #
FROM debian:bookworm AS runtime
WORKDIR /app

COPY --from=builder /app/target/release/redirect /usr/local/bin/

RUN useradd -m appuser && chown appuser /usr/local/bin/redirect
USER appuser

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/redirect"]
