# ansible-deploy-php

> 基于 Ansible 的 PHP 应用环境自动安装与持续部署脚本

---

## 目录结构

```bash
├── deploy-git.yml           # 基于 Git 拉取代码的部署 Playbook
├── deploy.yml               # 正式部署应用的 Playbook（通常结合版本号发布）
├── group_vars/
│   └── webservers.yml       # Web 服务器组变量配置（PHP 版本、路径、用户等）
├── hosts/
│   └── webservers.yml       # 目标服务器清单，定义主机和连接信息
├── install.yml              # 安装 PHP、Nginx 及依赖环境的 Playbook
├── LICENSE                  # 版权许可文件
├── Makefile                 # 常用命令快捷执行（如安装、部署、回滚）
├── README.md                # 项目说明文档
├── rollback.yml             # 回滚应用版本的 Playbook
└── templates/
    ├── nginx-php.conf.j2   # Nginx PHP 站点配置模板
    └── www.conf.j2         # PHP-FPM 池配置模板
```

## 介绍

这是一个基于 Ansible 的自动化部署项目，适用于快速搭建和管理 PHP 应用环境，支持：

- 自动安装 PHP 及常用扩展、Nginx、Git 等基础环境
- PHP-FPM 进程池配置模板管理
- 按时间戳版本部署代码，软链接切换实现平滑上线
- Nginx 配置模板动态生成，绑定域名
- 应用回滚支持
- 使用 Makefile 简化常用操作

## 使用说明

### 环境准备

1. 编辑 `hosts/webservers.yml`，配置目标服务器信息及连接方式（用户名、密码或密钥）。
2. 编辑 `group_vars/webservers.yml`，配置全局变量如 PHP 版本、应用路径、域名等。

## 常用命令

~~~
#测试目标主机的网络连通性。
make ping

# 安装 PHP 和 Nginx 环境。
make install

# 部署新的应用版本。
make deploy

# 回滚到上一个版本（假设是备份的版本或本地更改的某个历史版本）。
make rollback

# 通过 Git 拉取代码并部署应用，不支持回滚，需要通过 git_version 来控制版本的选择（可以是分支、标签或提交哈希）。
make deploy-git
~~~

## 变量说明（`group_vars/webservers.yml`）

~~~
# 应用部署根目录，代码将拉取到此目录的 releases 子目录
app_path: "/var/www/php-app"  

# 应用代码仓库地址，支持 HTTPS 或 SSH
app_repo: "https://github.com/example/php-app.git"  

# git_version 可以指定分支、标签或提交哈希来控制部署版本。
git_version: "main"  

# 绑定的域名，用于 Nginx 配置等
domain: www.example.com  

# 应用运行用户和用户组，确保权限正确
app_user: "www-data"  
app_group: "www-data"  


# PHP 版本，安装与配置相关的关键变量
php_version: "8.1"  

# PHP-FPM 池配置：最大子进程数，控制并发处理能力
pm_max_children: 20  

# PHP-FPM 池配置：启动时启动的进程数
pm_start_servers: 5  

# PHP-FPM 池配置：保持的最小空闲进程数
pm_min_spare_servers: 3  

# PHP-FPM 池配置：保持的最大空闲进程数
pm_max_spare_servers: 10  

# PHP 配置项：POST 请求最大数据大小（影响上传文件大小）
php_post_max_size: "100M"  

# PHP 配置项：上传文件最大大小
php_upload_max_filesize: "100M"  

# PHP 配置项：脚本最大执行时间（秒），防止超时
php_max_execution_time: "60"  
~~~

## 部署目录

在服务器上，应用的部署目录采用**多层分离设计**，以支持多版本管理和平滑发布。以变量配置示例：

~~~
app_path: /var/www/php-app
domain: www.example.com
~~~

实际目录结构如下：

```
/var/www/php-app/
└── www.example.com/
    ├── releases/                  # 代码版本存放目录，存放所有历史发布版本
    │   ├── 20250721120000/       # 按时间戳命名的唯一版本目录
    │   ├── 20250722123000/
    │   └── ...
    └── current -> releases/20250722123000   # 软链接，指向当前运行版本，Nginx 指向此目录
```

## 备注

- 部署时会自动按时间戳创建版本目录，使用软链接切换到新版本，支持平滑回滚
- 请确保目标服务器已安装 Python，且 Ansible 能通过 SSH 连接目标服务器
- 请根据实际环境修改 `hosts.yml` 中的连接信息
