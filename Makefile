.PHONY: clean data lint requirements sync_data_to_s3 sync_data_from_s3

#################################################################################
# GLOBALS                                                                       #
#################################################################################

BUCKET = yelp.academic

#################################################################################
# COMMANDS                                                                      #
#################################################################################

requirements:
	pip install -q -r requirements.txt

load_dataset_to_sqlite:
	sqlite3 data/yelp.db < src/data/init.sql
	python3 src/data/make_dataset.py

data:
	sqlite3 data/yelp.db < src/data/reviews.sql

clean:
	find . -name "*.pyc" -exec rm {} \;

lint:
	flake8 --exclude=lib/,bin/ .

sync_data_to_s3:
	s3cmd sync --recursive data/ s3://$(BUCKET)/data/

sync_data_from_s3:
	s3cmd sync --recursive s3://$(BUCKET)/data/ data/

#################################################################################
# PROJECT RULES                                                                 #
#################################################################################
