'=============================================================================
' SOLFEGG.BAS
' Erstellt in QuickBASIC 1991
' Bearbeitet fuer FreeBASIC 08.01.2011
'=============================================================================

#include "play2mid.bas"

dim as string Soso, Dada, Lala, Aha, Nana, Mama, Papa, Coco, Gaga, Wawa

print "Philipp Emanuel Bach "
print "       ( 1714-1788 ):"
print "     --------------"
print "      SOLFEGGIETTO "
print "     --------------"

Soso = "T100 o1 L16 E-CE-G o2CE-DC o1 BGB o2 DGFE-DE-CE-G o3 CE-DCDC o2BAGFE-DE-" _
       + "CE-G o3 CE-DC o2BGB o3 DGFE-DE-CE-Go4CE-DCDC o3BAGFE-D"
Dada = "T100 L16 o3 E-C o2 GE-C o4 C o3 GE-A- o1 FA- o2 CFA- o3 CE-D o2 B-FD" _ 
       + "o1 B- o3 B-FDG o1E-GB- o2 E-GB- o3DC o2AG+A o3C o2AG+A o3 E-C o2GA" _
       + "o3 E-C o2GA o3 DC o2 F+A"
Lala = "T100 L16 o3 AC o2 F+A o3 F+C o2DA o3C o2 AF+DB-o0 GB-o1 DGB-AGF+DF+A" _
       + "o2 DC o1B-AB-GB-o2DGB-AGAGF+EDC o1B-AB-GB- o2 DGB-AGF+DF+A o3 DC o2 B-AB-"
Aha  = "T100 L16 o2 GB- o3 DGB-AGAGF+EDC o2 B-AB-GB- o3 DGD o2 B-G o1 F o3 GD" _
       + "o2 BGB o3 DGC o2 G o3 G o2 G o3 C o2 G o3 G o2 GBG o3 F o2 GBG o3 F o2 G"
Nana = "T100 L16 o3 E-CE-G o4 C o3 GE-C o1 B- o4 C o3 GECEG o4 C o3 FC o4C o3 CFC" _
       + "o4 C o3 CECB-CECB-CA- o0 FA- o1 CFA-GFECEG o2 C o1 B-A-GA-FA- o2 CFA-GFGFEDC"
Mama = "T100 L16 o1 B-A-GA-FA- o2 CFA-GFECEG o3 C o2 B-A-GA-FA- o3 CFA-GFGFEDC" _
       + "o2 B-A-GA- o3 FC o2 A-F o3 C o2 A-FCA-FC o1 A- o2 FC o1 A- L2 D-L16 o3 A-FEFGFEF"
Papa = "T100 l2 o1 C L16 o2 A-FEFGFEF L2 o1 D L16 o4 D o3 FGA-GFE-DE-G o4 C o3 GB-A-GF" _
       + "L4 E- L32 E-DE-DE-D L16 CDC o2 G o3 G o2 G o3 C o2 G o3 G o2 GBG o3 F o2GBG o3 F o2 G"
Coco = "T100 L16 o2 B-G o3 E o2 GB-G o3 E o2 GA o3 E- o4 C o3 E- o2A o3E- o4C o3 E-" _
       + "o2 A-F o3 D o2 FA-F o3 D o2 FG o3 D-B-D- o2 G o3 D-B-D-"
Gaga = "T100 L16 o2 F+E- o3 C o2 E-F+E- o3 C o2 E- E- o3 C o4 C o3 C o2 E- o3 C" _
       + "o4 C o3 C o2 E- o3 CE-G o4 C o3 GE-CGE-C o2 G o3 FD o2 BFE- o1 CE-G o2 CE-DC o1 B"
Wawa = "T100 L16 o1 GB o2 DGFE-DE-CE-G o3CE-DCDC o2 BAGFE-DE-CE-G o3 CE-DC o2 BGB" _
       + "o3DGFE-DE-CE-G o4 CE-DC o3 B o4 L4 C."

midiFileName = "solfegg.mid"
PLAY Soso + Dada + Lala + Aha + Nana + Mama + Papa + Coco + Gaga + Wawa
