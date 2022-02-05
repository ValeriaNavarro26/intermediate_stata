cd   "..."

use enaho01a-2018-400, clear
egen gsalud=rowtotal(i41601 i41602 i41603 i41604 i41605 i41606 i41607 i41608 i41609 i41610 i41611 i41612 i41613 i41614 i41615 i41616),miss
lab var gsalud "gasto total en salud"
g as=(p4191==1 | p4192==1 |  p4193==1 |  p4194==1 |  p4195==1 |  p4196==1 |  p4197==1 |  p4198==1 )
collapse (sum) gsalud as, by(conglome vivienda hogar)
replace as=1 if as>=1
lab def as 0 "nadie tiene seguro" 1 "al menos algún integrante de la fam tiene seguro"
lab val as as
save salud, replace

use enaho01-2018-601, clear
g gfood=p601c*365 if p601b1==1
replace gfood=p601c*365/2 if p601b1==2
replace gfood=p601c*(12*4) if p601b1==3
replace gfood=p601c*(12*2) if p601b1==4
replace gfood=p601c*(12) if p601b1==5
replace gfood=p601c*(6) if p601b1==6
replace gfood=p601c*(4) if p601b1==7
replace gfood=p601c*(2) if p601b1==8
replace gfood=p601c*(2*12*4) if p601b1==9
replace gfood=p601c*(3*12*4) if p601b1==10
replace gfood=p601c*(4*12*4) if p601b1==11
replace gfood=p601c if p601b1==12
collapse (sum) gfood, by(conglome vivienda hogar)
lab var gfood "gasto en alimentos"
save food, replace

use sumaria-2018, clear
merge 1:1 conglome vivienda hogar using food, nogen
merge 1:1 conglome vivienda hogar using salud, nogen
keep conglome vivienda hogar dominio estrato ubigeo factor07 gfood gsalud as gashog1d inghog2d mieperho
g yper=inghog2d/mieperho
g gb=gsalud/(gashog1d-gfood)
lab var gb "gasto total en salud/(gasto total-gasto comida)"
su gb, d
drop if gb>=1
drop if gb<=0
su gb
replace gb=gb*100
save base1, replace


use enaho01a-2018-300, clear
g niños=p208a<=5
g may=p208a>65
g muj=(p208a>=15 & p208a<=45) & p207==2
collapse (sum) niños may muj, by(conglome vivienda hogar)
lab var niños "número de niños de 0 a 5 años que viven en el hogar"
lab var may "número de personas mayores a 65 años que viven en el hogar"
lab var muj "número de mujeres en edad fértil (15 a 45 años) que viven en el hogar"
save base2, replace

use enaho01a-2018-300, clear
g sexo=p207==1
rename p208a edad
g rural=estrato>=6
lab def sexo 1 "JH hombre" 0 "JH mujer"
lab val sexo sexo
lab var edad "edad del jefe del hogar"
lab def rural 1 "rural" 0 "urbano"
lab val rural rural
keep if p203==1
keep conglome vivienda hogar sexo edad rural
save base3, replace

use enaho01a-2018-300, clear
g educ=0 if p301a<=2
replace educ=p301b if p301a>=3 & p301a<=4
replace educ=p301b+6 if p301a>=5 & p301a<=6
replace educ=p301b+11 if p301a>=7 & p301a<=10
replace educ=p301b+16 if p301a==11
lab var educ "número de años de escolaridad de la pareja del JH"
keep if p203==2
keep conglome vivienda hogar educ
save base4, replace

use enaho01-2018-100, clear
g piso=p103<6
g techo=p103a<=3
g agua=p110<=2
keep conglome vivienda hogar factor07 piso techo agua dominio estrato
lab def piso 1 "hogar con piso firme" 0 "hogar con piso tierra"
lab def techo 1 "hogar con techo firme" 0 "hogar sin techo firme"
lab def agua 1 "hogar cuenta con agua potable" 0 "hogar sin agua potable"
save base5, replace

use base1, clear
merge 1:1 conglome vivienda hogar using base2
keep if _merge==3
drop _merge
merge 1:1 conglome vivienda hogar using base3
keep if _merge==3
drop _merge
merge 1:1 conglome vivienda hogar using base4
keep if _merge==3
drop _merge
merge 1:1 conglome vivienda hogar using base5
keep if _merge==3
drop _merge

xtile quintil1=yper if as==1 [aw=factor07], n(5)
xtile quintil2=yper if as==0 [aw=factor07], n(5)
g ly=ln(yper)

hist gb
recode dominio (1/3 8=1 "Costa")(4/6=2 "Sierra")(7=3 "Selva"),g(region)
reg gb niños may muj edad sexo rural educ piso techo agua
g lg=ln(gb) if gb>0

save base2018, replace

use base2017, clear
g year=2017
append using base2018
replace year=2018 if year==. 


svyset [pw=factor07], strata(estrato) psu(conglome)
forvalue j=1/3 {
forvalue k=0/1 {
qui svy:reg lg niños may muj edad sexo rural educ piso techo agua ly if (region==`j' & as==`k') 
estimates store M`j'`k'
}
}

estimates table M10 M11 M20 M21 M30 M31, star(0.1 0.05 0.01) stat(N r2 )

svy:reg lg niños may muj edad sexo rural educ piso techo agua ly if as==0 
estimates store No_Asegurado
svy:reg lg niños may muj edad sexo rural educ piso techo agua ly if as==1
estimates store Asegurado

estimates table No_Asegurado Asegurado, star(0.1 0.05 0.01)
