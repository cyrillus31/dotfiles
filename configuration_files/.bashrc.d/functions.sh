function _enter_docker {

	# if [[ -z $1 ]]; then 
	# 	echo "Pass a name of the container as an argument"
	# 	return 1
	# fi;

	container_name=$(\
			sudo docker ps |\
			awk 'NR > 1 { print $2 }' |\
			fzf --preview 'sudo docker ps | grep {}'\
			)

	container_id=$(sudo docker ps | grep $container_name | awk '{ print $1 }')

	sudo docker exec -it $container_id sh

}
