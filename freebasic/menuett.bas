'==============================================================================
' Menuett_Krieger.bas
' Menuett von Johann Krieger
' Erstellt am 10.01.2011
'==============================================================================

#include "play2mid.bas"

dim as string a, b, c, d, e, f, g

print "Menuett in A-Moll"
print "von Johann Krieger (1651 - 1735)"

a = "T100 O3 L4 ec<a >L8fgfeL4f L4d<bg >L8efedL4e <L4a.L8>c<ba L4g+e>e L8dc<L4b.L8a L2a."
b = "T100 O3 L4 cde <agf b>cd <gfe ab>c <bg>g L8feL4d.L8c L2c."

midiFileName = "menuett.mid"
Play a + a + b + a + b + a
