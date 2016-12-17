#!/bin/bash
# This script generates sql insert scripts for data import

readonly N=3
readonly pathway_module_file="output/insert_pathway_module.sql"
unique_modules=()
rm -r output
mkdir output

if [ ! -f pathway ]; then
  curl http://rest.kegg.jp/list/pathway > pathway
fi

read_pathways ()
{
  insert_file="output/insert_pathway.sql"
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

  unique_modules=("${unique_modules[@]}" "${modules[@]}")
  unique_modules=$(unique_values $unique_modules)
  echo "Modules array ${modules[@]} "

  for module in "${modules[@]}"
  do
    echo "INSERT INTO raw_pathway_module(pathway, module) VALUES ('$path', '$module');" >> "$pathway_module_file"
    #download module file if it doesn't exist
    if [ ! -f "$module" ]; then
      curl "http://rest.kegg.jp/get/$module" > "$module"
    fi
    python3 parse_module.py "$module"
   
  done

  echo "Global modules array ${unique_modules[@]} "
}

compounds_from_insert_file ()
{
  compounds=($(awk '{print $10}' output/insert_reaction_compound.sql | sed "s/'//g" | sort -u))
  #echo "Compounds: $compounds"
  for compound in "${compounds[@]}"
  do
    #echo "compound= $compound"
    #download module file if it doesn't exist
    if [ ! -f "$compound" ]; then
      curl "http://rest.kegg.jp/get/$compound" > "$compound"
    fi

    python3 parse_compound.py "$compound"

  done
}


reactions_from_insert_file ()
{
  reactions=($(awk '{print $8}' output/insert_reaction_compound.sql | sed "s/'//g" | sort -u))
  for reaction in "${reactions[@]}"
  do
    #download module file if it doesn't exist
    if [ ! -f "$reaction" ]; then
      curl "http://rest.kegg.jp/get/$reaction" > "$reaction"
    fi

    python3 parse_reaction.py "$reaction"

  done
}

enzymes_from_insert_file ()
{
  enzymes=($(awk '{print $9}' output/insert_reaction_enzyme.sql | sed "s/'//g" | sort -u))
  for enzyme in "${enzymes[@]}"
  do
    #download module file if it doesn't exist
    if [ ! -f "$enzyme" ]; then
      curl "http://rest.kegg.jp/get/$enzyme" > "$enzyme"
    fi

    python3 parse_enzyme.py "$enzyme"

  done
}


unique_values ()
{
  input=$1
  unique=($(printf "%s\n" "${input[@]}" | sort -u))
  #return unique
  echo ${unique[@]}
}

#invocations
read_pathways
compounds_from_insert_file
reactions_from_insert_file
enzymes_from_insert_file
