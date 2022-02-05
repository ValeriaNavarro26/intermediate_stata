cd "..."
use rendimientos, clear

d
tab cat_beca
lab list categoria

tab programa
lab list programa

tabstat rend, stat(mean median sd) by(programa)
gr box rend, by(programa)

ttest rend, by(programa)
h ttest
ttest rend, by(programa) unequal

reg rend programa

corr rend pctbeca
tabstat rend, stat(mean median sd) by(cat_beca)
gr box rend, over(cat_beca)

reg rend cat_beca
tab cat_beca, g(cat)
list cat_beca cat1 cat2 cat3 in 1/10, nolab

reg rend cat1 cat2
reg rend cat2 cat3 programa
su rend if cat2==0 & cat3==0 & programa==0
g cat2Xprog=cat2*programa
g cat3Xprog=cat3*programa
reg rend cat2 cat3 programa cat2Xprog cat3Xprog

reg rend cat2 cat3 programa cat2Xprog cat3Xprog padre_sined cert_doc
test cat2Xprog cat3Xprog
test padre_sined=-cert_doc

mfx, eyex

char cat_beca[omit] 1
xi: reg rend  i.cat_beca*programa padre_sined cert_doc

reg rend programa i.cat_beca i.cat_beca#i.programa padre_sined cert_doc
