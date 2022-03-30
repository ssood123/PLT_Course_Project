
.PHONY: default
default: begindefaultwords buildtest rundefaulttest defaulttestsemantics
	
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
	@echo "running scanner parser ast test. Input test string: "
	./test.native
	@echo "finished test"


.PHONY: defaulttestsemantics
defaulttestsemantics: buildsemtest rundefaultsemtest

rundefaultsemtest:
	@echo "running default test:"
	./testsemantics.native < exampleinput.txt



.PHONY: testsemantics
testsemantics: buildsemtest runsemtest

buildsemtest:
	@echo "testing the semantics piece"
	ocamlbuild testsemantics.native
	@echo "finished building the semantics test"

runsemtest:
	@echo "running semantics test. Input test string: "
	./testsemantics.native 

.PHONY: bigtest
bigtest:
	ocamlbuild test.native
	@echo "test finished building"
	@echo "running bigtest:"
	./test.native < semiexhaustivetestinput.txt



.PHONY: clean
clean:
	-rm -f *.o *~ a.out *.native
	-rm -r _build
.PHONY: all
all: clean default
