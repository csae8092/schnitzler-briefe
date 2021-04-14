FROM python:3.8-buster

USER root
WORKDIR /app

RUN apt-get update && apt-get -y install git ant && pip install -U pip
RUN pip install acdh-tei-pyutils==0.9.0

COPY . .
RUN cd 
# RUN denormalize-indices -t "erwähnt in " -i "/app/data/indices/*.xml" -f "/app/data/editions/*.xml" -x ".//tei:title[@level='a']/text()"
RUN ant

RUN ant -f /app/build.xml

# START STAGE 2
FROM existdb/existdb:release
ENV JAVA_OPTS="-Xms256m -Xmx2048m -XX:+UseConcMarkSweepGC -XX:MaxHeapFreeRatio=20 -XX:MinHeapFreeRatio=10 -XX:GCTimeRatio=20"

COPY --from=0 /app/build/*.xar /exist/autodeploy

EXPOSE 8080 8443

RUN [ "java", \
    "org.exist.start.Main", "client", "-l", \
    "--no-gui",  "--xpath", "system:get-version()" ]

CMD [ "java", "-jar", "start.jar", "jetty" ]
