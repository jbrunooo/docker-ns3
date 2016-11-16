	#!/bin/bash
	# DESCRICAO: Script de criação e configuração de containers
	# NOTA:
	# AUTOR: Joahannes Costa joahannes@gmail.com> GERCOM - UFPA

	#Variaveis
	n_container=2
	imagem="busybox"


	#Criando containers
	for ((id=1; id<=n_container; id++))
		do
		bridge="br_${id}"
		tap="tap_${id}"
		veth="veth_${id}"
		deth="deth_${id}"

		ifconfig ${bridge} down &>/dev/null
		brctl delif ${bridge} ${tap} &>/dev/null
		brctl delbr ${bridge} &>/dev/null

		ifconfig ${tap} down &>/dev/null
		tunctl -d ${tap} &>/dev/null
		ifconfig ${veth} down &>/dev/null

		ifconfig ${deth} down &>/dev/null

		docker stop "ns3_${id}" &>/dev/null
		docker rm "ns3_${id}" &>/dev/null
	done

	rm -rf /var/run/netns

	sleep 2
	
	ifconfig

	docker ps -a
	printf "\n--------------------------------------------------\n\n"

	#EOF