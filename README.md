# Rate Limit Service Example

This is an example of using `envoyproxy/ratelimit` service for rate limit.

In this example, this rate-limit configuration is used:

```yaml
domain: httpserver
descriptors:
- key: x-test-ratelimit
  value: limit
  rate_limit:
    unit: second
    requests_per_unit: 3
```

The configuration means, only 3 requests per second are allowed if HTTP header `x-test-ratelimit: limit` is set.

## Run The Example

To run the example, run:

```shell
❯ docker-compose up -d

Creating rate_limit_redis_1 ... done
Creating rate_limit_envoy_1 ... done
Creating rate_limit_ratelimitsvc_1 ... done
Creating rate_limit_httpserver_1   ... don

❯ docker ps

CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS              PORTS                                                       NAMES
dd459f5ca70f        rate_limit_httpserver      "/bin/httpserver"        49 seconds ago      Up 47 seconds       0.0.0.0:9000->9000/tcp                                      rate_limit_httpserver_1
49d051fb97bf        rate_limit_ratelimitsvc    "./bin/ratelimit"        49 seconds ago      Up 47 seconds       0.0.0.0:6070->6070/tcp, 0.0.0.0:8080-8081->8080-8081/tcp    rate_limit_ratelimitsvc_1
ca68b5b31a70        redis:6.0.5-alpine         "docker-entrypoint.s…"   49 seconds ago      Up 48 seconds       0.0.0.0:6379->6379/tcp                                      rate_limit_redis_1
ffff060497d5        envoyproxy/envoy:v1.15.0   "/docker-entrypoint.…"   49 seconds ago      Up 48 seconds       0.0.0.0:8001->8001/tcp, 0.0.0.0:9080->9080/tcp, 10000/tcp   rate_limit_envoy_1
```

Total of 4 containers should be up to run the example.

## Test It 

To directly request the `httpserver` without through envoy proxy:

```shell
❯ curl -v 'localhost:9000/test'

*   Trying 127.0.0.1:9000...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 9000 (#0)
> GET /test HTTP/1.1
> Host: localhost:9000
> User-Agent: curl/7.68.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Date: Fri, 24 Jul 2020 11:08:14 GMT
< Content-Length: 4
< Content-Type: text/plain; charset=utf-8
< 
* Connection #0 to host localhost left intact
test
```

To request the `httpserver` through envoy proxy:

```shell
❯ curl -v 'localhost:9080/test'

*   Trying 127.0.0.1:9080...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 9080 (#0)
> GET /test HTTP/1.1
> Host: localhost:9080
> User-Agent: curl/7.68.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< date: Fri, 24 Jul 2020 11:09:09 GMT
< content-length: 4
< content-type: text/plain; charset=utf-8
< x-envoy-upstream-service-time: 0
< server: envoy
< 
* Connection #0 to host localhost left intact
test
```

To request the `httpserver` through envoy proxy and use ratelimit-service:

```shell
curl -v 'localhost:9080/test' -H 'x-test-ratelimit: limit'
```