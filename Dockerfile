# 1. Use the official Material image
FROM squidfunk/mkdocs-material:latest

# 2. Set the working directory
WORKDIR /docs

# 3. Copy your project files
COPY . .

# 4. CRITICAL: Reset the entrypoint
# The base image has ENTRYPOINT ["mkdocs"]. We clear it so CMD works normally.
ENTRYPOINT []

# 5. Build the static site during the image build
RUN mkdocs build --clean

# 6. Serve the static folder using Python
# Using 'python' instead of 'python3' as the base image usually aliases it
CMD ["python", "-m", "http.server", "8000", "--directory", "site"]