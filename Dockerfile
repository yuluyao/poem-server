# 从源码构建服务端程序，并运行

# 编译所用的镜像，go 1.18
FROM golang:1.19 as builder

# 编译阶段，环境变量
ENV GOPROXY="https://goproxy.cn,direct" \
    CGO_ENABLED="0" \
    GOOS="linux" \
    GOARCH="amd64"

# 指定构建过程中的工作目录
WORKDIR /app

# 先安装依赖
COPY go.mod .
COPY go.sum .
RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/go/bin \
    set -x; go mod download

# 把要编译的代码 copy 过去。（修改频率低的文件放在前面）
COPY main.go .
#COPY conf ./conf
#COPY pkg ./pkg
#COPY server ./server

# 先生成 swagger 文档，然后编译，编译生成文件：main。（生成文档耗时很少，主要是编译耗时）
RUN --mount=type=cache,target=/root/.cache/go-build --mount=type=cache,target=/go/bin \
    set -x; go build -o main .


# 运行时所用基础镜像，alpine
FROM alpine:3.16

# 容器默认时区为UTC，如需使用上海时间请启用以下时区设置命令
RUN apk add tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo Asia/Shanghai > /etc/timezone

# 使用 HTTPS 协议访问容器云调用证书安装
RUN apk add ca-certificates

## dev: 开发环境，test: 测试环境，release: 正式环境
#ENV X_ENV "dev"
## 静态图片资源，地址前缀
#ENV X_PICTURE_PREFIX "http://img.yuluyao.com/ebaye/generalicon"
## mysql
#ENV X_MYSQL_USER_NAME "ebaye_user0"
#ENV X_MYSQL_USER_PASSWD "IVSvuPZwk8Mjscri"
#ENV X_MYSQL_ADDRESS "119.29.140.217"
#ENV X_MYSQL_PORT "3306"
#ENV X_MYSQL_DB_NAME "ebaye_db"
## redis
#ENV X_REDIS_ADDRESS "119.29.140.217"
#ENV X_REDIS_PORT "6379"
#ENV X_REDIS_PASSWD "doomredis"


# 指定运行时的工作目录
WORKDIR /app

# 将构建产物/app/main拷贝到运行时的工作目录中
COPY --from=builder /app/main /app/

EXPOSE 7716

# 执行启动命令
CMD ["/app/main"]
