	#!/bin/bash
	# DESCRICAO: Script de criação e configuração de containers
	# NOTA:
	# AUTOR: Joahannes Costa joahannes@gmail.com> GERCOM - UFPA

	#Variaveis
	n_container=2
	imagem="busybox"

	#Limpeza inicial
	cd /proc/sys/net/bridge
	for f in bridge-nf-*; do echo 0 > $f; done
	cd -

	mkdir /var/run/netns

	#CRIA CONTAINETS E SUAS INTERFACES
	for ((i=1; i<=n_container; i++))
		do
			printf "\nCriando container número $i:\n"
			
			gnome-terminal -x bash -c "docker run --privileged -it -d --net='none' --name \"ns3_${i}\" ${imagem} /bin/sh"
			sleep 1
			#sudo docker run --privileged -it -d --name 'ns3_'$i $image /bin/sh

			#Pega ID dos containers
			pid=$(docker inspect -f '{{.State.Pid}}' ns3_${i})

			bridge="br_${i}"
			tap="tap_${i}"
			veth="veth_${i}"
			deth="deth_${i}"

			brctl addbr ${bridge}

			ip link add ${veth} type veth peer name ${deth}
			brctl addif ${bridge} ${veth}
			#brctl addif docker0 ${veth}
			ip link set ${veth} up
			ip link set ${deth} netns ${pid}

			tunctl -d ${veth}

			tunctl -t ${tap}

			#ifconfig ${tap} up
			ifconfig ${tap} 0.0.0.0 promisc up

			brctl addif ${bridge} ${tap}
			ifconfig ${bridge} up
			#ifconfig ${bridge} 0.0.0.0 promisc up

			ln -sf /proc/${pid}/ns/net /var/run/netns/${pid}

			ip netns exec ${pid} ip link set dev ${deth} name eth0
			ip netns exec ${pid} ip link set eth0 up
			ip netns exec ${pid} ip addr add 172.17.0.${i}/16 dev eth0
			#ip netns exec ${pid} ip route add default via 172.17.42.1
	done
	
	cd /proc/sys/net/bridge
	for f in bridge-nf-*; do echo 0 > $f; done
	cd -

	sleep 2
	
	ifconfig

	docker ps

	#EOF
