for _PROBLEM_SOLVER in $(find $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/build/maven/problems -type f -name '*.sh'); do
	_PROBLEM_SOLVER_NAME=$(basename $_PROBLEM_SOLVER | tr '-' ' ' | sed -e "s/\.sh$//")
	_info "Inspecting project with $_PROBLEM_SOLVER_NAME"
	. $_PROBLEM_SOLVER
done
