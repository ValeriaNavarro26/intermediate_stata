cd "..."
use rendimientos, clear

gr box rend, over(programa)
gr box rend, over(cat_beca)
tab cat_beca, g(catbeca)
g progXcat2=programa*catbeca2
g progXcat3=programa*catbeca3
g progXcat1=programa*catbeca1
xi:reg rend programa catbeca3 catbeca1 progXcat3  progXcat1 cert_doc padre_sined
predict r1, resid
swilk r1
sfrancia r1
jb r1
sktest r1

ovtest
linktest

vif 
collin  programa catbeca3 catbeca1 progXcat3  progXcat1 cert_doc padre_sined
fgtest rend programa catbeca3 catbeca1 progXcat3  progXcat1 cert_doc padre_sined

imtest, white
hettest
