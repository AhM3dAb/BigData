build:
	docker build -t bigdata-base ./base
	docker build -t bigdata-master ./master
	docker build -t bigdata-worker ./worker
	docker build -t bigdata-history ./history
	docker build -t bigdata-kafka ./kafka
	docker build -t bigdata-jupyter ./jupyter
	docker build -t bigdata-dev ./dev
