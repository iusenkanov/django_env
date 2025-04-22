# Use a specific version of Python as the base image
FROM python:3.8.16-slim

# Set the working directory
WORKDIR /app

# Copy the requirements.txt file into the container
COPY requirements.txt .

# Install system dependencies, including ffmpeg and necessary build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to the latest version
RUN python -m pip install --upgrade pip

# Install any needed packages specified in requirements.txt
RUN pip install -r requirements.txt

# Install any needed packages specified for Sentry
RUN pip install --upgrade 'sentry-sdk[django]'

# Define a build-time variable for the Sentry release.
ARG SENTRY_RELEASE=dev
ENV SENTRY_RELEASE=$SENTRY_RELEASE

# Copy the rest of the application code into the container
COPY . .

# Expose the port the app will run on
EXPOSE 8000

# Install Gunicorn
RUN pip install gunicorn

# Start the application using Gunicorn with 3 workers
CMD ["gunicorn", "--bind", ":8000", "--workers", "1", "--limit-request-line", "8190", "--limit-request-field_size", "104857600","playground.wsgi:application"]

