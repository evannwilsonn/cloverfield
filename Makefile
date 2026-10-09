.PHONY: setup extract load build page serve all
all: extract load build page   ## read the sources, rebuild, write the status page (DuckDB)
setup:    ## install dependencies
	pip install -r requirements.txt
extract:  ## GitHub run history + Cloverleaf's data branch into data/raw (with SHA-256 manifest)
	python ingest/extract.py
load:     ## land data/raw in DuckDB unchanged
	python ingest/load_raw.py
build:    ## seed, run and test every dbt model
	dbt build --profiles-dir .
page:     ## export the reporting marts for the status page
	python dashboard/export_data.py
serve:    ## open the status page at http://localhost:8000
	cd dashboard && python -m http.server 8000
