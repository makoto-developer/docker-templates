import (
  "bytes"
  "context"
  "fmt"
  "log"

  "github.com/elastic/go-elasticsearch/v8"
)

// ...

cfg := elasticsearch.Config{
  Addresses: []string{
    "http://localhost:9200/",
  },
  APIKey: "",
}

es, err := elasticsearch.NewClient(cfg)
if err != nil {
  log.Fatalf("Error creating the client: %s", err)
}

