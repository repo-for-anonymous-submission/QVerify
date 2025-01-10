# Relative_PATH := ../tools/maude
# ABS_PATH=$(shell realpath $(Relative_PATH))
clean_spthy=./tools/clean_spthy
tamarin=./tools/tamarin-prover
TAMARIN_FLAGS= 
# TAMARIN_FLAGS= -c=100
# TAMARIN_FLAGS=+RTS -N16 -RTS # limit number of CPUs used
# TAMARIN_FLAGS=+RTS -s -M1000000000 -RTS # limit amount of memory used

type=EB
Adv=Network
exec=false
auth=false
secrecy=false
ER=FEC
BO=PostM
M4_FLAGS= --define=type=$(type) --define=Adv=$(Adv) --define=auth=$(auth) --define=secrecy=$(secrecy) --define=exec=$(exec) --define=ER=$(ER) --define=BO=$(BO)

# ifeq ($(Adv), Network)
# 	M4_FLAGS=net
# endif

#  make type=EB auth=true ER=REC BO=PostM Adv=Network prove
#  make type=PM auth=true ER=REC BO=SeqA Adv=MaliciousUser  prove

preprocess:
	m4 ${M4_FLAGS} main.m4 > generated_$(type).spthy
	$(clean_spthy) generated_$(type).spthy

test: preprocess
	${tamarin} ${TAMARIN_FLAGS} --quit-on-warning generated_$(type).spthy

prove: preprocess
	${tamarin} ${TAMARIN_FLAGS} --prove --output=generated_$(type).proof generated_$(type).spthy


web: preprocess
	${tamarin} interactive generated_$(type).spthy


gen_proofs:
	chmod a+x ./tools* ./tools/maude/*
	./tools/compile_models
	# ./tools/test_models
	./tools/compile_results | tee run.log
	./tools/collect ./output/

web_proofs: 
	${tamarin} interactive ./output/


all: prove web





clean_user:
	$(RM) -f generated_*
	$(RM) -f client_session_key.aes

clean_tmp:
	$(RM) -f ./output/*.tmp

clean_theory:
	$(RM) -f ./output/*.spthy
	

clean_proofs:
	$(RM) -f ./output/*.proof

clean: clean_user clean_theory clean_proofs clean_tmp
	$(RM) -f run.log
