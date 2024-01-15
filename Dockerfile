# Use the official Python image with Alpine Linux
FROM python:3.9-alpine3.19

# Set metadata information
LABEL maintainer="https://3d-portfolio-lovat-omega.vercel.app/"

# Set environment variable to prevent Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED 1


RUN apk add --update --no-cache postgresql-client

# Install system dependencies required by psycopg2
RUN apk add --no-cache musl-dev postgresql-dev

# Copy requirements.txt and the app directory
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

# Set the working directory
WORKDIR /app

# Expose the port the app will run on
EXPOSE 8000

ARG DEV=false
# Create a virtual environment and install Python dependencies
RUN python3.9 -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install --no-cache-dir -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then \
        /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm /tmp/requirements.txt

# Install flake8
RUN /py/bin/pip install flake8

# Add a non-root user
RUN adduser \
    --disabled-password \
    --no-create-home \
    django-user

# Add the virtual environment to the PATH
ENV PATH="/py/bin:$PATH"

# Switch to the non-root user
USER django-user
