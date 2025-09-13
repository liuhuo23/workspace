# Multi-stage build for OpenResty with Lua support
FROM ubuntu:20.04 AS builder

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpcre3-dev \
    libssl-dev \
    zlib1g-dev \
    wget \
    git \
    libxml2-dev \
    libxslt-dev \
    libgd-dev \
    libgeoip-dev \
    libperl-dev \
    libbrotli-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and extract OpenResty source
WORKDIR /tmp
RUN wget https://openresty.org/download/openresty-1.21.4.1.tar.gz \
    && tar -zxvf openresty-1.21.4.1.tar.gz

# Download ngx_brotli
RUN git clone https://github.com/google/ngx_brotli.git \
    && cd /tmp/ngx_brotli && git submodule update --init

# Download nginx-module-vts
RUN git clone https://github.com/vozlt/nginx-module-vts.git

# Download nginx-rtmp-module
RUN git clone https://github.com/arut/nginx-rtmp-module.git
# Configure, build, and install OpenResty with additional modules
WORKDIR /tmp/openresty-1.21.4.1
RUN ./configure \
    --prefix=/usr/local/openresty \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --with-http_gzip_static_module \
    --with-http_gunzip_module \
    --with-http_auth_request_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_geoip_module \
    --with-http_image_filter_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_ssl_preread_module \
    --with-pcre \
    --with-pcre-jit \
    --with-debug \
    --add-module=/tmp/ngx_brotli \
    --add-module=/tmp/nginx-module-vts \
    --add-module=/tmp/nginx-rtmp-module \
    && make \
    && make install

# Final stage
FROM ubuntu:20.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libpcre3 \
    zlib1g \
    libssl1.1 \
    libxml2 \
    libxslt1.1 \
    libgd3 \
    libgeoip1 \
    libperl5.30 \
    libbrotli1 \
    git \
    make \
    && rm -rf /var/lib/apt/lists/*

# Copy OpenResty from builder stage
COPY --from=builder /usr/local/openresty /usr/local/openresty


# Create nginx user
RUN useradd -r -s /sbin/nologin nginx

# Expose ports
EXPOSE 80 443

# Set working directory
WORKDIR /usr/local/openresty

# Set OpenResty path for runtime
ENV PATH=/usr/local/openresty/bin:/usr/local/openresty/nginx/sbin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/openresty/luajit/lib
# 设置 Lua 搜索路径，确保 resty.core 能被找到
ENV LUA_PATH="/usr/local/openresty/lualib/?.lua;/usr/local/openresty/lualib/?/init.lua;;"

# Start OpenResty
CMD ["/usr/local/openresty/nginx/sbin/nginx", "-g", "daemon off;"]