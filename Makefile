
.PHONY: default
default: begindefaultwords buildtest rundefaulttest testsemantics
	
begindefaultwords:
	@echo "running default behaviour"
buildtest: beginbuildtestwords 
	ocamlbuild test.native
	@echo "test finished building"
beginbuildtestwords:
	@echo "building the test:"
rundefaulttest:
	@echo "running default test:"
	./test.native < exampleinput.txt
	@echo "finished default test"
runtest:
	@echo "running test":
	./test.native
	@echo "finished test"

.PHONY: testsemantics
testsemantics:
	begintestingsemanticswords buildsemtest runsemtest

begintestingsemanticswords:
	@echo "testing the semantics piece"
buildsemtest:
	ocamlbuild testsemantics.native
	@echo "finished building the semantics test"
runsemtest:
	./testsemantics.native






.PHONY: clean
clean:
	-rm -f *.o *~ a.out *.native
	-rm -r _build
.PHONY: all
all: clean default
