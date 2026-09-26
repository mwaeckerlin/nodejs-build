# Changelog

- 2026-09-26 **1.0.2**
    - The image is published for amd64 and arm64 under one tag, built, tested and published automatically on every change and every week
    - The README example for a compiled application ran the binary through `node`; the binary is now the entrypoint of the final image, and a test builds and runs exactly that example

- 2026-07-17 **1.0.1**
    - Documentation now states the image's role explicitly: build-only, never for deployments — production images end in a runtime base stage as shown in the examples
    - Image build no longer emits warnings (modernized instruction format)
