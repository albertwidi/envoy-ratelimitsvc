ENVOY_RATELIMIT_REPO=envoyproxy/ratelimit
ENVOY_RATELIMIT_SHA=d7d563ac55949d66a25e7cd8c6676511d8c25bb3
RATELIMIT_FOLDER=envoy-ratelimit
RATELIMIT_NAME=ratelimit-service

${RATELIMIT_FOLDER}:
	if [ ! -d ${RATELIMIT_FOLDER} ]; then mkdir ${RATELIMIT_FOLDER}; fi

${ENVOY_RATELIMIT_REPO}: ${RATELIMIT_FOLDER}
	cd ${RATELIMIT_FOLDER} && \
		git clone git@github.com:${ENVOY_RATELIMIT_REPO}

build-ratelimit: $(ENVOY_RATELIMIT_REPO)
	cd ${RATELIMIT_FOLDER}/ratelimit && \
	make compile && \
	mv bin ../