FROM wesen1/assaultcube-lua-server:1.2.0.2-lib-lua
RUN apt-get install -y luarocks && \
    luarocks install ac-luaserver && \
    luarocks install luaorm && \
    luarocks install sleep && \
    apt-get install -y lua-sql-mysql && \
    apt-get autoremove -y luarocks
COPY ./src/config /ac-server/lua/config
COPY ./src/wesenGemaMod /ac-server/lua/scripts/wesenGemaMod
COPY ./src/main.lua /ac-server/lua/scripts/main.lua
