Bitcoind for Docker with backend support for LND
===================

[![Docker Stars](https://img.shields.io/docker/stars/kylemanna/bitcoind.svg)](https://hub.docker.com/r/nauutilus/bitcoind/)
[![Docker Pulls](https://img.shields.io/docker/pulls/kylemanna/bitcoind.svg)](https://hub.docker.com/r/nauutilus/bitcoind/)

Docker image that runs the Bitcoin bitcoind node in a container with support for LND on testnet or mainnet for easy deployment.

Requirements
------------

* Physical machine, cloud instance, or VPS that supports Docker (i.e. [Vultr](http://bit.ly/1HngXg0), [Digital Ocean](http://bit.ly/18AykdD), KVM or XEN based VMs) running Ubuntu 14.04 or later (*not OpenVZ containers!*)
* At least 100 GB to store the block chain files (and always growing!)
* At least 1 GB RAM + 2 GB swap file

Recommended and tested on unadvertised (only shown within control panel) [Vultr SATA Storage 1024 MB RAM/250 GB disk instance @ $10/mo](http://bit.ly/vultrbitcoind).  Vultr also *accepts Bitcoin payments*!


Really Fast Quick Start boostraping just a simple bitcoind node
-----------------------

One liner for Ubuntu 14.04 LTS machines with JSON-RPC enabled on localhost and adds upstart init script:

    curl https://raw.githubusercontent.com/nauutilus/docker-bitcoind/master/bootstrap-host.sh | sh -s trusty


Quick Start
-----------

1. Create a `bitcoind-data` volume to persist the bitcoind blockchain data, enable testnet, enable LND support.  The `bitcoind-data` container will store the blockchain when the node container is recreated (software upgrade, reboot, etc):

        docker volume create --name=bitcoin-data
        docker run -v bitcoind-data:/bitcoin --name=bitcoind-node -d \
	    -e LND_SUPPORT=true \
	    -e TESTNET=1 \
	    -e DISABLEWALLET=1 \
	    -e RPCUSER=myuser \
	    -e RPCPASSWORD=mypassword \ 
            -p 8333:8333 \
            -p 127.0.0.1:8332:8332 \
	    -p 127.0.0.1:28333:28333 \
	    -p 127.0.0.1:28332:28332 \
            nauutilus/bitcoind

2. Verify that the container is running and bitcoind node is downloading the blockchain

        $ docker ps
	CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS              PORTS                                                                                      NAMES
	91c4b6bb0552        nauutilus/bitcoind             "docker-entrypoint.s…"   42 minutes ago      Up 42 minutes       127.0.0.1:8332->8332/tcp, 127.0.0.1:28332-28333->28332-28333/tcp, 0.0.0.0:8333->8333/tcp   bitcoind-node
3. You can then access the daemon's output thanks to the [docker logs command]( https://docs.docker.com/reference/commandline/cli/#logs)

        docker logs -f bitcoind-node

4. Install optional init scripts for upstart and systemd are in the `init` directory.


5. Run LND node:

	lnd --bitcoin.active --bitcoin.testnet --debuglevel=debug --bitcoin.node=bitcoind --bitcoind.rpcuser=myuser --bitcoind.rpcpass=mypassword --bitcoind.zmqpubrawblock=tcp://127.0.0.1:28332 --bitcoind.zmqpubrawtx=tcp://127.0.0.1:28333 --externalip=X.X.X.X


* Additional documentation in the [docs folder](docs).
