####
# Variables (see volumes config document)
####

####
# SSH vars
####

REMOTE_USER_NAME ?= core
IP ?= 52.49.229.231
#full ssh connect vars
CONNECT = $(REMOTE_USER_NAME)@$(IP)

####
# dockgen vars
####

DOCKGEN_DATADOG_NAME ?= dockgen-datadog
TMPL_SRC ?= /home/core/templates/datadog/
DOCKGEN_TMPL_DEST = /etc/docker-gen/templates/


####
# Datadog vars
####

API_KEY_LOCATION= ~/dockgen_api.key
DATADOG_NAME=dd-agent
HOSTNAME=stage-agent
include $(API_KEY_LOCATION)

####
# volume vars
####
DOCKGEN_CFG_SRC ?= /home/core/config/dockgen/datadog/docker-gen.cfg
DOCKGEN_CFG_DEST ?= /etc/docker-gen/docker-gen.cfg
DATADOG_CFG_SRC = /tmp/datadog/
DATADOG_CFG_DEST = /etc/dd-agent/conf.d/

####
# full mount vars (don't edit)
####

DOCKGEN_CFG = $(DOCKGEN_CFG_SRC):$(DOCKGEN_CFG_DEST)
DOCKGEN_TMPL = $(TMPL_SRC):$(DOCKGEN_TMPL_DEST)
DATADOG_CFG = $(DATADOG_CFG_SRC):$(DATADOG_CFG_DEST)


####
# dockgen deployment
####

dockgen_datadog_run:
	ssh $(CONNECT) docker run -d --name $(DOCKGEN_DATADOG_NAME) \
	-v /var/run/docker.sock:/tmp/docker.sock:ro \
	-v $(DOCKGEN_TMPL) \
	-v $(DATADOG_CFG) \
	-v $(DOCKGEN_CFG) \
	-t jwilder/docker-gen \
	-config $(DOCKGEN_CFG_DEST)

dockgen_datadog_remove:
	ssh $(CONNECT) docker stop $(DOCKGEN_DATADOG_NAME) | xargs -r ssh $(CONNECT) docker rm

dockgen_reset: dockgen_datadog_remove dockgen_datadog_run

####
# datadog deployment
####

datadog_run:
	ssh $(CONNECT) docker run -d --name $(DATADOG_NAME) -h $(HOSTNAME) \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /proc/:/host/proc/:ro \
	-v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
	-v /opt/dd-agent-conf.d:/conf.d:ro \
	-v $(DATADOG_CFG) \
	-e API_KEY=$(API_KEY) -e SERVICE="datadog" \
	datadog/docker-dd-agent

datadog_cleanup:
	ssh $(CONNECT) docker stop $(DATADOG_NAME) | xargs -r ssh $(CONNECT) docker rm

datadog_reset: datadog_cleanup datadog_run