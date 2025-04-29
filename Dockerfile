FROM ubuntu:18.04

RUN apt-get update && apt-get install -y python3.6 \
    python3-pip python3-venv sudo apt-transport-https wget

# Set up project directory
RUN mkdir -p /opt/cmate/
COPY . /opt/cmate/

# Set environment variables
ENV ROOT_DIR="/opt/cmate"
ENV SECRET_KEY="your_own_secret_key"
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Upgrade pip
RUN pip3 install --upgrade pip

# Install project dependencies
RUN cd $ROOT_DIR && pip3 install --no-cache-dir -r requirements.txt --default-timeout=100

# Download model files
RUN cd $ROOT_DIR/src/cmate/segmentation/models && sh get_models.sh

# Install Gunicorn
RUN pip3 install gunicorn

# Set working directory to where wsgi.py is located
WORKDIR $ROOT_DIR/src/flask_app/

# Expose the port the app runs on
EXPOSE 8080

# Run with Gunicorn in production
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "wsgi:app"]
