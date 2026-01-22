.PHONY: help extract load dbt-run dbt-test

help:
	@echo "Available commands:"
	@echo "  make extract     - Download raw Olist dataset"
	@echo "  make load        - Load raw data into DuckDB"
	@echo "  make dbt-run     - Run dbt models"
	@echo "  make dbt-test    - Run dbt tests"

extract:
	python elt/extract/download_olist.py

load:
	python elt/load/load_to_duckdb.py

dbt-run:
	cd dbt && dbt run

dbt-test:
	cd dbt && dbt test
