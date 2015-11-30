s3ftp
=====

Docker container running vsftpd ftps server with Amazon S3 backed storage

Configuration
-------------

Create an s3 bucket for each user using a common prefix with their username as the suffix
for example 
    ftp-files-user1
    ftp-files-user2

Create an iam user with privilages on these buckets, a user policy something like this: 

    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "Stmt0000",
                "Effect": "Allow",
                "Action": [
                    "s3:DeleteObject",
                    "s3:GetObject",
                    "s3:ListBucket",
                    "s3:PutObject",
                    "s3:PutObjectAcl"
                ],
                "Resource": [
                    "arn:aws:s3:::ftp-files-user1/*",
                    "arn:aws:s3:::ftp-files-user2/*"
                ]
            },
            {
                "Sid": "Stmt0001",
                "Effect": "Allow",
                "Action": [
                    "s3:ListBucket"
                ],
                "Resource": [
                    "arn:aws:s3:::ftp-files-user1",
                    "arn:aws:s3:::ftp-files-user2"
                ]
            }
        ]
    }


Create an access key for this user, make sure you have the access key and secret


Clone this repo

    git clone reponame
    cd reponame

create a certificate
    
    mkdir -p /etc/ssl/private
    openssl req -x509 -nodes -newkey rsa:1024 -keyout etc/ssl/private/vsftpd.pem -out etc/ssl/private/vsftpd.pem


Build the image

    docker build -t s3ftp .

Run ths image    

    docker run --rm --privileged \
    		--name s3ftp \
    		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    		-e AWS_BUCKET=${AWS_BUCKET} \
    		-e AWS_REGION=${AWS_REGION} \
    		-e FTP_USER=${FTP_USER} \
    		-e FTP_IP=${FTP_IP} \
    		-p 21:21 -p 15500-15599:15500-15599 \
    		s3ftp

You will need to set the environment, the following variables are used:

### AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

AWS credentials, from the iam user you set up.


### AWS_REGION

aws region (there is no default so this is required e.g. eu-west-1)


### AWS_BUCKET

S3 bucket prefix (each user will be restricted to a bucket based on this and their username
e.g. with a prefix of ftp-files, the full bucket for user1 would be ftp-files-user1

### FTP_IP
The public ip address to report for passive ftp connections, this will default to the container ip

### FTP_USER

list of users and passwords to allow ftp access to in the following format:
user1:secret1,user2:secret2


Make
----

if you have make installed, you can use the following:

- make build - build the docker image
- make - run the docker container (requires .env - see below)

make will source a file in the current directory called `.env` use this to export the environement variables described above e.g:

    # .env
    export AWS_ACCESS_KEY_ID=yyyyyyyyyyyyyyyy
    export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxx
    export AWS_BUCKET=ftp-data
    export AWS_REGION=eu-west-1
    export FTP_IP=127.0.0.1
    export FTP_USER=user1:secret1,user2:shhh

TODO
----
1. allow uplaod of trusted server certificate
2. allow user to specify the ports to listen on (currently the server listens on 21 with passive connection in the range 15500 to 155992. allow user to specify the ports to listen on (currently the server listens on 21 with passive connection in the range 15500 to 15599
