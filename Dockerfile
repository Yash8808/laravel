FROM composer:1.6.5 as build

WORKDIR /app
COPY . /app
RUN composer install


FROM ubuntu
RUN sed -i'' 's/archive\.ubuntu\.com/us\.archive\.ubuntu\.com/' /etc/apt/sources.list
RUN apt-get update 
ENV TZ=Asia/Kolkata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


RUN apt-get install -y apache2 \
    -y apache2-utils

RUN apt-get clean

RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:ondrej/php 
RUN apt-get update 

RUN apt-get -y install php7.4 \
    -y php7.4-cli php7.4-json php7.4-common php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml php7.4-bcmath 
    
    
COPY --from=build /app /app
COPY vhost.conf /etc/apache2/sites-available/000-default.conf
RUN chown -R www-data:www-data /app \
    && a2enmod rewrite

EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]