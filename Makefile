NAME = s3ftp

.PHONY: build
.PHONY: test
.PHONY: run
.PHONY: clean

default: test

build: Dockerfile bin/* etc/*
	docker build -t s3ftp .

test:  build clean
	docker run --rm -it --privileged \
		--name s3ftp \
		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		-e AWS_BUCKET=${AWS_BUCKET} \
		-e AWS_REGION=${AWS_REGION} \
		-e FTP_USER=${FTP_USER} \
		-e FTP_IP=${FTP_IP} \
		-p 21:21 -p 990:990 -p 15500-15599:15500-15599 \
		$(NAME)

run: test

ssl:
	openssl req -x509 -nodes -newkey rsa:1024 -keyout etc/ssl/private/vsftpd.pem -out etc/ssl/private/vsftpd.pem

env: .env
	. ./.env

ftp-test:
	ftp `docker inspect --format '{{ .NetworkSettings.IPAddress }}' s3ftp`

clean: env
	-docker rm s3ftp
