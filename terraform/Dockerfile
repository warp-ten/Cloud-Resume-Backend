FROM alpine:latest

RUN apk update && apk add wget unzip

RUN wget https://releases.hashicorp.com/terraform/0.15.0/terraform_0.15.0_linux_amd64.zip && unzip /terraform* -d /usr/local/sbin

ENTRYPOINT [ "terraform", "-chdir=/github/workspace/terraform"  ]