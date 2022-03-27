# Elixir DNS Rest Server
:warning: Experimental :warning:

## First steps

In order to build this project you will need either [elixir](https://elixir-lang.org/learning.html) or docker installed.

To install elixir: https://elixir-lang.org/install.html (This should come with the mix build system)

To install docker: https://docs.docker.com/install/ (Then see the elixir install guide for running in docker)

## Usage

Two components will be stood up with this project.

### RESTful endpoint for DNS registration.

This contains two endpoints. One for :a records, and one for :srv records.

1. POST - /dns/a
1. POST - /dns/srv

```bash
//Register an :a record
curl -X POST -H "content-type: application/json" --data '{"host": "hostname", "ip_address": "127.0.0.1"}' http://localhost/dns/a

//Register an :srv record
curl -X POST -H "content-type: application/json" --data '{"entry": "_test_srv._tcp", "host": "hostname", "port": 1000}' http://localhost/dns/srv
```

#### A endpoint request body (only IPV4 is supported)

1. host - string representation of the :a record hostname - required
1. ip_address - string representation of the :a record ip address - must match regexp `^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$` - required

#### SRV endpoint request body
[See here](https://en.wikipedia.org/wiki/SRV_record)

1. entry - string representation of the :srv records service name and proto ex. `_service._proto.name.` - must match regexp `^_\w+(_\w+)*._(tcp|udp)(.\w+)*\.?$` - required
1. host - string representation of the :srv record hostname - required
1. port - int representation of the :srv record port - required

## How To

This project can be built and tested using [mix](https://hexdocs.pm/mix/Mix.html), and [distillery](https://github.com/bitwalker/distillery).

Start by downloading all dependencies.

```bash
mix deps.get
```

_The output_
```bash
Resolving Hex dependencies...
Dependency resolution completed:
Unchanged:
  cowboy 2.6.3
  cowlib 2.7.3
  distillery 1.5.5
  dns 2.1.2
  jason 1.1.2
  maru 0.13.2
  mime 1.3.1
  plug 1.8.3
  plug_cowboy 2.0.2
  plug_crypto 1.0.0
  poison 3.1.0
  ranch 1.7.1
  socket 0.3.13
* Getting dns (Hex package)
* Getting maru (Hex package)
* Getting jason (Hex package)
* Getting plug_cowboy (Hex package)
* Getting ranch (Hex package)
* Getting cowboy (Hex package)
* Getting distillery (Hex package)
* Getting poison (Hex package)
* Getting cowlib (Hex package)
* Getting plug (Hex package)
* Getting mime (Hex package)
* Getting plug_crypto (Hex package)
* Getting socket (Hex package)
```

### Mix Config Environments

See this [documentation](https://hexdocs.pm/mix/Mix.Config.html).

For this project, we will have 4 environments. (dev, test, debug, and prod).

1. [Dev](config/dev.exs) - This environment will be used to deploy this application in a development setting.
1. [Test](config/test.exs) - This environment will be used to run the existing tests.
1. [Debug](config/debug.exs) - This environment will be used to deploy this application in a post release environment with debug configurations.
1. [Prod](config/prod.exs) - This environment will be used to deploy this application in a post release environment.

### Testing

Run the command:

```bash
mix test
```

_The output_
```bash
==> socket
Compiling 11 files (.ex)
Generated socket app
==> dns
Compiling 7 files (.ex)
Generated dns app
===> Compiling ranch
==> jason
Compiling 8 files (.ex)
Generated jason app
warning: String.strip/1 is deprecated. Use String.trim/1 instead
  deps/poison/mix.exs:4

==> poison
Compiling 4 files (.ex)
warning: Integer.to_char_list/2 is deprecated. Use Integer.to_charlist/2 instead
  lib/poison/encoder.ex:173

Generated poison app
===> Compiling cowlib
===> Compiling cowboy
==> mime
Compiling 2 files (.ex)
Generated mime app
==> distillery
Compiling 19 files (.ex)
warning: found quoted atom "insecure_cookie_in_distillery_config" but the quotes are not required. Atoms made exclusively of Unicode letters, numbers, underscore, and @ do not require quotes
  lib/distillery/lib/cookies.ex:22

warning: "not expr1 in expr2" is deprecated. Instead use "expr1 not in expr2" if you require Elixir v1.5+, or "not(expr1 in expr2)" if you have to support earlier Elixir versions
  lib/mix/lib/releases/appups.ex:207

warning: "not expr1 in expr2" is deprecated. Instead use "expr1 not in expr2" if you require Elixir v1.5+, or "not(expr1 in expr2)" if you have to support earlier Elixir versions
  lib/mix/lib/releases/appups.ex:208

warning: System.stacktrace/0 outside of rescue/catch clauses is deprecated. If you want to support only Elixir v1.7+, you must access __STACKTRACE__ inside a rescue/catch. If you want to support earlier Elixir versions, move System.stacktrace/0 inside a rescue/catch
  lib/mix/lib/releases/errors.ex:68

warning: System.stacktrace/0 outside of rescue/catch clauses is deprecated. If you want to support only Elixir v1.7+, you must access __STACKTRACE__ inside a rescue/catch. If you want to support earlier Elixir versions, move System.stacktrace/0 inside a rescue/catch
  lib/mix/lib/releases/errors.ex:190

warning: System.stacktrace/0 outside of rescue/catch clauses is deprecated. If you want to support only Elixir v1.7+, you must access __STACKTRACE__ inside a rescue/catch. If you want to support earlier Elixir versions, move System.stacktrace/0 inside a rescue/catch
  lib/mix/lib/releases/errors.ex:246

warning: invalid type annotation. When using the | operator to represent the union of types, make sure to wrap type annotations in parentheses: {:ok, [term]} :: {:error, String.t()}
  lib/mix/lib/releases/utils.ex:71

warning: Mix.Config.read!/1 is deprecated. Use eval!/2 instead
  lib/mix/lib/releases/assembler.ex:601

warning: Mix.Dep.loaded/1 is deprecated. Mix.Dep.loaded/1 was private API and you should not use it
  lib/mix/lib/releases/models/app.ex:37

Generated distillery app
==> plug_crypto
Compiling 4 files (.ex)
Generated plug_crypto app
==> plug
Compiling 1 file (.erl)
Compiling 39 files (.ex)
warning: System.stacktrace/0 outside of rescue/catch clauses is deprecated. If you want to support only Elixir v1.7+, you must access __STACKTRACE__ inside a rescue/catch. If you want to support earlier Elixir versions, move System.stacktrace/0 inside a rescue/catch
  lib/plug/conn/wrapper_error.ex:23

Generated plug app
==> maru
Compiling 58 files (.ex)
warning: module attribute @since was set but never used
  lib/maru/server.ex:122

Generated maru app
==> plug_cowboy
Compiling 5 files (.ex)
Generated plug_cowboy app
==> restful_dns
Compiling 4 files (.ex)
Generated restful_dns app

07:52:38.202 [info]  Starting Elixir.Rest.API with Elixir.Plug.Cowboy under supervisor tree on http://127.0.0.1:0

07:52:38.208 [debug] DNS Server listening at 0
.....
07:52:38.464 [debug] Request Record:

07:52:38.464 [debug] %DNS.Record{anlist: [], arlist: [], header: %DNS.Header{aa: false, id: 0, opcode: :query, pr: false, qr: false, ra: false, rcode: 0, rd: true, tc: false}, nslist: [], qdlist: [%DNS.Query{class: :in, domain: '_test_srv._tcp', type: :srv}]}

07:52:38.464 [debug] Answer List:

07:52:38.464 [debug] [%DNS.Resource{bm: [], class: :in, cnt: 0, data: {0, 0, 1000, 'my_host'}, domain: '_test_srv._tcp', func: false, tm: :undefined, ttl: 0, type: :srv}]
.
07:52:38.466 [debug] Request Record:
.
07:52:38.466 [debug] %DNS.Record{anlist: [], arlist: [], header: %DNS.Header{aa: false, id: 0, opcode: :query, pr: false, qr: false, ra: false, rcode: 0, rd: true, tc: false}, nslist: [], qdlist: [%DNS.Query{class: :in, domain: 'me.com', type: :a}]}

07:52:38.466 [debug] Answer List:

07:52:38.466 [debug] [%DNS.Resource{bm: [], class: :in, cnt: 0, data: {127, 0, 0, 1}, domain: 'me.com', func: false, tm: :undefined, ttl: 0, type: :a}]
....

Finished in 0.1 seconds
11 tests, 0 failures

Randomized with seed 270000
```

### Run application in dev

A dev environment can be stood up in 2 ways.

First, dev before release. Run this command:

```bash
//Without the --no-halt everything will run as daemon and complete when the build has completed
mix run --no-halt
```

_The output_
```bash
==> socket
Compiling 11 files (.ex)
Generated socket app
==> dns
Compiling 7 files (.ex)
Generated dns app
===> Compiling ranch
==> jason
Compiling 8 files (.ex)
Generated jason app
warning: String.strip/1 is deprecated. Use String.trim/1 instead
  deps/poison/mix.exs:4

==> poison
Compiling 4 files (.ex)
warning: Integer.to_char_list/2 is deprecated. Use Integer.to_charlist/2 instead
  lib/poison/encoder.ex:173

Generated poison app
===> Compiling cowlib
===> Compiling cowboy
==> mime
Compiling 2 files (.ex)
Generated mime app
==> distillery
Compiling 19 files (.ex)
warning: found quoted atom "insecure_cookie_in_distillery_config" but the quotes are not required. Atoms made exclusively of Unicode letters, numbers, underscore, and @ do not require quotes
  lib/distillery/lib/cookies.ex:22

warning: "not expr1 in expr2" is deprecated. Instead use "expr1 not in expr2" if you require Elixir v1.5+, or "not(expr1 in expr2)" if you have to support earlier Elixir versions
  lib/mix/lib/releases/appups.ex:207

warning: "not expr1 in expr2" is deprecated. Instead use "expr1 not in expr2" if you require Elixir v1.5+, or "not(expr1 in expr2)" if you have to support earlier Elixir versions
  lib/mix/lib/releases/appups.ex:208

warning: System.stacktrace/0 outside of rescue/catch clauses is deprecated. If you want to support only Elixir v1.7+, you must access __STACKTRACE__ inside a rescue/catch. If you want to support earlier Elixir versions, move System.stacktrace/0 inside a rescue/catch
  lib/mix/lib/releases/errors.ex:68

warning: System.stacktrace/0 outside of rescue/catch clauses is deprecated. If you want to support only Elixir v1.7+, you must access __STACKTRACE__ inside a rescue/catch. If you want to support earlier Elixir versions, move System.stacktrace/0 inside a rescue/catch
  lib/mix/lib/releases/errors.ex:190

warning: System.stacktrace/0 outside of rescue/catch clauses is deprecated. If you want to support only Elixir v1.7+, you must access __STACKTRACE__ inside a rescue/catch. If you want to support earlier Elixir versions, move System.stacktrace/0 inside a rescue/catch
  lib/mix/lib/releases/errors.ex:246

warning: invalid type annotation. When using the | operator to represent the union of types, make sure to wrap type annotations in parentheses: {:ok, [term]} :: {:error, String.t()}
  lib/mix/lib/releases/utils.ex:71

warning: Mix.Config.read!/1 is deprecated. Use eval!/2 instead
  lib/mix/lib/releases/assembler.ex:601

warning: Mix.Dep.loaded/1 is deprecated. Mix.Dep.loaded/1 was private API and you should not use it
  lib/mix/lib/releases/models/app.ex:37

Generated distillery app
==> plug_crypto
Compiling 4 files (.ex)
Generated plug_crypto app
==> plug
Compiling 1 file (.erl)
Compiling 39 files (.ex)
warning: System.stacktrace/0 outside of rescue/catch clauses is deprecated. If you want to support only Elixir v1.7+, you must access __STACKTRACE__ inside a rescue/catch. If you want to support earlier Elixir versions, move System.stacktrace/0 inside a rescue/catch
  lib/plug/conn/wrapper_error.ex:23

Generated plug app
==> maru
Compiling 58 files (.ex)
warning: module attribute @since was set but never used
  lib/maru/server.ex:122

Generated maru app
==> plug_cowboy
Compiling 5 files (.ex)
Generated plug_cowboy app
==> restful_dns
Compiling 4 files (.ex)
Generated restful_dns app

07:55:46.346 [info]  Starting Elixir.Rest.API with Elixir.Plug.Cowboy under supervisor tree on http://0.0.0.0:8000

07:55:46.350 [debug] DNS Server listening at 53

07:55:46.368 [info]  Application restful_dns exited: Dnrest.start(:normal, []) returned an error: shutdown: failed to start child: DNS.DnrestServer
    ** (EXIT) an exception was raised:
        ** (Socket.Error) address already in use
            (socket) lib/socket/udp.ex:89: Socket.UDP.open!/2
            (restful_dns) lib/dns/dnrest_server.ex:21: DNS.DnrestServer.init/1
            (stdlib) gen_server.erl:374: :gen_server.init_it/2
            (stdlib) gen_server.erl:342: :gen_server.init_it/6
            (stdlib) proc_lib.erl:249: :proc_lib.init_p_do_apply/3
** (Mix) Could not start application restful_dns: Dnrest.start(:normal, []) returned an error: shutdown: failed to start child: DNS.DnrestServer
    ** (EXIT) an exception was raised:
        ** (Socket.Error) address already in use
            (socket) lib/socket/udp.ex:89: Socket.UDP.open!/2
            (restful_dns) lib/dns/dnrest_server.ex:21: DNS.DnrestServer.init/1
            (stdlib) gen_server.erl:374: :gen_server.init_it/2
            (stdlib) gen_server.erl:342: :gen_server.init_it/6
            (stdlib) proc_lib.erl:249: :proc_lib.init_p_do_apply/3

//This means the existing port in the config is in use
//Modify that port.
Compiling 4 files (.ex)
Generated restful_dns app

07:57:00.936 [info]  Starting Elixir.Rest.API with Elixir.Plug.Cowboy under supervisor tree on http://0.0.0.0:8000

07:57:00.942 [debug] DNS Server listening at 8080

//Once the dev instance is tested. Ctrl-C to end the process.
```

First, dev after release process. Run this command:

This is the same as prod, but using MIX_ENV=dev instead of prod.

### Run application in prod

Once everything has been tested and development is complete, the release process can be run and the app can be deployed to a prod environment.

Run the command:
```bash
MIX_ENV=prod mix release
```

_The output_
```bash
==> socket
Compiling 11 files (.ex)
Generated socket app
==> dns
Compiling 7 files (.ex)
Generated dns app
===> Compiling ranch
==> jason
Compiling 8 files (.ex)
Generated jason app
warning: String.strip/1 is deprecated. Use String.trim/1 instead
  deps/poison/mix.exs:4

==> poison
Compiling 4 files (.ex)
warning: Integer.to_char_list/2 is deprecated. Use Integer.to_charlist/2 instead
  lib/poison/encoder.ex:173

Generated poison app
===> Compiling cowlib
===> Compiling cowboy
==> mime
Compiling 2 files (.ex)
Generated mime app
==> distillery
Compiling 19 files (.ex)
warning: found quoted atom "insecure_cookie_in_distillery_config" but the quotes are not required. Atoms made exclusively of Unicode letters, numbers, underscore, and @ do not require quotes
  lib/distillery/lib/cookies.ex:22

warning: "not expr1 in expr2" is deprecated. Instead use "expr1 not in expr2" if you require Elixir v1.5+, or "not(expr1 in expr2)" if you have to support earlier Elixir versions
  lib/mix/lib/releases/appups.ex:207

warning: "not expr1 in expr2" is deprecated. Instead use "expr1 not in expr2" if you require Elixir v1.5+, or "not(expr1 in expr2)" if you have to support earlier Elixir versions
  lib/mix/lib/releases/appups.ex:208

warning: System.stacktrace/0 outside of rescue/catch clauses is deprecated. If you want to support only Elixir v1.7+, you must access __STACKTRACE__ inside a rescue/catch. If you want to support earlier Elixir versions, move System.stacktrace/0 inside a rescue/catch
  lib/mix/lib/releases/errors.ex:68

warning: System.stacktrace/0 outside of rescue/catch clauses is deprecated. If you want to support only Elixir v1.7+, you must access __STACKTRACE__ inside a rescue/catch. If you want to support earlier Elixir versions, move System.stacktrace/0 inside a rescue/catch
  lib/mix/lib/releases/errors.ex:190

warning: System.stacktrace/0 outside of rescue/catch clauses is deprecated. If you want to support only Elixir v1.7+, you must access __STACKTRACE__ inside a rescue/catch. If you want to support earlier Elixir versions, move System.stacktrace/0 inside a rescue/catch
  lib/mix/lib/releases/errors.ex:246

warning: invalid type annotation. When using the | operator to represent the union of types, make sure to wrap type annotations in parentheses: {:ok, [term]} :: {:error, String.t()}
  lib/mix/lib/releases/utils.ex:71

warning: Mix.Config.read!/1 is deprecated. Use eval!/2 instead
  lib/mix/lib/releases/assembler.ex:601

warning: Mix.Dep.loaded/1 is deprecated. Mix.Dep.loaded/1 was private API and you should not use it
  lib/mix/lib/releases/models/app.ex:37

Generated distillery app
==> plug_crypto
Compiling 4 files (.ex)
Generated plug_crypto app
==> plug
Compiling 1 file (.erl)
Compiling 39 files (.ex)
warning: System.stacktrace/0 outside of rescue/catch clauses is deprecated. If you want to support only Elixir v1.7+, you must access __STACKTRACE__ inside a rescue/catch. If you want to support earlier Elixir versions, move System.stacktrace/0 inside a rescue/catch
  lib/plug/conn/wrapper_error.ex:23

Generated plug app
==> maru
Compiling 58 files (.ex)
warning: module attribute @since was set but never used
  lib/maru/server.ex:122

Generated maru app
==> plug_cowboy
Compiling 5 files (.ex)
Generated plug_cowboy app
==> restful_dns
Compiling 4 files (.ex)
Generated elixir_dns_server app
[1m[36m==> Assembling release..[0m
[1m[36m==> Building release restful_dns:0.1.0 using environment prod[0m
[1m[36m==> Including ERTS 10.2 from c:/Users/cwholmes/scoop/apps/erlang/21.2/erts-10.2[0m
[1m[36m==> Packaging release..[0m
[1m[32m==> Release successfully built!
    You can run it in one of the following ways:
      Interactive: _build/prod/rel/elixir_dns_rest_server/bin/elixir_dns_rest_server.bat console
      Foreground: _build/prod/rel/elixir_dns_rest_server/bin/elixir_dns_server.bat foreground
      Daemon: _build/prod/rel/elixir_dns_rest_server/bin/elixir_dns_server.bat start[0m
```

The commands presented can then be run.

## Docker

From this projects [Dockerfile](./Dockerfile), the project will be compiled, tested and released. The binaries will then be provided in a slimmed alpine image.

## Troubleshooting

By default the released version of this component does not log anything other than that of `:warn`.

To assist with debugging of this component, a debug image can be constructed with this command:

```bash
docker build -t elixir-dns-rest-server:debug --build-arg MIX_ENV=debug .
```

This will create an image with the log level set to `:debug`. This will help with troubleshooting issues, by capturing more event logging.
