#!/bin/bash -e
catalog=${1%/*}
set +e
(set -E ; trap 'exit 1' ERR ; ./shacl/bin/shaclvalidate.sh -datafile workspace/dcat/$catalog/original.nt -shapesfile schemas/dcatapvl.ttl > workspace/dcat/$catalog/report.ttl)
if [ $? -ne 0 ]
then
	./apache-jena/bin/sparql --data=workspace/dcat/$catalog/report.ttl --query=shacl-report.rq --results=text
	exit 1
fi
set -e
