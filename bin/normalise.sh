#!/bin/bash -e
catalog=${1%/*}
syntax=$(cat catalogs/$catalog)
./apache-jena/bin/riot --syntax=$syntax workspace/dcat/$catalog/original > workspace/dcat/$catalog/original.nt
