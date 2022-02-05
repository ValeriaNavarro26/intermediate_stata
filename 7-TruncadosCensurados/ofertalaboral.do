cd "..."
use enaho01a-2016-500, clear
egen horas=rowtotal(p518 p513t)
replace horas=. if horas==0
g mas60horas=horas>60 & horas!=.
g jefe=p203==1
g urbano=estrato<=5

keep if urbano==1

g lima=dominio==8
lab def lima 1 "lima" 0 "resto urbano"
lab val lima lima

g sexo= p207==1
lab def sexo 0 "mujer" 1 "hombre", replace
lab val sexo sexo
rename p208a edad

keep if edad<=65

g ingprin=p524a1*7 if p523==1
replace ingprin=p524a1 if p523==2
replace ingprin=p524a1/2 if p523==3
replace ingprin=p524a1/4 if p523==4
replace p538a1=p538a1/4
egen ingsem=rowtotal(ingprin p538a1)
replace ingsem=. if ingsem==0
g inghor=ingsem/horas
su inghor, d
replace inghor=. if inghor<r(p5) | inghor>r(p99)

merge 1:1 conglome vivienda hogar codperso using enaho01a-2016-300, keepusing(p301b)
keep if _merge==3
drop _merge

g educ=.
replace educ=0 if p301a<=2
replace educ=p301b if p301a>=3 & p301a<=4
replace educ=p301b+6 if p301a==5
replace educ=11 if p301a==6
replace educ=p301b+11 if p301a>=7 & p301a<=10
replace educ=p301b+16 if p301a==11


g  ocupsec=p517<=4 | p517==6
g trabasalariado=p507!=2
replace trabasalariado=. if p507==.
g persjurid=p510a1==1
replace persjurid=. if p510a1==.
recode p510b (1=1 "si") (2=0 "no"), g(libros)
g descley=p524b1>0 & p524b1<.
g empr_pub=p510>=2 & p510<=3


g casado=p209<=2

gen ActEcon=0
replace ActEcon = 1 if (p506>=111 & p506<=1499) /*A,B,C*/
replace ActEcon = 2 if (p506>=1500 & p506<=3799) /*D*/
replace ActEcon = 3 if (p506>=4500 & p506<=4599) /*F*/
replace ActEcon = 4 if (p506>=5000 & p506<=5299) /*G*/
replace ActEcon = 5 if (p506>=6000 & p506<=6499) /*I*/
replace ActEcon = 6 if (p506>=9500 & p506<=9599) /*P*/
replace ActEcon = 7 if  ActEcon==0                  /*E,H,J,K,L,M,N,O,Q*/

lab def  ActEcon 1 "Extractiva" 2 "Manufactura"  3 "Construcción" ///
 4 "Comercio" 5 "Transporte, Almacenamiento y Comunicaciones" ///
 6 "Hogares" 7 "Otras Actividades"
lab val ActEcon ActEcon
lab var ActEcon "Actividad Económica"
tab ActEcon, g(ActEcon)
 
rename ActEcon1 Extractiva
rename ActEcon2 Manufactura 
rename ActEcon3 Construccion
rename ActEcon4 Comercio
rename ActEcon5 Transporte
rename ActEcon6 Hogares
rename ActEcon7 Otras
 
g exper1=edad-educ-5
g exper2=edad-14
g exper=min(exper1 ,exper2)
replace exper=0 if exper<0
drop exper1 exper2

g culmi_prim=p301a>=4
g culmi_sec=p301a>=6
g culmi_sup=(p301a>=10 | p301a==8)

g emp100_500=p512a==4
g emp500_mas=p512a==5

g independiente=p507==2

g ocupado=0
replace ocupado=1 if ocu500<=3

g exper2=exper^2
g edad2=edad^2

tab dominio, g(region)
rename region1 c_norte
rename region2 c_centro
rename region3 c_sur
rename region4 s_norte
rename region5 s_centro
rename region6 s_sur


g hijos=0
replace hijos=1 if p203==3 & edad<=18
bys conglome vivienda hogar: egen nhijos=sum(hijos)
bys conglome vivienda hogar: gen nperso=_N


forval k=1/8 {
gen rent`k'=p557`k'c*7 if p557`k'b==1
replace rent`k'=p557`k'c if p557`k'b==2
replace rent`k'=p557`k'c/2 if p557`k'b==3
replace rent`k'=p557`k'c/4 if p557`k'b==4
replace rent`k'=p557`k'c/8 if p557`k'b==5
replace rent`k'=p557`k'c/12 if p557`k'b==6 
replace rent`k'=p557`k'c/24 if p557`k'b==7
replace rent`k'=p557`k'c/48 if p557`k'b==8
}
egen ingnolab1=rowtotal(rent1 rent2 rent3 rent4 rent5 rent6 rent7 rent8)

forval k=1/8 {
gen trans`k'=p556`k'c*7 if p556`k'b==1
replace trans`k'=p556`k'c if p556`k'b==2
replace trans`k'=p556`k'c/2 if p556`k'b==3
replace trans`k'=p556`k'c/4 if p556`k'b==4
replace trans`k'=p556`k'c/8 if p556`k'b==5
replace trans`k'=p556`k'c/12 if p556`k'b==6 
replace trans`k'=p556`k'c/24 if p556`k'b==7
replace trans`k'=p556`k'c/48 if p556`k'b==8
}
egen ingnolab2=rowtotal(trans1 trans2 trans3 trans4 trans5 trans6 trans7 trans8)


forval k=1/8 {
gen trans2`k'=p556`k'e*7 if p556`k'b==1
replace trans2`k'=p556`k'e if p556`k'b==2
replace trans2`k'=p556`k'e/2 if p556`k'b==3
replace trans2`k'=p556`k'e/4 if p556`k'b==4
replace trans2`k'=p556`k'e/8 if p556`k'b==5
replace trans2`k'=p556`k'e/12 if p556`k'b==6 
replace trans2`k'=p556`k'e/24 if p556`k'b==7
replace trans2`k'=p556`k'e/48 if p556`k'b==8
}
egen ingnolab3=rowtotal(trans21 trans22 trans23 trans24 trans25 trans26 trans27 trans28)

gen ingnolab4=p558t/48

egen ingnolab=rowtotal(ingnolab1 ingnolab2 ingnolab3 ingnolab4)
gen ingnolabhper=(ingnolab/horas)/nperso

merge m:1 conglome vivienda hogar using sumaria-2016, keepusing(factor07 gashog2d mieperho pobreza)
g gasper=gashog2d/mieperho
xtile quintil=gasper [aw=factor07], n(5)
xtile decil=gasper [aw=factor07], n(10)

keep ocupado empr_pub ingnolabhper decil quintil pobreza conglome vivienda hogar ubigeo edad edad2 fac500a horas  jefe urbano lima sexo educ casado inghor ocupsec trabasalariado persjurid libros descley  Extractiva Manufactura Construccion Comercio Transporte Hogares Otras ActEcon c_norte c_centro c_sur s_norte s_centro s_sur nhijos  exper culmi_prim culmi_sec culmi_sup emp100_500 emp500_mas independiente ocupado exper2 edad2 

save baseoferta, replace


use baseoferta, clear
global xb edad edad2  jefe casado ingnolabhper nhijos
global xb2 sexo exper  exper2  culmi_prim culmi_sec culmi_sup  emp100_500 emp500_mas independiente descley libros 
heckman inghor $xb2 if lima==1, select(ocupado=$xb)  nolog
predict w1, yexpected
hist w1
tw (hist w1)(hist inghor, color(red))
global xb3 edad edad2 sexo casado jefe nhijos ingnolabhper  w1 Extractiva Manufactura Construccion Comercio Transporte Hogares independiente ocupsec empr_pub libros lima c_norte c_centro c_sur s_norte s_centro s_sur
tobit horas $xb3 [pw=fac500a], ll(0)
margins, dydx(w1) predict(e(0,.))
margins, eyex(w1) predict(e(0,.))


global xb4 edad edad2 sexo casado jefe nhijos ingnolabhper  w1 
tobit horas $xb4 [pw=fac500a], ll(0) 
margins, dydx(*) predict(e(0,.))


*Evaluación por sexo
bys sexo: tobit horas $xb3 [pw=fac500a], ll(0)
*Evaluación por lima
bys lima:tobit horas $xb3 [pw=fac500a], ll(0)
*Evaluación por quintil
bys decil: tobit horas $xb3 [pw=fac500a], ll(0)
bys quintil: tobit horas $xb3 [pw=fac500a], ll(0)
*Evaluación por pobreza
bys pobreza: tobit horas $xb3 [pw=fac500a], ll(0)


tobit horas $xb3 [pw=fac500a] if pobreza==3 & quintil==5, ll(0)
