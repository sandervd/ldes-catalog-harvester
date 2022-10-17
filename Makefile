tracked-catalogs = $(wildcard catalogs/*)
catalogs := $(subst catalogs, workspace/dcat, $(tracked-catalogs))
catalogs-dcat-rdf := $(patsubst %,%/dcat.nt,$(catalogs))
first: workspace/catalog.nt
	$(info    VAR is $(catalogs-dcat-rdf))

workspace/catalog.nt: $(catalogs-dcat-rdf)
	cat $(catalogs-dcat-rdf) > workspace/catalog.nt

workspace/dcat/%/dcat.nt: workspace/dcat/%/original.nt
	#./shacl/bin/shaclvalidate.sh -datafile $(^) -shapesfile schemas/dcatapvl.ttl > workspace/dcat/$(*F)/report.ttl
	./bin/validate.sh $(*F)

workspace/dcat/%/original.nt: workspace/dcat/%/original apache-jena ./bin/normalise.sh
	./bin/normalise.sh $(*F)

workspace/dcat/%/original: catalogs/% ./bin/download.sh
	mkdir -p workspace/dcat/$(*F)
	./bin/download.sh $(^) > $@

schemas/dcatapvl.ttl: schemas/dcatapvl.jsonld
	./apache-jena/bin/riot --formatted=turtle schemas/dcatapvl.jsonld > schemas/dcatapvl.ttl

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
.PRECIOUS: workspace/dcat/%/original workspace/dcat/%/original.nt workspace/dcat/%/dcat.nt 
# For performance, no need to process old suffix rules.
.SUFFIXES: 
