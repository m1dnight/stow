################################################################################
# import all files from dotfiles
for file in ~/.{aliases,functions,dockerfunc,extra,exports,path}; do
	if [[ -r "$file" ]] && [[ -f "$file" ]]; then
		# shellcheck source=/dev/null
		source "$file"
	else
    fi
done
unset file