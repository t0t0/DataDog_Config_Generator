
DOCKGEN_EXPOSED_PORT ?= 15


make_container:
	docker run -ti --expose $(DOCKGEN_EXPOSED_PORT) -e DOCKGEN_VIRTUAL_PORT=$(DOCKGEN_EXPOSED_PORT) image

make_dockgen:
	docker run -d --name ddd-gen-test \
	-v /var/run/docker.sock:/tmp/docker.sock:ro \
	-v /home/tomas/DataDog_Config_Generator/nginxConfig/:/etc/docker-gen/ \
	-v /home/tomas/test/output:/etc/docker-gen/tmp \
	-t jwilder/docker-gen \
	-watch -only-exposed /etc/docker-gen/datadog.conf.tmpl /etc/docker-gen/tmp/datadog.conf

remove_dockgen:
	docker stop ddd-gen-test | xargs docker rm

dockegen_reset: remove_dockgen make_dockgen