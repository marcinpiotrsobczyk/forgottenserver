FROM alpine:3.17.3 AS build
# crypto++-dev is in edge/community
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
  build-base \
  boost-dev \
  cmake \
  crypto++-dev \
  fmt-dev \
  luajit-dev \
  mariadb-connector-c-dev \
  pugixml-dev \
  samurai \
  git

COPY cmake /usr/src/forgottenserver/cmake/
COPY libdatachannel /usr/src/forgottenserver/libdatachannel/
COPY websocketpp /usr/src/forgottenserver/websocketpp/
COPY src /usr/src/forgottenserver/src/
COPY CMakeLists.txt CMakePresets.json /usr/src/forgottenserver/
WORKDIR /usr/src/forgottenserver
RUN cmake --preset default && cmake --build --config RelWithDebInfo --preset default

FROM alpine:3.17.3
# crypto++ is in edge/community
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
  boost-iostreams \
  boost-system \
  crypto++ \
  fmt \
  luajit \
  mariadb-connector-c \
  pugixml

COPY --from=build /usr/src/forgottenserver/build/tfs \
     /usr/src/forgottenserver/build/src/tests/test_matrixarea* /usr/src/forgottenserver/build/src/tests/test_xtea* \
     /bin/
COPY data /srv/data/
COPY LICENSE README.md *.dist *.sql key.pem /srv/

EXPOSE 7171 7172 7170
WORKDIR /srv
VOLUME /srv
ENTRYPOINT ["/bin/tfs"]
