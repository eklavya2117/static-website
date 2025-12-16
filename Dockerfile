FROM httpd:2.4

# Clean default Apache content
RUN rm -rf /usr/local/apache2/htdocs/*

# Copy build output (from Jenkins Build stage)
COPY dist/ /usr/local/apache2/htdocs/

# Expose Apache port
EXPOSE 80
