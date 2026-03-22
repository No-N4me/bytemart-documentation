FROM squidfunk/mkdocs-material:latest

WORKDIR /app

# Copy the project
COPY . .

# Reset entrypoint
ENTRYPOINT []

# Build the site
RUN mkdocs build --clean

# We serve from the /app/site directory explicitly
# We use port 8000
CMD ["python", "-m", "http.server", "8000", "--bind", "0.0.0.0", "--directory", "site"]