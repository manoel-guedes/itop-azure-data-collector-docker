# Use the official PHP 8 CLI image
FROM php:8.1-cli

# Copy the iTop Hub extension zip file to the container
COPY combodo-azure-data-collector-2_0_1.zip params.local.xml /tmp/


# Update package lists, install necessary packages, and clean up:
# - Update apt-get package lists
# - Install unzip and libxml2-dev packages
# - Install PHP SOAP extension
# - Unzip the Azure data collector package to the specified directory
# - Move the configuration file to the appropriate location
# - Remove the zip file to clean up
# - Clean up apt-get cache and remove unnecessary files to reduce image size
RUN apt-get update && apt-get install -y unzip libxml2-dev \
	&& docker-php-ext-install soap \
	&& unzip /tmp/combodo-azure-data-collector-2_0_1.zip -d /var/www/html/ \
	&& mv /tmp/params.local.xml /var/www/html/combodo-azure-data-collector/conf/params.local.xml \
	&& rm /tmp/combodo-azure-data-collector-2_0_1.zip \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Load environment variables from the .env file and set them as Docker environment variables.
# The `cat .env | xargs` command reads the .env file and converts its contents into a format
# that can be used by the `ENV` instruction to set multiple environment variables at once.
ENV $(cat .env | xargs)

# Set the working directory to /var/www/html/combodo-azure-data-collector
WORKDIR /var/www/html/combodo-azure-data-collector

# Run the Azure data collector and terminate the container
CMD ["php", "exec.php"]