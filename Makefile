export MODEL_BASENAME=astinxml
export REPO_NAME=astinxml
export GITHUB_ORGANIZATION=kode-konveyor

#rules.python

all: deliver documentation

#include rules.zenta

documentation: zentaworkaround $(MODEL_BASENAME).compiled
	mv $(MODEL_BASENAME) shippable

deliver: compile
	mv dist shippable
	touch deliver

compile: tests shippable
	./setup.py bdist_wheel
	touch compile

shippable:
	mkdir -p shippable

tests:	unittest mutationtest
	touch tests

unittest:
	pyTestRunner
	touch unittest

mutationtest:
	python3 -m mutmut run
	touch mutationtest

publish_release:
	cat ~/.pypirc | sed 's/[A-Z]/X/g'
	python3 -m twine upload shippable/dist/*

clean:
	git clean -fdx


#rules.zenta

TOOLCHAINDIR = /usr/local/toolchain

inputs/$(MODEL_BASENAME).issues.xml: shippable/$(MODEL_BASENAME)-implementedBehaviours.xml shippable/$(MODEL_BASENAME)-testcases.xml
	mkdir -p inputs
	$(TOOLCHAINDIR)/tools/getGithubIssues >inputs/$(MODEL_BASENAME).issues.xml


codedocs: shippable/$(MODEL_BASENAME)-testcases.xml shippable/$(MODEL_BASENAME)-implementedBehaviours.xml shippable/$(MODEL_BASENAME)-implementedBehaviours.html shippable/bugpriorities.xml

shippable/$(MODEL_BASENAME)-testcases.xml: $(MODEL_BASENAME).richescape shippable
	zenta-xslt-runner -xsl:xslt/generate_test_cases.xslt -s $(MODEL_BASENAME).richescape outputbase=shippable/$(MODEL_BASENAME)-

shippable/$(MODEL_BASENAME)-implementedBehaviours.xml: buildreports shippable
	zenta-xslt-runner -xsl:xslt/generate-behaviours.xslt -s target/test/ast.xml outputbase=shippable/$(MODEL_BASENAME)-

CONSISTENCY_INPUTS=shippable/$(MODEL_BASENAME)-testcases.xml shippable/$(MODEL_BASENAME)-implementedBehaviours.xml

include /usr/share/zenta-tools/model.rules

$(MODEL_BASENAME).consistencycheck: $(MODEL_BASENAME).rich $(MODEL_BASENAME).check $(CONSISTENCY_INPUTS)
	zenta-xslt-runner -xsl:xslt/consistencycheck.xslt -s:$(basename $@).check -o:$@ >$(basename $@).consistency.stderr 2>&1
	sed 's/\//:/' <$(basename $@).consistency.stderr |sort --field-separator=':' --key=2

zentaworkaround:
	mkdir -p ~/.zenta/.metadata/.plugins/org.eclipse.e4.workbench/
	cp $(TOOLCHAINDIR)/etc/workbench.xmi ~/.zenta/.metadata/.plugins/org.eclipse.e4.workbench/
	touch zentaworkaround

shippable/bugpriorities.xml: $(MODEL_BASENAME).consistencycheck inputs/$(MODEL_BASENAME).issues.xml $(MODEL_BASENAME).richescape shippable
	zenta-xslt-runner -xsl:xslt/issue-priorities.xslt -s:$(MODEL_BASENAME).consistencycheck -o:shippable/bugpriorities.xml issuesfile=inputs/$(MODEL_BASENAME).issues.xml modelfile=$(MODEL_BASENAME).richescape missingissuefile=shippable/missing.xml

# end includes
#
buildreports: target/test/ast.xml target/src/ast.xml

target/test/ast.xml: target
	PYTHONPATH=src python3 -m astinxml $(PWD)/test >target/test/ast.xml

target/src/ast.xml: target
	PYTHONPATH=src python3 -m astinxml $(PWD)/src >target/src/ast.xml

target:
	mkdir -p target/src target/test

