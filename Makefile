
IMAGE_NAME := etcd-manage-ui
DOCKER_BUILD_CONTEXT := .


default:
	@echo 'Usage of make: [ build | run | go | clean ]'

build: 
	npm run build

docker_build:
	docker build -t $(IMAGE_NAME) $(DOCKER_BUILD_CONTEXT)
	docker create --name etcd-manage-ui-tmp $(IMAGE_NAME)
	rm -f tpls/tpls.go
	docker cp etcd-manage-ui-tmp:/app/tpls.go tpls/tpls.go
	docker rm etcd-manage-ui-tmp	

run:
	npm run dev

go: build
	@cp -r dist tpls && cd tpls && ./compile.sh

clean: 
	@rm -f ./dist
	@rm -f ./tpls/dist
	@rm -f ./tpls/tpls.go

docker_clean:
	@docker rmi $(IMAGE_NAME)

.PHONY: default build run go clean docker_build docker_clean
