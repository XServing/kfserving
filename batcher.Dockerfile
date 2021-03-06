# Build the inference-batcher binary
FROM golang:1.13.0 as builder

# Copy in the go src
WORKDIR /go/src/github.com/kubeflow/kfserving
COPY pkg/    pkg/
COPY cmd/    cmd/
COPY go.mod  go.mod
COPY go.sum  go.sum

RUN go mod download

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o batcher ./cmd/batcher

# Copy the inference-batcher into a thin image
FROM gcr.io/distroless/static:latest
COPY third_party/ third_party/
WORKDIR /
COPY --from=builder /go/src/github.com/kubeflow/kfserving/batcher .
ENTRYPOINT ["/batcher"]
