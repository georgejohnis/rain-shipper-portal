# Use NGINX as the base image with multi-architecture support
FROM --platform=$TARGETPLATFORM nginx:alpine

# Set build arguments for multi-architecture support
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Add labels for better identification
LABEL maintainer="Rain Transportation Services"
LABEL app="rain-shipper-portal"
LABEL description="Rain Shipper Portal Frontend"

# Copy the frontend files to the NGINX html directory
COPY frontend/src/ /usr/share/nginx/html/

# Configure NGINX for better performance
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
