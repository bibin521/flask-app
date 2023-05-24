FROM alpine:latest

RUN mkdir /var/flaskapp
WORKDIR /var/flaskapp
COPY . .
RUN apk update && apk add --no-cache python3 && apk add py-pip py3-pip
RUN pip3 install -r requirements.txt
EXPOSE 5000
CMD ["python3" , "app.py"]

