#!/bin/bash -e
catalog=${1%/*}
set +e
(set -E ; trap 'exit 1' ERR ; ./shacl/bin/shaclvalidate.sh -datafile workspace/dcat/$catalog/normalised.nt -shapesfile schemas/dcatapvl.ttl > workspace/dcat/$catalog/report.ttl)
if [ $? -ne 0 ]
then
	# Catalog is not conformant.
	./apache-jena/bin/sparql --data=workspace/dcat/$catalog/report.ttl --query=schemas/shacl-report.rq --results=text
	exit 1
else
	# Include this catalog in the combined catalog.
	cp workspace/dcat/$catalog/normalised.nt workspace/dcat/$catalog/validated.nt
fi
set -e
