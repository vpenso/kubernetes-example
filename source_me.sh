# Find the correct path even if dereferenced by a link
__source=$0

if [[ "$__source" == *bash* ]]; then
  __source=${BASH_SOURCE[0]}
fi

__dir="$( dirname $__source )"
while [ -h $__source ]
do
  __source="$( readlink "$__source" )"
  [[ $__source != /* ]] && __source="$__dir/$__source"
  __dir="$( cd -P "$( dirname "$__source" )" && pwd )"
done
__dir="$( cd -P "$( dirname "$__source" )" && pwd )"

export K8S_PATH=$__dir

echo K8S_PATH=$K8S_PATH

unset __dir
unset __source

for file in `\ls $K8S_PATH/var/aliases/*.sh`
do 
  source $file
done
