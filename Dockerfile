FROM swift:4.1

WORKDIR /caption
COPY ./ ./
RUN swift build -c release && \
  cp .build/x86_64-unknown-linux/release/CaptionDecoder ./ && \
  rm -rf .build

# Add Tini
ENV TINI_VERSION v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ENTRYPOINT ["/tini", "--", "./CaptionDecoder"]
