# Nginx 配置文档

本项目 Nginx 配置采用模块化设计，支持多站点、静态资源、反向代理和自定义扩展。

## 目录结构

```
config/
│   └── nginx/
│       ├── nginx.conf         # 主配置文件，包含全局设置和 conf.d 目录加载
│       ├── mime.types         # 静态资源类型定义
│       └── conf.d/
│           └── default.conf   # 默认站点及应用扩展配置
```

## 主配置文件 nginx.conf 示例

```nginx
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
	worker_connections  1024;
}

http {
	include       /etc/nginx/mime.types;
	default_type  application/octet-stream;
	sendfile        on;
	keepalive_timeout  65;

	# 加载所有自定义站点和应用配置
	include /etc/nginx/conf.d/*.conf;
}
```


## 反向代理配置示例

你可以在 conf.d 目录下新建 proxy.conf 文件，或在任意 server 配置块中添加如下反向代理配置：

```nginx
server {
	listen 80;
	server_name www.example.com;

	location /api/ {
		proxy_pass http://backend-api:8080/;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto $scheme;
	}
}
```

说明：
- location /api/ 表示所有以 /api/ 开头的请求将被转发到后端服务 backend-api:8080。
- proxy_pass 后面的地址可以是容器名、IP 或域名。
- proxy_set_header 保证后端能获取真实请求信息。


你可以在 conf.d 目录下新建一个 lb.conf 文件，或直接在 default.conf 中添加如下负载均衡配置：

```nginx
upstream app_servers {
	server app1:80;
	server app2:80;
	# 可继续添加更多后端应用
}

server {
	listen 80;
	server_name localhost;

	location / {
		proxy_pass http://app_servers;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto $scheme;
	}
}
```

说明：
- upstream 定义后端应用池，支持轮询、权重等多种负载均衡策略。
- location / 通过 proxy_pass 实现反向代理和负载均衡。
- proxy_set_header 保证后端应用能获取真实请求信息。

## 默认站点配置 default.conf 示例

```nginx
server {
	listen 80;
	server_name localhost;
	root /usr/share/nginx/www;

	# 默认静态网页
	location / {
		index  index.html index.htm;
	}

	# 网站 icon 图标
	location = /favicon.ico {
		root /usr/share/nginx/www;
		access_log off;
		log_not_found off;
	}

	# 应用1，访问 /app1/
	location /app1/ {
		alias /usr/share/nginx/app1/;
		index index.html index.htm;
	}

	# 应用2，访问 /app2/
	location /app2/ {
		alias /usr/share/nginx/app2/;
		index index.html index.htm;
	}
}
```

## 静态资源类型 mime.types 示例

（已包含常用 web 类型，详见 config/nginx/mime.types 文件）

## 扩展说明

- 你可以在 conf.d 目录下添加更多 .conf 文件，实现多站点或反向代理。
- root 可提升到 server 级别，location 可用 alias 指定不同应用目录。
- favicon.ico、favicon.svg 可放在 www 目录下，自动被浏览器识别。
- 支持自定义 404、301 跳转、HTTPS 等高级配置。

## 常见问题

- 配置修改后需重载 Nginx：
  ```sh
  docker-compose exec nginx nginx -s reload
  ```
- 路径挂载需与 docker-compose.yml 保持一致。
- 端口冲突请检查 docker-compose.yml 的 ports 配置。
