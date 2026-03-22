# Use the official Material image
FROM squidfunk/mkdocs-material:latest

# Set the working directory
WORKDIR /docs

# Copy all your files (docs, mkdocs.yml, etc.) into the container
COPY . .

# Build the static site during the image creation phase
RUN mkdocs build --clean

# Expose the port
EXPOSE 8000

# Serve the STATIC 'site' folder using Python's built-in server
# This avoids the "live reload" issues on a VPS
CMD ["python3", "-m", "http.server", "8000", "--directory", "site"]