```text
Kaggle (Olist)
      |
      v
data/raw (immutable)
      |
      v
DuckDB Warehouse (analytics.duckdb)
      |
      v
bronze
      |
      v
audit
      |
      v
contracts (decision gate)
      |
 allow_analytics = true ?
      |
      v
analytics
```