# Need a custom image here so that we can incorporate an npm build too
# Alpine is super light
FROM alpine:3.5

# Download and install packages
RUN apk add -U nginx python make g++ nodejs bash

# Create directories
#   /working is the build directory
#   /static is the directory linked to nginx (serves static content)
RUN mkdir -p /var/www/acm/working && \
    mkdir -p /var/www/acm/static && \
    mkdir -p /var/www/acm/static/build

# Install the required packages to build the frontend
WORKDIR /var/www/acm/working
COPY *.json /var/www/acm/working/
RUN /usr/bin/node --max_semi_space_size=8 \
                  --max_old_space_size=298 \
                  --max_executable_size=248 \
                  /usr/bin/npm install

# Copy the source files
COPY static/ /var/www/acm/working/static/
COPY src/ /var/www/acm/working/src/
COPY .babelrc *.js Makefile /var/www/acm/working/

# build and copy files to server root
RUN make build-static && \
    cp -rv static/* ../static/ && \
    cp -rv lib/build/* ../static/build/

# Copy the configuration file
RUN mkdir -p /run/nginx
COPY conf/ /etc/nginx/
COPY start.sh /var/www/acm
WORKDIR /var/www/acm/static

# Run the server
#CMD ["nginx", "-g", "daemon off;"]
CMD ["/var/www/acm/start.sh"]
