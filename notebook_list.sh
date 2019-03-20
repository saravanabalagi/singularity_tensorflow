for line in $(find ~/.jupyter/tmp/jupyter -type f -iname '*.json'); do
  url=$(cat $line | grep \"url | sed 's/[^:]*: *"*//; s/".*//')
  token=$(cat $line | grep token | sed 's/[^:]*: *"*//; s/".*//')
  echo $url?token=$token
done
