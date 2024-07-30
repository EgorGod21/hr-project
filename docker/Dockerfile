FROM apache/airflow:latest-python3.12

COPY requirements.txt /requirements.txt

RUN pip install pip
RUN pip install --no-cache-dir -r /requirements.txt