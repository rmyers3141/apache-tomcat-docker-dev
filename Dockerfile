# Define some Arguments, e.g.:
ARG base_image=redhat/ubi8

# Use UBI Standard Image
FROM ${base_image}

# Define values to be used by CATALINA_OPTS:
ARG startOptions="-Xms250m -Xmx500m"

# Add metadata, e.g.:
LABEL author=RM

# Install and setup Java under /opt
ENV JAVA_VERSION=jdk-11.0.18
ENV JAVA_HOME=/opt/${JAVA_VERSION}
ENV PATH="${JAVA_HOME}/bin:$PATH"
ADD ${JAVA_VERSION}_linux-x64_bin.tar.gz /opt

#Install and setup Tomcat under /opt
ENV TOMCAT_VERSION=10.1.8
# ENV CUSTOM_TOMCAT_VERSION=myTomcat_v1
ENV CATALINA_HOME=/opt/apache-tomcat-${TOMCAT_VERSION}
ENV CATALINA_BASE="${CATALINA_HOME}"
ADD apache-tomcat-${TOMCAT_VERSION}.tar.gz /opt
ENV PATH="${CATALINA_HOME}/bin:$PATH"

# Setup Tomcat setenv.sh -using COPY Here-Doc:
COPY <<-EOT ${CATALINA_BASE}/bin/setenv.sh
JAVA_HOME=${JAVA_HOME}
CATALINA_PID=${CATALINA_BASE}/tomcat.pid
CATALINA_OPTS="${startOptions}"
EOT

# Copy your custom Tomcat config files: 
COPY ./config/* ${CATALINA_BASE}/conf/


# Copy application (sample) to webapps here:
COPY sample.war ${CATALINA_BASE}/webapps/

# Expose Tomcat ports
EXPOSE 8080
EXPOSE 8443

##TO-DO: Healthcheck Tomcat is running.
#HEALTHCHECK --interval=60s --timeout=20s --start-period=180s \
#  CMD curl -f http://localhost/ || exit 1
# Probably can't use the following as 'ps' is missing from container image?
# CMD ps -ef | grep tomcat | grep -v grep


# Run Tomcat in the foreground:
CMD ["catalina.sh", "run"]

# TRY-LATER: Best practice is to set ENTRYPOINT to the image's main command
# and CMD as the default flag.  That way, other flags can be used, e.g.:
# ENTRYPOINT ["catalina.sh"]
# CMD ["run"]

