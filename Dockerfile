FROM 1alek/alpine-nginx-phpfpm

# Copy nginx configs
RUN rm -f /etc/nginx/conf.d/default.conf
ADD conf/20-vhost.conf /etc/nginx/conf.d/20-vhost.conf

# Copy Project code
RUN rm -Rf /var/www/* && mkdir -p /var/www/html/
ADD ./src/* /var/www/html/

EXPOSE 80 1234
CMD ["/start.sh"]
