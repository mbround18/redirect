ARG RUST_VERSION=1.70
# ----------------- #
# ---- Planner ---- #
# ----------------- #
FROM lukemathwalker/cargo-chef:latest-rust-${RUST_VERSION}-alpine as planner
WORKDIR /app/redirect
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

# ----------------- #
# ---- Cacher  ---- #
# ----------------- #
FROM lukemathwalker/cargo-chef:latest-rust-${RUST_VERSION}-alpine as cacher
WORKDIR /app/redirect
COPY --from=planner /app/redirect/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

# --------------------------- #
# ---- Project Mangement ---- #
# --------------------------- #

FROM mbround18/cargo-make:latest as cargo-make

# ----------------- #
# ---- Builder ---- #
# ----------------- #
FROM rust:${RUST_VERSION} as builder
WORKDIR /app/redirect
COPY . .
# Copy over the cached dependencies
COPY --from=cacher /app/redirect/target target
COPY --from=cacher /usr/local/cargo/registry /usr/local/cargo/
COPY --from=cargo-make /usr/local/bin/cargo-make /usr/local/cargo/bin
RUN /usr/local/cargo/bin/cargo build --release

# ----------------- #
# ---- Runtime ---- #
# ----------------- #
FROM debian:buster-slim as runtime
WORKDIR /app/redirect
COPY --from=builder /app/redirect/target/release/redirect /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/redirect"]
