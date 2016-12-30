#!/bin/bash
# This script generates sql insert scripts for data import

rm -r output
mkdir output

parse_input_file ()
{
  input_file="input"

  insert_file="output/insert_pathway_module.sql"
  while read -r line
  do
    path=$(echo $line | awk '{print $1}')
    module=$(echo $line | awk '{print $2}')
   echo " INSERT INTO raw_pathway_module(pathway, module) VALUES ('${path}', '${module}'); " >>"$insert_file"
  
    read_pathways $path
    read_modules $module
  done < "$input_file"
}

read_pathways ()
{
  path=$1
  echo "reading modules for $path"
  #download pathway details file if necessary
  if [ ! -f "$path" ]; then
    curl "http://rest.kegg.jp/get/$path" > "$path"
  fi
 
  python3 scripts/parse_pathway.py "$path"

}


read_modules ()
{
  module=$1
  #download module file if it doesn't exist
  if [ ! -f "$module" ]; then
    curl "http://rest.kegg.jp/get/$module" > "$module"
  fi
  python3 scripts/parse_module.py "$module"
}

compounds_from_insert_file ()
{
  compounds=($(awk '{print $11}' output/insert_reaction_compound.sql | sed "s/'//g" | sort -u))
  #echo "Compounds: $compounds"
  for compound in "${compounds[@]}"
  do
    #download module file if it doesn't exist
    if [ ! -f "$compound" ]; then
      curl "http://rest.kegg.jp/get/$compound" > "$compound"
    fi

    python3 scripts/parse_compound.py "$compound"

  done
}


reactions_from_insert_file ()
{
  reactions=($(awk '{print $9}' output/insert_reaction_compound.sql | sed "s/'//g" | sort -u))
  for reaction in "${reactions[@]}"
  do
    #download module file if it doesn't exist
    if [ ! -f "$reaction" ]; then
      curl "http://rest.kegg.jp/get/$reaction" > "$reaction"
    fi

    python3 scripts/parse_reaction.py "$reaction"

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

    python3 scripts/parse_enzyme.py "$enzyme"

  done
}


unique_values ()
{
  input=$1
  unique=($(printf "%s\n" "${input[@]}" | sort -u))
  #return unique
  echo ${unique[@]}
}

remove_duplicate_lines()
{
  for file in ./output/*; do 
    echo "$(sort -u "$file")" > "$file" 
  done
}
#invocations
parse_input_file
compounds_from_insert_file
reactions_from_insert_file
enzymes_from_insert_file
remove_duplicate_lines
