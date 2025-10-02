# Use official PostgreSQL 17 image
FROM postgres:17

# Install git and bash for backup scripts
RUN apt-get update && apt-get install -y git bash && rm -rf /var/lib/apt/lists/*

# Copy backup scripts
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Expose Postgres port
EXPOSE 5432

# Use default Postgres entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]
