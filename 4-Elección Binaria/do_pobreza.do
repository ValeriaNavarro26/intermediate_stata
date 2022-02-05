cd "..."
use enaho01a-2017-300, clear
keep if p203==1
g urbano=estrato<=5
tab dominio
g sierra=(dominio>=4 & dominio<=6)
g selva=(dominio==7)
tab p301a
g pri_inc=p301a==3
g pri_com=p301a==4
g sec_inc=p301a==5
g sec_com=p301a==6
g sup_inc=p301a==7 | p301a==9 
g sup_com=p301a==8 | p301a==10
drop if p301a>=11

rename p208a edad
tab p209
g casado=p209<=2
tab p207
g hombre=p207==1
save base1, replace

use enaho01a-2017-500, clear
drop if p203==1
g ingprinc=p524e1/4 if p523==4
replace ingprinc=p524e1/2 if p523==3
replace ingprinc=p524e1 if p523==2
replace ingprinc=p524e1*7 if p523==1
g ingh=ingprinc/p523
collapse (mean) inghorhog=ingh, by( conglome vivienda hogar)
su
save base2, replace

use enaho01a-2017-500, clear
lab list p558c
g indigena=p558c>=1 & p558c<=3 | p558c==7 | p558c==9
keep if p203==1
g noblanco=p558c!=5
g noblancomestizo=(p558c!=5 | p558c!=6)
keep conglome vivienda hogar indigena noblanco noblancomestizo
save base3, replace

use sumaria-2017, clear
merge 1:1 conglome vivienda hogar using base1, ///
keepusing(urbano sierra selva pri_inc pri_com sec_inc sec_com sup_inc sup_com edad casado hombre)
merge 1:1 conglome vivienda hogar using base2, ///
keepusing(inghorhog) nogen
merge 1:1 conglome vivienda hogar using base3, ///
keepusing(indigena noblanco noblancomestizo) nogen

g year=2017
g gper=(gashog2d/mieperho)/12
keep  gper year inghorhog factor07 indigena noblanco noblancomestizo conglome linea linpe  vivienda hogar ubigeo dominio estrato urbano sierra selva pri_inc pri_com sec_inc sec_com sup_inc sup_com edad casado hombre mieperho pobreza
g edad2=edad*edad
g pobre=gper<linea
lab def pobre 0 "no pobre" 1 "pobre"
lab val pobre pobre
replace inghorhog=0 if inghorhog==.
saveold basepobreza, replace

use basepobreza, clear

global xlist  pri_inc pri_com sec_inc sec_com sup_inc sup_com edad edad2 urbano sierra selva casado hombre inghorhog indigena
probit pobre $xlist
lroc
lstat, cutoff(0.2225)
lsens, xline(0.2225)
fitstat
prchange
prvalue, x(pri_inc=1 pri_com=0 sec_inc=0 sec_com=0 sup_inc=0 sup_com=0)
prvalue, x(pri_inc=0 pri_com=1 sec_inc=0 sec_com=0 sup_inc=0 sup_com=0)
prvalue, x(pri_inc=0 pri_com=0 sec_inc=1 sec_com=0 sup_inc=0 sup_com=0)
prvalue, x(pri_inc=0 pri_com=0 sec_inc=0 sec_com=1 sup_inc=0 sup_com=0)
prvalue, x(pri_inc=0 pri_com=0 sec_inc=0 sec_com=0 sup_inc=1 sup_com=0)
prvalue, x(pri_inc=0 pri_com=0 sec_inc=0 sec_com=0 sup_inc=0 sup_com=1)

prgen inghorhog, from(0)to(500) n(100) x(hombre=1) g(ph) 
prgen inghorhog, from(0)to(500) n(100) x(hombre=0) g(pm)
 
tw line php1 pmp1 phx, sort legend(lab(1 "hombre") lab(2 "mujer")) ///
xtitle("Ingreso hora promedio del resto") ytitle("Probabilidad") ///
title("Evolución de la pobreza según dependencia de ingresos") ///
subtitle("(Por sexo del encuestado)") 

stepwise, pr(0.1): probit pobre $xlist [pw=factor07]

mfx, at(pri_inc=0 pri_com=0 sec_inc=0 sec_com=0 sup_inc=0 sup_com=0)
mfx
*Caso de la edad
su edad
global m_edad=r(mean)
stepwise, pr(0.1): probit pobre $xlist [pw=factor07]
scalar b_inghorhog=_b[inghorhog]
mfx
mat impacto= e(Xmfx_dydx) '
mat list impacto
di  "f(xb)= " impacto[11,1]/b_inghorhog
scalar fxb=impacto[11,1]/b_inghorhog
stepwise, pr(0.1): probit pobre $xlist [pw=factor07]
di "el impacto de la edad será: " fxb*(_b[edad]+2*_b[edad2]) 

*elasticidades
mfx compute, eyex

