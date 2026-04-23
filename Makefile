
PROGRAMS := $(filter-out play2mid.pas utils.pas,$(wildcard *.pas))
TARGETS := $(PROGRAMS:%.pas=%)

PC := fpc
#PFLAGS := -Mobjfpc -Sh -gh
PFLAGS := -Mobjfpc -Sh -g

def: mml2mid
all: $(TARGETS)

%: %.pas play2mid.pas
	$(PC) $(PFLAGS) $<

test: mml2mid
	./$< samples-beepy/giga_1.txt giga_1.mid

clean:
	rm -fv *.o *.ppu $(TARGETS)
