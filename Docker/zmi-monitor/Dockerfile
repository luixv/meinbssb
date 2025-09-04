FROM alpine:3.19

# Install required packages
RUN apk add --no-cache \
    curl \
    bash \
    nginx \
    supervisor \
    tzdata

# Create necessary directories
RUN mkdir -p /var/www/html /var/log/supervisor /etc/supervisor.d /var/log

# Copy monitoring script
COPY monitor_zmi.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/monitor_zmi.sh
RUN sed -i 's/\r$//' /usr/local/bin/monitor_zmi.sh

# Copy health check script
COPY health-check.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/health-check.sh
RUN sed -i 's/\r$//' /usr/local/bin/health-check.sh



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
ENV TZ=Europe/Berlin

# Create initial CSV file with header
RUN echo "Timestamp,Target_URL,HTTP_Code,Response_Time_s,Status_Message" > /var/www/html/data/https_monitor.csv

# Note: Monitoring is now handled by a background loop in startup.sh instead of cron

# Create a startup script to handle monitoring and supervisor
RUN echo '#!/bin/bash' > /usr/local/bin/startup.sh && \
    echo 'export TZ=Europe/Berlin' >> /usr/local/bin/startup.sh && \
    echo 'echo "Starting ZMI Monitor Container..."' >> /usr/local/bin/startup.sh && \
    echo 'echo "Current time: $(date)"' >> /usr/local/bin/startup.sh && \
    echo 'echo "Environment variables:"' >> /usr/local/bin/startup.sh && \
    echo 'echo "TARGET_URL: $TARGET_URL"' >> /usr/local/bin/startup.sh && \
    echo 'echo "Running initial monitoring check..."' >> /usr/local/bin/startup.sh && \
    echo '/usr/local/bin/monitor_zmi.sh' >> /usr/local/bin/startup.sh && \
    echo 'echo "Starting monitoring loop in background..."' >> /usr/local/bin/startup.sh && \
    echo 'mkdir -p /var/log' >> /usr/local/bin/startup.sh && \
    echo 'while true; do sleep 300; /usr/local/bin/monitor_zmi.sh; done &' >> /usr/local/bin/startup.sh && \
    echo 'echo "Starting supervisor..."' >> /usr/local/bin/startup.sh && \
    echo 'exec /usr/bin/supervisord -c /etc/supervisor.d/supervisord.conf' >> /usr/local/bin/startup.sh && \
    chmod +x /usr/local/bin/startup.sh

# Expose port 80
EXPOSE 80

# Start with our startup script
CMD ["/usr/local/bin/startup.sh"]
