FROM openjdk:8-jdk

ENV FASTCATSEARCH_CONSOLE_HOME /usr/local/fastcatsearch-console
ENV PATH $FASTCATSEARCH_CONSOLE_HOME:$PATH

RUN mkdir -p "$FASTCATSEARCH_CONSOLE_HOME"

ARG LIB=target
ARG FASTCATSEARCH_CONSOLE_VERSION=3.0.0

WORKDIR "$FASTCATSEARCH_CONSOLE_HOME"

COPY $LIB/fastcatsearch-console-$FASTCATSEARCH_CONSOLE_VERSION.tar.gz "$FASTCATSEARCH_CONSOLE_HOME"

RUN set -x \
	\
	&& tar -xzvf fastcatsearch-console-$FASTCATSEARCH_CONSOLE_VERSION.tar.gz --strip-components=1 \
	&& rm -f fastcatsearch-console-$FASTCATSEARCH_CONSOLE_VERSION.tar.gz

RUN ls -al

EXPOSE 8080
ENTRYPOINT ["/bin/bash", "run-console.sh"]