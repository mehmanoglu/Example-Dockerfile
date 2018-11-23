FROM centos:latest

MAINTAINER Elchin Nazarov <e.nazarov@example.com>

# Generic labels
LABEL Component="httpd" \ 
      Name="httpd-parent" \
      Version="1.0" \
      Release="1"

# Labels consumed by OpenShift
LABEL io.k8s.description="A basic Apache HTTP Server" \ 
      io.k8s.display-name="Apache HTTP Server image" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="apache, httpd"

# DocumentRoot for Apache
ENV DOCROOT=/var/www/html \
    LANG=en_US \
    LOG_PATH=/var/log/httpd

# Need this for installing Apache from classroom yum repo

RUN   yum install -y --setopt=tsflags=nodocs --noplugins httpd && \ 
      yum clean all --noplugins -y && \
      echo "Hello from the httpd-parent container!" > ${HOME}/index.html

# Inject content into DocumentRoot
COPY src/ ${DOCROOT}/ 

EXPOSE 8080

# This stuff is needed to ensure a clean start
RUN rm -rf /run/httpd && mkdir /run/httpd

# Change Apache listen port to 8080
RUN sed -i "s/Listen 80/Listen 8080/g" /etc/httpd/conf/httpd.conf

# Change Permissions
RUN chgrp -R 0 /var/log/httpd /var/run/httpd && \
    chmod -R g=u /var/log/httpd /var/run/htt

# Run as the root user
USER 1001

# Launch apache daemon
CMD /usr/sbin/apachectl -DFOREGROUND
