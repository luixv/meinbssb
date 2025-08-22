FROM alpine:latest

# Install required packages
RUN apk add --no-cache \
    curl \
    bash \
    nginx \
    supervisor \
    cronie

# Create necessary directories
RUN mkdir -p /var/www/html /var/log/supervisor /etc/supervisor.d

# Copy monitoring script
COPY monitor_zmi.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/monitor_zmi.sh
RUN sed -i 's/\r$//' /usr/local/bin/monitor_zmi.sh

# Copy HTML dashboard
COPY history.html /var/www/html/index.html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor.d/supervisord.conf

# Create log directory for monitoring data
RUN mkdir -p /var/www/html/data

# Set environment variables
ENV TARGET_URL=https://webintern.bssb.bayern:56400/rest/zmi/api/serverping
ENV EXPECTED_HTTP_CODE=200
ENV MAX_RESPONSE_TIME=5.0
ENV CONNECT_TIMEOUT=3
ENV MAX_TIME=10
ENV LOG_FILE=/var/www/html/data/https_monitor.csv

# Create initial CSV file with header
RUN echo "Timestamp,Target_URL,HTTP_Code,Response_Time_s,Status_Message" > /var/www/html/data/https_monitor.csv

# Set up cron job to run monitoring every 5 minutes
RUN echo "*/5 * * * * /usr/local/bin/monitor_zmi.sh" > /etc/crontabs/root

# Expose port 80
EXPOSE 80

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.d/supervisord.conf"]
