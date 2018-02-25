FROM php:7.0.27-apache

# Dependencies and maybe some debugging
RUN apt-get update && apt-get install -y curl git vim && rm -rf /var/lib/apt/lists/*

# Set up PHP and apache
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load
RUN touch /usr/local/etc/php/php.ini
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf
RUN docker-php-ext-install pdo pdo_mysql

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# Copy project to folder
RUN chmod 777 /var/www
ADD . /var/www/html
WORKDIR /var/www/html

# Run composer
USER www-data
RUN composer install
USER root

# Set owner for PHP
RUN chown -R www-data:www-data /var/www/html

# Connect to MySQL
RUN sed -i "s|host: 'localhost'|host: 'tdt4237public_mysql_1'|g" /var/www/html/App/config.yml
RUN sed -i "s|password: ''|password: 'barePassord'|g" /var/www/html/App/config.yml
