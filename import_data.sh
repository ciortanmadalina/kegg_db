#!/bin/bash
# This script generates sql insert scripts for data import

readonly N=3
readonly join_file="insert_into_raw_pathway_module.sql"
rm "$join_file"


if [ ! -f pathway ]; then
  curl http://rest.kegg.jp/list/pathway > pathway
fi

read_pathways ()
{
  insert_file="insert_into_raw_pathway.sql"
  rm "$insert_file"
  for i in $(seq 1 $N)
  do
    read line
    echo $line
    path=$(echo $line | awk '{print $1}')
    desc=$(echo $line | awk '{print $2}')
    echo "INSERT INTO raw_pathway(name, description) VALUES ('$path', '$desc');" >>"$insert_file"
    read_pathway_modules $path

  done < pathway
}

read_pathway_modules ()
{
  path=$1
  echo "reading modules for $path"
  #download pathway details file if necessary
  if [ ! -f "$path" ]; then
    curl "http://rest.kegg.jp/get/$path" > "$path"
  fi
 
  modules=()
  modules+=( $(grep "^MODULE" "$path" | awk '{print $2}') )
  modules+=( $(awk '{print $1}' "$path" | grep -o 'M[0-9]\{5,6\}') )

  echo "Modules array ${modules[@]} "

  for module in "${modules[@]}"
  do
    echo "INSERT INTO raw_pathway_module(pathway, module) VALUES ('$path', '$module');" >> "$join_file"
  done

}

#invocations
read_pathways
