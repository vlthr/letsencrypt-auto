SHELL:=/bin/bash
default: run

run:
	docker network ls | grep -w "vanguard-bridge" > /dev/null; if [[ "$$?" != 0 ]]; then docker network create -d bridge vanguard-bridge; fi
	docker-compose -f docker-compose.yml up -d

build:
	# cd client && npm run build
	docker build -t letsencrypt-auto.image .

stop:
	docker-compose -f docker-compose.yml kill || true

clean:
	docker-compose -f docker-compose.yml kill || true
	docker-compose -f docker-compose.yml rm -f || true

refresh:
	make clean && make build . && make && docker logs -f letsencrypt-auto_letsencrypt-auto_1
