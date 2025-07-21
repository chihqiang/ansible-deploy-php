# Makefile 用于统一管理 Ansible 自动化部署相关命令
export ANSIBLE_HOST_KEY_CHECKING=False
# 测试阶段：对所有主机执行 ping 模块，检测主机是否连通
ping:
	ansible all -i hosts/webservers.yml -m ping
# 安装阶段：执行安装依赖环境的 playbook，比如安装 PHP、Nginx 等
install:
	ansible-playbook -i hosts/webservers.yml install.yml
# 部署阶段：执行应用部署的 playbook，将代码拉取到服务器、配置软链接等
deploy:
	ansible-playbook -i hosts/webservers.yml deploy.yml
# 回滚阶段：执行回滚 playbook，将应用版本回退到上一个稳定版本
rollback:
	ansible-playbook -i hosts/webservers.yml rollback.yml
# 部署阶段：执行部署 Git 版本的 playbook，将代码从 Git 仓库部署到服务器
deploy-git:
	ansible-playbook -i hosts/webservers.yml deploy-git.yml
# 部署 Vue 应用的 playbook，主要用于前端应用的部署
deploy-vue:
	ansible-playbook -i hosts/webservers.yml deploy-vue.yml
