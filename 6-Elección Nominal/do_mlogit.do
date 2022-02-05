cd "..."
*prima universitaria
forvalue k=2016/2018 {
use enaho01a-`k'-500, clear
g ingprinc=p524e1/4 if p523==4
replace ingprinc=p524e1/2 if p523==3
replace ingprinc=p524e1 if p523==2
replace ingprinc=p524e1*7 if p523==1
g ingh=ingprinc/p523
su ingh, d
replace ingh=. if ingh>r(p99) | ingh<r(p5)
g ingsec2=p541a/4
g ingprinc2=p530a/4
g ingsec=p538e1/4
egen ingtot=rowtotal(ingprinc ingsec ingprinc2 ingsec2)
su ingtot
replace ingtot=ingtot/r(sd)
keep if p301a==6  
gen depart=substr(ubigeo, 1,2)
gen prov=substr(ubigeo, 1,4)
collapse (mean) ingsec=ingh [aw=fac500a], by(depart)
save b1, replace

use enaho01a-`k'-500, clear
g ingprinc=p524e1/4 if p523==4
replace ingprinc=p524e1/2 if p523==3
replace ingprinc=p524e1 if p523==2
replace ingprinc=p524e1*7 if p523==1
g ingh=ingprinc/p523
su ingh,d
replace ingh=. if ingh>r(p99) | ingh<r(p5)
g ingsec2=p541a/4
g ingprinc2=p530a/4
g ingsec=p538e1/4
egen ingtot=rowtotal(ingprinc ingsec ingprinc2 ingsec2)
su ingtot 
replace ingtot=ingtot/r(sd)
keep if p301a==10
su ingtot
gen depart=substr(ubigeo, 1,2)
gen prov=substr(ubigeo, 1,4)
collapse (mean) inguni=ingh [aw=fac500a], by(depart)
save b2, replace

merge 1:1 depart using b1
g prima=ln(inguni)-ln(ingsec)
keep depart prima
save prima1, replace


use enaho01a-`k'-300, clear
g dependiente=((p208a<=6 | p208a>=65) )
bys conglome vivienda hogar: egen ndepend=sum(dependiente)
bys conglome vivienda hogar: gen nperso=_N
g porc_dep=ndepend/nperso
br conglome vivienda hogar codperso ndepend nperso dependiente p208a porc_dep
keep if p203==1
saveold dependientes, replace

use enaho01a-`k'-300, clear
keep if p208a<=23
*keep if p208a>=16
merge 1:1 conglome vivienda hogar codperso using enaho01a-`k'-500, keepusing(ocu500)
keep if _merge==3
drop _merge
merge m:1 conglome vivienda hogar using sumaria-`k', keepusing(pobreza)
keep if _merge==3
drop _merge
merge m:1 conglome vivienda hogar using dependientes, keepusing(porc_dep)
keep if _merge==3
drop _merge
merge m:1 conglome vivienda hogar using educ_jh, keepusing(educ)
keep if _merge==3
drop _merge
g depart=substr(ubigeo, 1,2)
merge m:1 depart  using prima1, nogen

tab pobreza
g pobre=pobreza<=2
lab def pobre 0 "no pobre" 1 "pobre"
lab val pobre pobre

tab ocu500
g trabaja=1 if ocu500>=1 & ocu500<=3
replace trabaja=0 if ocu500==4
tab trabaja

lab list p308a
tab p308a
lab list p310
tab p308a p310, miss
drop if p308a<=3
drop if p308a==7
drop if p308a==6
g estudia=0
replace estudia=1 if p308a==4 | p308a==5 | p310==1


tab trabaja estudia

g actividad=.
replace actividad=3 if trabaja==1 & estudia==0  
replace actividad=1 if p308a==5 & trabaja==0
replace actividad=2 if p308a==4 & trabaja==0
replace actividad=0 if estudia==0 & trabaja==0
tab actividad

lab def actividad 1 "universitario" 2 "no universitario" 3 "trabaja" 0 "otro"
lab val actividad actividad

tab actividad

codebook p304d
g tipo_colegio=1 if p304d==2
replace tipo_colegio=0 if p304d==1
tab tipo_colegio

g jefe=p203==1
lab def jefe 0 "no jefe" 1 "jefe"
lab val jefe jefe

tab p207
g mujer=p207==2
lab def mujer 0 "hombre" 1 "mujer"
lab val mujer mujer

rename p208a edad
g edad2=edad^2

g rural=estrato>=6
lab def rural 0 "urbano" 1 "rural"
lab val rural rural

capture rename factora07 factor07a 
keep conglome vivienda hogar codperso dominio estrato actividad prima educ edad edad2  jefe mujer pobre porc_dep rural factor07a factor07 tipo_colegio
lab var porc_dep "porcentaje de personas dependientes (menores de 6 y mayores de 65) del hogar"
rename educ educjh
lab var educjh "educación del JH"
lab var pobre "caracteristiza la condicion de pobreza del individuo segun el gasto per capita"
lab var tipo_colegio "si el individuo asistio en educ básica a una inst privada o publica"
lab var actividad "actividad que se encuentra desarrollando el individuo"
lab var edad "edad del individuo"
lab var prima "diferencia del ln del salario esperado con educ superior y el correspondiente solo con estudios de secundaria"

lab var jefe "¿es jefe familiar o no?"
lab var mujer "¿es mujer o no?"
lab var rural "¿habita en zona rural?"

drop if tipo_colegio==.

saveold data_estudios`k', replace
}

use data_estudios2016,clear
append using data_estudios2017
append using data_estudios2018
save data_estudios, replace

use data_estudios, clear
global xlist prima educjh tipo_colegio  edad edad2 rural pobre porc_dep jefe 
mlogit actividad $xlist , b(0)

mlogtest, wald set(edad edad2)
mlogtest, lr set(edad edad2)
mlogtest, combine
mlogtest, lrcomb
mlogtest, hausman
set seed 123
mlogtest, sm


*Efectos marginales
prchange
mfx, predict(outcome(0)) 
mfx, predict(outcome(1)) 
mfx, predict(outcome(2)) 
mfx, predict(outcome(3)) 

*Elasticidades
mfx, predict(outcome(0)) eydx 
mfx, predict(outcome(1)) eydx
mfx, predict(outcome(2)) eydx
mfx, predict(outcome(3)) eydx

*Probabilidades con Ratio
listcoef, pval(0.05) percent

*Pr value y prtab
prvalue
prtab edad jefe

su prima
prgen prima, from(0)to(0.67) n(100) x(rural=0) gen(pu)
prgen prima, from(0)to(0.67) n(100) x(rural=1) gen(pr)

su prima
local j=0
foreach i in Otro Universidad Tecnica Trabaja  {
tw line pup`j' prp`j' prx , title("Probabilidad de estar en `i'") name(g`j', replace) ///
legend(lab(1 "urbano") lab(2 "rural")) xtitle("Prima universitaria") ytitle("Probabilidad")
local j=`j'+1
}
gr combine g0 g1 g2 g3

mlogview

/*
Cameron, A. Colin and Pravin K. Trivedi. 2005. Microeconometrics:
Methods and applications, Cambridge: Cambridge University Press.
———. 2009. Microeconometrics Using Stata, College Station, Texas:
Stata Press.
Long, J. Scott and Jeremy Freese. 2006. Regression models for
categorical dependent variables using Stata, College Station, Texas:
Stata Press.
Wooldridge, Jeffrey. 2002. Econometric Analysis of Cross Section and
Panel Data, Cambridge, Massachusetts: MIT Press

*/
