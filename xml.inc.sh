read_dom () {
	ENTITY=
	CONTENT=
	local IFS=\>
	read -d \< ENTITY CONTENT
	while [[ $ENTITY == /* ]] ; do
		read -d \< ENTITY CONTENT
	done
}
