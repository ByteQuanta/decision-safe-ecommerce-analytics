## Decision-Safe E-commerce Analytics
### Overview

This project demonstrates a decision-safe analytics pipeline for e-commerce data.

Unlike traditional analytics systems that always publish metrics,
this pipeline explicitly evaluates data quality and business risk
before allowing analytics to be consumed.

The goal is not faster dashboards, but safer business decisions.

---

### Architecture Summary

- Extract: Raw Olist e-commerce data downloaded from Kaggle

- Load: Immutable raw data loaded into a DuckDB warehouse

- Transform: SQL-based transformations using dbt

- Audit: Explicit data quality metrics

- Contract: Business decision thresholds derived from quality signals

- Analytics: Published only if contracts allow it

- Monitoring: Drift detection and contract breach alerts

Analytics is not guaranteed.
It is earned through data quality.

See diagrams/pipeline_architecture.md for the full pipeline flow.

---

### Monitoring & Alerts (Added Layer)

Beyond static audits and contracts, this pipeline includes
explicit monitoring and alerting models.

These models continuously observe key quality signals
over time and raise alerts when abnormal behavior is detected.

Two alert types are implemented:

- Drift Alerts  
  Detect sudden changes in key metrics compared to historical baselines.

- Contract Breach Alerts  
  Trigger when business decision thresholds are violated.

Alerts are intentionally modeled as data.
An empty alert table means the system is healthy.

---

### What This Project Does Differently

Traditional analytics pipelines follow this logic:

If data arrives, publish metrics.

This project follows a different rule:

Only publish metrics if the risk of misleading decisions is acceptable.

Key differences:

- Data quality is measured, not assumed

- Business thresholds are explicit, not implicit

- Analytics can refuse to publish when risk is too high

- Data quality issues surface as alerts, not silent failures

---

### Why There Is No Machine Learning Model

This project intentionally does not train a machine learning model.

In many real-world systems, the primary source of business loss is not
poor model accuracy, but silently corrupted data feeding dashboards,
reports, and downstream models.

This pipeline ensures that:

- Analytics are trustworthy

- Any future ML models would be trained on decision-safe data

---

### Alerting Philosophy

In production systems, the absence of alerts is a success condition.

This project models alerts as first-class analytical outputs:

- Alert tables are expected to be empty most of the time
- A non-empty alert table represents a system state change
- Analytics consumption is gated independently from alert presence

This design avoids alert fatigue while ensuring
that genuine data risks cannot go unnoticed.

---

### Business Impact (Quantified)

This project focuses on preventing bad decisions, not optimizing metrics at any cost.

Using the Olist dataset:

- Total orders analyzed: ~99,000

- Undelivered order rate: ~3%

A traditional pipeline would always publish this metric.

This pipeline:

- Audits delivery completeness

- Applies an explicit threshold (max 5% undelivered)

- Publishes analytics only if the threshold is respected

This prevents dashboards from:

- Underestimating operational issues

- Masking late-arriving or incomplete data

- Triggering incorrect cost-optimization decisions

---

### When This System Matters Most

- Operational KPIs used for executive decisions

- Dashboards driving cost reduction or SLA enforcement

- Analytics feeding downstream ML models

- Environments where late-arriving data is common

---

### Technologies Used

- DuckDB (analytical warehouse)

- Python (ELT orchestration)

- dbt (transformations, tests, monitoring, alerts)

---

### Data Source

This project uses the **Olist Brazilian E-Commerce Dataset**, a public dataset
commonly used for analytics and data engineering case studies.

**Dataset details:**

- Source: Kaggle – Olist E-commerce Dataset (https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- Domain: E-commerce orders, customers, logistics
- Size: ~100k orders
- Data format: CSV

The dataset contains real-world characteristics such as:
- Late-arriving data
- Missing delivery timestamps
- Incomplete order fulfillment records

These properties make it well-suited for demonstrating
**data quality auditing, decision gating, and contract-based analytics**.

---

### Folder Structure

decision-safe-ecommerce-analytics/
│
├── README.md
│
├── Makefile
│
├── .env.example
│
├── pyproject.toml
│
├── requirements.txt
│
├── data/
│   └── raw/
│       └── olist/              # Original dataset
│
├── elt/
│   ├── extract/
│   │   └── download_olist.py
│   └── load/
│       └── load_to_duckdb.py
│
├── warehouse/
│   └── duckdb/
│       └── analytics.duckdb
│
├── dbt/
│   ├── dbt_project.yml
│   ├── profiles.yml
│   ├── .user.yml
│   └── models/
│       ├── bronze/
│       │   ├── schema.yml
│       │   └── bronze_orders.sql
│       ├── audit/
│       │   └── audit_orders_quality.sql
│       ├── contracts/
│       │   └── contracts_orders.sql
│       ├── monitoring/
│       │   ├── alerts_drift.sql
│       │   └── order_health_snapshot.sql
│       ├── alerts/
│       │   └── alerts_contracts.sql
│       └── analytics/
│           └── analytics_order_summary.sql
│
├── contracts/
│   └── decision_thresholds.yml
│
├── notebooks/
│   └── business_impact.ipynb
│
└── diagrams/
    └── pipeline_architecture.md

---

### How to Run

1. Prerequisites

- Python 3.10+
- Conda (recommended)
- dbt-core
- dbt-duckdb

---

2. Create Environment

```bash
conda create -n decision-safe python=3.11
conda activate decision-safe
pip install -r requirements.txt
```

3. Initialize dbt

Move into the dbt directory:
```bash
cd dbt
```

Verify dbt connection:
```bash
dbt debug
```

4. Run the ELT Pipeline

Run transformations step by step:
```bash
# Bronze layer
dbt run --select bronze

# Data quality audit
dbt run --select audit

# Decision contracts
dbt run --select contracts

# Business analytics (only if contracts allow)
dbt run --select analytics
```

5. Monitoring & alerts

```bash
dbt run --select monitoring
dbt run --select alerts
```

6. Validate Results

Open a Python shell and inspect the DuckDB warehouse:
```python
import duckdb

con = duckdb.connect("warehouse/duckdb/analytics.duckdb")
print(con.execute("select * from analytics_order_summary").fetchdf())
```

