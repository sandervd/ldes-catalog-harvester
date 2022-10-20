tracked-catalogs = $(wildcard catalogs/*)
catalogs := $(subst catalogs, workspace/dcat, $(tracked-catalogs))
catalogs-dcat-rdf := $(patsubst %,%/validated.nt,$(catalogs))

workspace/catalog.nt: $(catalogs-dcat-rdf)
	cat $(catalogs-dcat-rdf) 2>/dev/null > workspace/catalog.nt

workspace/dcat/%/validated.nt: workspace/dcat/%/inferred.nt schemas/dcatapvl.ttl
	./bin/validate.sh $(*F)

workspace/dcat/%/inferred.nt: workspace/dcat/%/infer-1.nt
	cp $(<) $(<D)/inferred.nt


#workspace/dcat/%/infer-3.nt: workspace/dcat/%/infer-2.nt schemas/infer/3.rq
#	 ./apache-jena/bin/update --data $(<) --file schemas/infer/3.rq --dump > $@

#workspace/dcat/%/infer-2.nt: workspace/dcat/%/infer-1.nt schemas/infer/2.rq
#	 ./apache-jena/bin/update --data $(<) --file schemas/infer/2.rq --dump > $@

workspace/dcat/%/infer-1.nt: workspace/dcat/%/normalised.nt schemas/infer/1.rq
	mkdir -p schemas/infer
	./apache-jena/bin/update --data $(<) --file schemas/infer/1.rq --dump > $@

workspace/dcat/%/normalised.nt: workspace/dcat/%/original apache-jena bin/normalise.sh
	./bin/normalise.sh $(*F)

workspace/dcat/%/original: catalogs/% ./bin/download.sh
	mkdir -p workspace/dcat/$(*F)
	./bin/download.sh $(^) > $@

schemas/dcatapvl.ttl: workspace/schema/5.ttl
	cp workspace/schema/5.ttl schemas/dcatapvl.ttl

workspace/schema/5.ttl: workspace/schema/4.ttl schemas/changes/5.rq
	./apache-jena/bin/update --data workspace/schema/4.ttl --update schemas/changes/5.rq --dump > workspace/schema/5.ttl

workspace/schema/4.ttl: workspace/schema/3.ttl schemas/changes/4.rq
	./apache-jena/bin/update --data workspace/schema/3.ttl --update schemas/changes/4.rq --dump > workspace/schema/4.ttl

workspace/schema/3.ttl: workspace/schema/2.ttl schemas/changes/3.rq
	./apache-jena/bin/update --data workspace/schema/2.ttl --update schemas/changes/3.rq --dump > workspace/schema/3.ttl

workspace/schema/2.ttl: workspace/schema/1.ttl schemas/changes/2.rq
	./apache-jena/bin/update --data workspace/schema/1.ttl --update schemas/changes/2.rq --dump > workspace/schema/2.ttl

workspace/schema/1.ttl: schemas/dcatap-normalised.ttl schemas/changes/1.rq
	mkdir -p workspace/schema
	./apache-jena/bin/update --data schemas/dcatap-normalised.ttl --update schemas/changes/1.rq --dump > workspace/schema/1.ttl

schemas/dcatap-normalised.ttl: schemas/dcatapvl.jsonld
	./apache-jena/bin/riot --formatted=turtle schemas/dcatapvl.jsonld > schemas/dcatap-normalised.ttl

schemas/dcatapvl.jsonld:
	mkdir -p schemas
	wget https://raw.githubusercontent.com/Informatievlaanderen/OSLOthema-metadataVoorServices/validation/release/dcatapvl.jsonld -O schemas/dcatapvl.jsonld

expire:
	#       Mark all tracked catalogs older than a day for processing.
	find catalogs/* -mmin +1440 -exec touch {}  \;

apache-jena:
	rm -f apache-jena
	wget https://dlcdn.apache.org/jena/binaries/apache-jena-4.6.1.zip -O apache-jena.zip
	unzip apache-jena.zip
	rm apache-jena.zip
	ln -s apache-jena-* apache-jena

shacl:
	# Download TopBraid SHALC validator.
	rm -f shacl
	wget https://repo1.maven.org/maven2/org/topbraid/shacl/1.4.2/shacl-1.4.2-bin.zip
	unzip shacl-1.4.2-bin.zip
	rm shacl-1.4.2-bin.zip
	ln -s shacl-* shacl
	chmod +x shacl/bin/shaclvalidate.sh

# Keep intermediate files for performance.
.PRECIOUS: workspace/dcat/%/original workspace/dcat/%/normalised.nt workspace/dcat/%/dcat.nt workspace/dcat/%/inferred.nt
# For performance, no need to process old suffix rules.
.SUFFIXES: 
