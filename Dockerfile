# ChurnShield API - Dockerfile for Render
FROM rocker/r-ver:4.3.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('plumber'), repos='https://cloud.r-project.org/')"

# Create app directory
WORKDIR /app

# Copy the API file
COPY plumber.R /app/plumber.R

# Expose port (Render uses 10000 by default, but we'll use PORT env var)
EXPOSE 10000

# Run the API
CMD ["R", "-e", "plumber::plumb('plumber.R')$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', 10000)))"]
