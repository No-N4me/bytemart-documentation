FROM squidfunk/mkdocs-material:latest

# Set working directory
WORKDIR /docs

# Copy everything from your repo
COPY . .

# Clear the entrypoint so we can run shell commands
ENTRYPOINT []

# 1. Build the site
# 2. We use 'ls -la site' to verify the index.html exists in the logs
RUN mkdocs build --clean && ls -la site

# 3. Serve the folder. 
# IMPORTANT: Use '0.0.0.0' so it's accessible outside the container
CMD ["python", "-m", "http.server", "8000", "--bind", "0.0.0.0", "--directory", "site"]