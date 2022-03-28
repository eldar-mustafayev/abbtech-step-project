FROM python:3.9

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV DB_HOST='' DB_USER='' DB_PASSWORD='' DB_NAME=''

EXPOSE 8080
CMD [ "python", "./app.py" ]