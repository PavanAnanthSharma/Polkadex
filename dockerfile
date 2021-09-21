FROM ubuntu as builder
RUN apt-get update
RUN apt-get install -y git && apt-get install -y curl
RUN git clone https://github.com/Polkadex-Substrate/Polkadex
# # Gets the latest tag and chain spec
RUN cd Polkadex && \
    git checkout $(git describe --tags --abbrev=0) && \
    curl -O -L https://github.com/Polkadex-Substrate/Polkadex/releases/download/$(git describe --tags --abbrev=0)/customSpecRaw.json && \
    ls && \
    apt-get install -y build-essential && \
    apt-get install -y clang && \
    apt-get install -y jq && \
    curl https://sh.rustup.rs -sSf | sh -s -- -y && \
        export PATH="$PATH:$HOME/.cargo/bin" && \
        rustup toolchain install nightly-2021-06-28 && \
        rustup target add wasm32-unknown-unknown --toolchain nightly-2021-06-28 && \
        rustup default stable && \
        cargo update -p sp-std --precise 88c64e06471cc12aa9b25290f24d5566bcb5dd82 && \
        cargo +nightly-2021-06-28 build --release

# /\-Build Stage | Final Stage-\/

FROM docker.io/library/ubuntu:20.04
COPY --from=builder /Polkadex/target/release/polkadex-node /usr/local/bin

RUN useradd -m -u 1000 -U -s /bin/sh -d /polkadex-node polkadex-node && \
        mkdir -p /polkadex-node/.local/share && \
        mkdir /data && \
        chown -R polkadex-node:polkadex-node /data && \
        ln -s /data /polkadex-node/.local/share/polkadex-node && \
        rm -rf /usr/bin /usr/sbin

COPY --from=builder /Polkadex/customSpecRaw.json /data

USER polkadex-node
EXPOSE 30333 9933 9944
VOLUME ["/data"]

EXPOSE 30333 9933 9944

ENTRYPOINT ["/usr/local/bin/polkadex-node","--chain=/data/customSpecRaw.json","--bootnodes=/ip4/13.235.190.203/tcp/30333/p2p/12D3KooWMJ4AMmzpRbv914ZGZR6ehBhcZvGtqYid5jxSx8vXiSr7", "--rpc-external", "--ws-external"]

