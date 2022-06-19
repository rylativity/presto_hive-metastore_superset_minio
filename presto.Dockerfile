FROM openjdk:8-jre

# Presto version will be passed in at build time
ARG PRESTO_VERSION=0.273.3

# Set the URL to download
ARG PRESTO_BIN=https://repo1.maven.org/maven2/com/facebook/presto/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz

# Update the base image OS and install wget and python
RUN apt-get update
RUN apt-get install -y wget python less

# Download Presto and unpack it to /opt/presto
RUN wget --quiet ${PRESTO_BIN}
RUN mkdir -p /opt
RUN tar -xf presto-server-${PRESTO_VERSION}.tar.gz -C /opt
RUN rm presto-server-${PRESTO_VERSION}.tar.gz
RUN ln -s /opt/presto-server-${PRESTO_VERSION} /opt/presto

# # Replace the httpclient jar < 4.5.9 and replace with updated httpclient
# ARG HTTPCLIENT_VERSION=4.5.13
# RUN rm /opt/presto/plugin/hive-hadoop2/httpclient-4.*.*.jar && \
#      wget --quiet https://search.maven.org/remotecontent?filepath=org/apache/httpcomponents/httpclient/${HTTPCLIENT_VERSION}/httpclient-${HTTPCLIENT_VERSION}.jar -O /opt/presto/plugin/hive-hadoop2/httpclient-${HTTPCLIENT_VERSION}.jar

# Get AWS SDK Bundle JAR and hadoop-aws JAR
# ARG AWS_JAVA_SDK_VERSION=1.12.230
# RUN wget --quiet https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar -O /opt/presto/plugin/hive-hadoop2/aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar
# ARG HADOOP_VERSION=3.2.0
# RUN wget --quiet https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar -O /opt/presto/plugin/hive-hadoop2/hadoop-aws-${HADOOP_VERSION}.jar && \
#      wget --quiet https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar -O /opt/presto/plugin/hive-hadoop2/hadoop-aws-${HADOOP_VERSION}.jar 


# Create a Folder to hold the FileHiveMetastore
RUN mkdir /etc/hive_metastore

# Copy configuration files on the host into the image
COPY presto /opt/presto/etc

# Download the Presto CLI and put it in the image
RUN wget --quiet https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar
RUN mv presto-cli-${PRESTO_VERSION}-executable.jar /usr/local/bin/presto && chmod +x /usr/local/bin/presto

# Specify the entrypoint to start
ENTRYPOINT /opt/presto/bin/launcher run