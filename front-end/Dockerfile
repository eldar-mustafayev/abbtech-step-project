FROM python:3.9

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV BACKEND_HOST=''

EXPOSE 80
CMD [ "python", "./app.py" ]