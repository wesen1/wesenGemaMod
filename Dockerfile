FROM wesen1/assaultcube-lua-server:1.2.0.2-lib-lua
RUN apt-get --allow-releaseinfo-change-suite update && \
    apt-get install -y luarocks && \
    apt-get install libmaxminddb0 libmaxminddb-dev && \
    apt-get install make && \
    luarocks install ac-luaserver && \
    luarocks install luaorm && \
    luarocks install sleep && \
    luarocks install lua-maxminddb LIBMAXMINDDB_INCDIR=/usr/include/x86_64-linux-gnu && \
    apt-get install -y lua-sql-mysql && \
    apt-get autoremove -y libmaxminddb-dev && \
    apt-get autoremove -y make && \
    apt-get autoremove -y luarocks
COPY ./src/config /ac-server/lua/config
COPY ./src/wesenGemaMod /ac-server/lua/scripts/wesenGemaMod
COPY ./src/main.lua /ac-server/lua/scripts/main.lua
