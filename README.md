# 多服务 Docker Compose 环境
## 目录结构

```
├── .env                  # 环境变量配置
├── .gitignore            # Git 忽略文件
├── README.md             # 项目说明文档
├── config/               # 各服务配置目录
│   ├── mysql/            # MySQL 配置
│   ├── nginx/            # Nginx 配置
│   ├── rabbitmq/         # RabbitMQ 配置
│   └── redis/            # Redis 配置
├── data/                 # 各服务持久化数据目录
│   ├── elasticsearch/    # Elasticsearch 数据
│   ├── mongodb/          # MongoDB 数据
│   ├── mysql/            # MySQL 数据
│   ├── nginx/            # Nginx 数据
│   ├── rabbitmq/         # RabbitMQ 数据
│   └── redis/            # Redis 数据
├── docker-compose.yml    # Compose 主配置文件
├── docker-entrypoint.sh  # Nginx 启动脚本（如有）
├── script/               # 辅助脚本目录
│   ├── goinstall.sh      # Go 相关安装脚本
│   └── local_docker.sh   # 本地 Docker 启动脚本
```
├── docker-entrypoint.sh  # Nginx 启动脚本（如有）
├── script/               # 辅助脚本目录
│   ├── goinstall.sh      # Go 相关安装脚本
│   └── local_docker.sh   # 本地 Docker 启动脚本
```

## 快速开始

1. 安装 Docker 和 Docker Compose
2. 配置 `.env` 文件，按需修改各服务参数和挂载路径
3. 启动服务：

```sh
docker-compose up -d
```

4. 访问服务：
	 - Nginx: http://localhost:80
	 - MySQL: localhost:3306，用户名/密码见 .env
	 - Redis: localhost:6379
	 - RabbitMQ 管理界面: http://localhost:15672

## 主要服务说明

- **Nginx**：负载均衡可自定义配置
- **MySQL**：支持自定义 root 密码、数据持久化、配置挂载
- **Redis**：支持配置挂载和数据持久化
- **RabbitMQ**：支持自定义用户名密码、配置挂载和数据持久化

## 常用命令

- 启动所有服务：
	```sh
	docker-compose up -d
	```
- 停止所有服务：
	```sh
	docker-compose down
	```
- 查看服务日志：
	```sh
	docker-compose logs -f
	```

## 注意事项

- 请确保 `.env` 文件和各配置目录已正确设置。
- 如需自定义服务配置，请修改 `config/` 下对应文件。
- 数据目录建议添加到 `.gitignore`，避免数据泄露。

---

# 问题
## 1. elasticsearch 没有权限写入文件
```shell
# 以下命令进入容器内
docker compose run -it elasticsearch /bin/bash
id elasticsearch

# 退出
sudo chown -R 1000:1000 ./data/elasticsearch
```
