#!/bin/bash

# ============================
# Author: Mirko Moguljak, M.IT
# ============================

# Define ElasticSearch URL
es_url="https://search-logs-random.eu-central-1.es.amazonaws.com/"
credentials="Username:Password"

# Get the names of all the indices
indices="$(for i in "$(curl --silent --user "$credentials" "$es_url"_aliases?pretty=true | grep -v ".opendistro" | grep -v "aliases" | grep -v ".kibana" | grep -v '}' | cut -d ":" -f1 | sed -nr 's/\s*"\s*/\n/gp' | awk NF )"; do echo $i; done)"

# Create URL for each indice
indices_url_list="$(
        indices_array=( $indices )
        for element in "${indices_array[@]}"
        do
                echo ""$es_url"${element}"
        done
    )"

indice_url="$(echo $indices_url_list | tr ' ' '\n')"

# Delete all indices
for i in $indice_url; do /usr/bin/curl --silent --user $credentials -XDELETE $i; done

# Test script
#for i in $indice_url; do /usr/bin/curl --silent --user $credentials -XGET $i; done
