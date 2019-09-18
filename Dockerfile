FROM prairielearn/centos7-base

RUN    yum -y install epel-release \
	&& yum -y install wget \
  && yum -y install java-1.8.0-openjdk-devel

ENV LEIN_VERSION=2.8.1
ENV LEIN_INSTALL=/usr/bin/

# Download the whole repo as an archive
RUN mkdir -p $LEIN_INSTALL \
  && wget -q https://raw.githubusercontent.com/technomancy/leiningen/$LEIN_VERSION/bin/lein-pkg \
  && echo "Comparing lein-pkg checksum ..." \
  && echo "019faa5f91a463bf9742c3634ee32fb3db8c47f0 *lein-pkg" | sha1sum -c - \
  && mv lein-pkg $LEIN_INSTALL/lein \
  && chmod 0755 $LEIN_INSTALL/lein \
  && wget -q https://github.com/technomancy/leiningen/releases/download/$LEIN_VERSION/leiningen-$LEIN_VERSION-standalone.zip \
  && wget -q https://github.com/technomancy/leiningen/releases/download/$LEIN_VERSION/leiningen-$LEIN_VERSION-standalone.zip.asc \
  && rm leiningen-$LEIN_VERSION-standalone.zip.asc \
  && mkdir -p /usr/share/java \
  && mv leiningen-$LEIN_VERSION-standalone.zip /usr/share/java/leiningen-$LEIN_VERSION-standalone.jar

ENV PATH=$PATH:$LEIN_INSTALL
ENV LEIN_ROOT 1

RUN mkdir -p /tmp/project
RUN chown -R ag /tmp/project

# Install clojure 1.8.0 so users don't have to download it every time
RUN cd /tmp/project \
    && sudo -u ag echo '(defproject dummy "" :dependencies [[org.clojure/clojure "1.8.0"] [org.clojure/data.json "0.2.6"] [quil "2.8.0"] [midje "1.7.0"]])' > project.clj \
  && sudo -u ag lein deps && sudo -u ag rm project.clj

RUN sudo -u ag echo '{:user {:plugins [[lein-exec "0.3.7"]]}}' > /home/ag/.lein/profiles.clj
RUN sudo -u ag lein exec -e '(println "Completed Setting Up lein-exec")'
