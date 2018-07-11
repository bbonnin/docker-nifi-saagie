FROM apache/nifi

COPY /start.sh /opt/nifi/scripts
COPY /nifi-framework-nar-1.6.0.nar /opt/nifi/nifi-1.6.0/lib 
COPY /core-site.xml.template /opt/nifi/nifi-1.6.0/conf
COPY /hdfs-site.xml.template /opt/nifi/nifi-1.6.0/conf

USER root
