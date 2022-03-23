#===========
#Build Stage
#===========
FROM elixir:1.8-alpine as build

ENV MIX_ENV=prod \
  APP_NAME="elixir_dns_server"

WORKDIR /workdir

#Copy the source folder into the Docker image
COPY mix.exs mix.lock .formatter.exs /workdir/
COPY config /workdir/config
COPY test /workdir/test
COPY rel /workdir/rel
COPY lib /workdir/lib

#Install dependencies and build Release
RUN rm -Rf _build; \
    mix deps.clean --all; \
    mix local.hex --force; \
    mix local.rebar --force; \
    mix deps.get; \
    mix format; \
    # run tests
    mix test; \
    rm -Rf _build; \
    mix release; \
    #Extract Release archive to /rel for copying in next stage
    RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/`; \
    mkdir /export; \
    tar -xf "$RELEASE_DIR/$APP_NAME.tar.gz" -C /export

#================
#Deployment Stage
#================
FROM alpine:3.13

# Bash is needed to run the erlang app
RUN apk add --update bash curl; \
  rm -rf /var/cache/apk/*

#Set environment variables and expose port
EXPOSE 8080 53/udp

ENV REPLACE_OS_VARS=true \
  MIX_ENV=prod \
  APP_NAME="elixir_dns_server"

#Copy and extract .tar.gz Release file from the previous stage
COPY --from=build /export/ /opt/app

#Set default entrypoint and command
#Run the restful_dns app using the foreground param
#This will output the logs to stdout
ENTRYPOINT ["/opt/app/bin/elixir_dns_server"]
CMD ["foreground"]
#HEALTHCHECK --interval=10s --timeout=5s --retries=25 CMD curl --fail -s http://localhost:8080/srv/health || exit 1
