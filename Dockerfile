FROM ubuntu:14.04
RUN apt-get update && apt-get install -y automake autotools-dev g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config vsftpd && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git
RUN cd s3fs-fuse && ./autogen.sh && ./configure &&  make && make install
RUN mkdir /s3data
RUN mkdir -p /var/run/vsftpd/empty
COPY bin /bin
COPY etc /etc

CMD bash -C '/bin/start-server';'bash' 
