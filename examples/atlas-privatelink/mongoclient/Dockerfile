FROM python:3.11-rc-bullseye

RUN apt-get update && apt-get install vim less wget curl zip unzip jq pwgen software-properties-common -y --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN pip3 install pymongo[aws] pymongo-auth-aws==1.1.0 dnspython
# mongosh
RUN wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
RUN apt-get update && apt-get install -y mongodb-mongosh

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install

WORKDIR app
COPY atlas-connection-string.txt ./
COPY client.py ./
ENTRYPOINT ["python","/app/client.py", "-t"]