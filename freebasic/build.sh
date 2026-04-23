
fbc -w all -g -exx -s console sarabande.bas -d DEBUG

exit 0

fbc -help
fbc -version
fbc -w all -g -exx -s console %1
fbc -pp %1
fbc -w pedantic %1
fbc -exx -s console %1
fbc -s console %1 fblogo.rc
fbc -s console %1 >> fbc.log 2>&1
fbc -gen gcc -r %1
