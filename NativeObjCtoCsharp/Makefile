# Compiler and Linker flags
CFLAGS=-fobjc-arc -Wall -pedantic -Werror
COMP_CFLAGS=-c

# LINK_CFLAGS=-dynamiclib -framework AppKit -framework Foundation -framework CoreGraphics
LINK_CFLAGS=-dynamiclib -framework Cocoa

# Source and Object files
SRC=$(wildcard Source/*.m)
OBJ=$(patsubst Source/%.m, obj/%.o, $(SRC))

# Target library
LIB=NativeSharp.dylib

all: $(LIB)

$(LIB): $(OBJ)
	clang $(CFLAGS) $(LINK_CFLAGS) -o $@ $^

obj/%.o: Source/%.m
	mkdir -p obj
	clang $(CFLAGS) $(COMP_CFLAGS) $< -o $@

clean:
	rm -rf $(LIB) obj
