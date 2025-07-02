# Use official Python runtime as base image
FROM python:3.11-slim

# Set working directory in container
WORKDIR /app

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    git \
    curl \
    wget \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Jupyter and JupyterLab
RUN pip install --no-cache-dir \
    jupyter \
    jupyterlab \
    notebook

# Create requirements file for Python dependencies
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Create directories for application
RUN mkdir -p /app/gee_results /app/data

# Copy application files
COPY . .

# Install Jupyter extensions for widgets (fix for JupyterLab 4+)
RUN pip install jupyter_server_proxy && \
    jupyter lab build --dev-build=False --minimize=False

# Create a non-root user for security
RUN useradd -m -u 1000 monitoring && \
    chown -R monitoring:monitoring /app

# Switch to non-root user
USER monitoring

# Expose port for Jupyter
EXPOSE 8888

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8888 || exit 1

# Default command - start Jupyter Lab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]
