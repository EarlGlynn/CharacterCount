.SUFFIXES:  .o .c 

PROGRAM = charcnt 
SOURCE  = charcnt.c
HEADERS = legible.h   

OBJECTS = $(SOURCE:c=o) 
FILES   = $(SOURCE) $(HEADERS)

$(PROGRAM):        $(HEADERS) $(OBJECTS)
	cc -lm -o $(PROGRAM) $(OBJECTS)

.c.o:
	cc  -c $<
