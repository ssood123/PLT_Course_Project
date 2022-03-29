
.PHONY: default
default: begindefaultwords buildtest rundefaulttest
	
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

.PHONY: clean
clean:
	-rm -f *.o *~ a.out *.native
	-rm -r _build
.PHONY: all
all: clean default
