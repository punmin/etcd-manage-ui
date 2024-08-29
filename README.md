# Etcd UI


## 功能介绍

etcd-manage 是一个用go编写的etcd管理工具，具有友好的界面(类似阿里云后台)，管理key就像管理本地文件一样方便。支持简单权限管理区分只读和读写权限。

开源地址： [https://github.com/etcd-manage](https://github.com/etcd-manage)

**备注**

1. 用helm部署时注意修改mysql连接相关信息，可不修改使用默认安装直接使用
2. 将sql文件导入到mysql数据库，默认用户 admin/111111 [etcd-manage.sql](https://raw.githubusercontent.com/cloudnativeapp/charts/master/submitted/etcd-manage/sql/etcd-manage.sql)
3. 此程序为2.0版本，实现1.0功能 1.0项目地址 [https://github.com/shiguanghuxian/etcd-manage](https://github.com/shiguanghuxian/etcd-manage)
4. 下一步开发对中英双语言做全面支持，当前对中文支持友好。
5. 当前只实现了etcd v3 api管理key v2在路上。
6. 在使用时可直接修改默认的两个etcd连接地址为真实可用地址即可开始体验。

**开发说明**

- 当只需要修改前端项目时，为了便于调试运行，后端使用当前运行的环境，前端代码通过nocalhost运行在k8s的开发环境容器，通过nginx代理前后端解决跨域，使用nocalhost将nginx forward到本地

- 配置说明
```shell

#配置静态资源路径前缀
config\index.js
assetsPublicPath: '/ui/'

#配置基础路由前缀和访问地址
package.json
"dev": "webpack-dev-server --content-base /ui/ --inline --progress --config build/webpack.dev.conf.js --host 0.0.0.0 --port 8080"

#配置api服务地址（nginx forward到本地的地址）
src\config\index.js
BaseUrl: 'http://127.0.0.1:10280'

#通过nginx分离前后端
cat >  /etc/nginx/conf.d/default.conf << EOF
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    location /ui {
        #ui pod nocalhost调试模式启动
        proxy_pass   http://ui_pod_ip:8080;
    }

    location / {
        #server pod 当前生产正在使用的版本
        proxy_pass   http://server_pod_ip:10280;
    }
}
EOF
```

## HELM 安装使用

提示：安装后通过kubectl get pods看到两个pod专题都是Running表示服务可用，首次mysql需要初始化会慢一些，大概1分钟。

```shell
helm install my-etcd-manage etcd-manage
或
cd path/etcd-manage
helm package .
helm install my-etcd-manage etcd-manage-1.0.0.tgz

```

运行后看到输出：

```shell
NAME: my-etcd-manage
LAST DEPLOYED: 2019-08-26 20:16:23.182943 +0800 CST m=+0.068774555
NAMESPACE: default
STATUS: deployed

NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods -l "app=etcd-manage,release=my-etcd-manage" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:10280 to use your application"
  kubectl port-forward $POD_NAME 10280:10280

# kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
my-etcd-manage-f4bc496f5-bpg99        1/1     Running   2          25s
my-etcd-manage-mysql-5577cd9b-4nqr2   1/1     Running   0          25s

```

执行完 NOTES 中提示命令的命令即可在浏览器中访问 `http://127.0.0.1:10280/ui` 查看。注意url端口后边路径为/ui

默认用户 admin/111111

如果NOTES命令执行错误可执行

```shell
kubectl port-forward my-etcd-manage-f4bc496f5-bpg99 10280:10280 // my-etcd-manage-f4bc496f5-bpg99 为 kubectl get pods 中获取的值
```

## HELM 使用参数

使用数据库参数可使用自己mysql服务，默认使用依赖的charts中mysql服务，如果使用自己mysql请导入sql文件 [etcd-manage.sql](https://raw.githubusercontent.com/cloudnativeapp/charts/master/submitted/etcd-manage/sql/etcd-manage.sql)

```shell
helm install my-etcd-manage etcd-manage --set database.address="你的数据库ip地址" --set database.port=3306 --set database.user="user" --set database.passwd="密码" --set database.db_name="etcd-manage"
```

**参数介绍**

| 参数名 | 简述 | 示例 |
| ----- | ----- | ---|
|  database.address | mysql数据库地址 | 192.168.1.88 |
|  database.port | mysql数据库端口 | 3306 |
|  database.user | mysql用户名 | root |
|  database.passwd | mysql用户密码 | z123456 |
|  database.db_name | 导入etcd-manage.sql的数据库 | etcd-manage |


## 效果演示

etcd服务列表管理

![](https://raw.githubusercontent.com/cloudnativeapp/charts/master/submitted/etcd-manage/imgs/etcd-server.png)

key 管理

![](https://raw.githubusercontent.com/cloudnativeapp/charts/master/submitted/etcd-manage/imgs/keys.png)

key 编辑

![](https://raw.githubusercontent.com/cloudnativeapp/charts/master/submitted/etcd-manage/imgs/key-edit.png)

key 查看

![](https://raw.githubusercontent.com/cloudnativeapp/charts/master/submitted/etcd-manage/imgs/key-show.png)

用户管理

![](https://raw.githubusercontent.com/cloudnativeapp/charts/master/submitted/etcd-manage/imgs/user.png)
