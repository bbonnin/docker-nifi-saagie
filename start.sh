#!/bin/sh

#    Licensed to the Apache Software Foundation (ASF) under one or more
#    contributor license agreements.  See the NOTICE file distributed with
#    this work for additional information regarding copyright ownership.
#    The ASF licenses this file to You under the Apache License, Version 2.0
#    (the "License"); you may not use this file except in compliance with
#    the License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

scripts_dir='/opt/nifi/scripts'

su root -c "truncate -s-1 /etc/hosts && echo \" $NIFI_WEB_HTTP_HOST\" >> /etc/hosts && more /etc/hosts"

sed "s|HDFS_URL|$HDFS_URL|g" /opt/nifi/nifi-1.6.0/conf/core-site.xml.template > /opt/nifi/nifi-1.6.0/conf/core-site.xml
sed "s|HDFS_HOST|$HDFS_HOST|g" /opt/nifi/nifi-1.6.0/conf/hdfs-site.xml.template > /opt/nifi/nifi-1.6.0/conf/hdfs-site.xml

echo "=== VARS ==="
echo "HDFS_URL=$HDFS_URL"
echo "HDFS_HOST=$HDFS_HOST"
echo "NIFI_WEB_HTTP_HOST=$NIFI_WEB_HTTP_HOST"
echo "NIFI_WEB_HTTP_PORT=$NIFI_WEB_HTTP_PORT"
echo "NIFI4SAAGIE=$NIFI4SAAGIE"

echo "=== PING/CURL ==="
ping -c 3 $HDFS_HOST
curl -v $(echo $HDFS_URL | sed 's/hdfs/http/g')

echo "=== CORE-SITE ==="
cat /opt/nifi/nifi-1.6.0/conf/core-site.xml

echo "=== HDFS-SITE ==="
cat /opt/nifi/nifi-1.6.0/conf/hdfs-site.xml

echo "================="



[ -f "${scripts_dir}/common.sh" ] && . "${scripts_dir}/common.sh"

# Establish baseline properties
prop_replace 'nifi.web.http.port'               "${NIFI_WEB_HTTP_PORT:-8080}"
prop_replace 'nifi.web.http.host'               "${NIFI_WEB_HTTP_HOST:-$HOSTNAME}"
prop_replace 'nifi.remote.input.host'           "${NIFI_REMOTE_INPUT_HOST:-$HOSTNAME}"
prop_replace 'nifi.remote.input.socket.port'    "${NIFI_REMOTE_INPUT_SOCKET_PORT:-10000}"
prop_replace 'nifi.remote.input.secure'         'false'

# Check if we are secured or unsecured
case ${AUTH} in
    tls)
        echo 'Enabling Two-Way SSL user authentication'
        . "${scripts_dir}/secure.sh"
        ;;
    ldap)
        echo 'Enabling LDAP user authentication'
        # Reference ldap-provider in properties
        prop_replace 'nifi.security.user.login.identity.provider' 'ldap-provider'
        prop_replace 'nifi.security.needClientAuth' 'WANT'

        . "${scripts_dir}/secure.sh"
        . "${scripts_dir}/update_login_providers.sh"
        ;;
    *)
        if [ ! -z "${NIFI_WEB_PROXY_HOST}" ]; then
            echo 'NIFI_WEB_PROXY_HOST was set but NiFi is not configured to run in a secure mode.  Will not update nifi.web.proxy.host.'
        fi
        ;;
esac

# Continuously provide logs so that 'docker logs' can    produce them
tail -F "${NIFI_HOME}/logs/nifi-app.log" &
"${NIFI_HOME}/bin/nifi.sh" run &
nifi_pid="$!"

trap "echo Received trapped signal, beginning shutdown...;" KILL TERM HUP INT EXIT;

echo NiFi running with PID ${nifi_pid}.
wait ${nifi_pid}
