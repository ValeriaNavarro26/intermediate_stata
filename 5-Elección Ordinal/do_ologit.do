cd "..."
use basepobreza, clear
recode pobreza (1=3 "pobre extremo")(2=2 "pobre no extremo")(3=1 "no pobre"), g(Pobreza)
drop pobreza
global xlist pri_inc pri_com sec_inc sec_com sup_inc sup_com edad edad2 casado hombre

*Modelo Ordinal
version 9
ologit Pobreza $xlist
brant 

predict pr1 pr2 pr3

dotplot pr1 pr2 pr3

fitstat
prchange
prvalue, x(pri_inc=1 pri_com=0 sec_inc=0 sec_com=0 sup_inc=0 sup_com=0)
prvalue, x(pri_inc=0 pri_com=1 sec_inc=0 sec_com=0 sup_inc=0 sup_com=0)
prvalue, x(pri_inc=0 pri_com=0 sec_inc=1 sec_com=0 sup_inc=0 sup_com=0)
prvalue, x(pri_inc=0 pri_com=0 sec_inc=0 sec_com=1 sup_inc=0 sup_com=0)
prvalue, x(pri_inc=0 pri_com=0 sec_inc=0 sec_com=0 sup_inc=1 sup_com=0)
prvalue, x(pri_inc=0 pri_com=0 sec_inc=0 sec_com=0 sup_inc=0 sup_com=1)

su edad
prgen edad, from(15)to(98) n(83) x(hombre=0) gen(ph)
prgen edad, from(15)to(98) n(83) x(hombre=1) gen(pm)

tw line php1 pmp1 phx, c(l l) xtitle("Edad") ytitle("Probabilidad") ///
legend(lab(1 "hombre") lab(2 "mujer")) ///
title("Probabilidad de ser Pobre Extremo") name(g1, replace)

tw line php2 pmp2 phx, c(l l) xtitle("Edad") ytitle("Probabilidad") ///
legend(lab(1 "hombre") lab(2 "mujer")) ///
title("Probabilidad de ser Pobre") name(g2, replace)

tw line php3 pmp3 phx, c(l l) xtitle("Edad") ytitle("Probabilidad") ///
legend(lab(1 "hombre") lab(2 "mujer")) ///
title("Probabilidad de ser No Pobre") name(g3, replace)

gr combine g1 g2 g3

listcoef
listcoef, percent

ologit Pobreza $xlist sierra selva urbano [pw=factor07], nolog
di -_b[edad]/(2*_b[edad2])
mfx, predict(outcome(1)) at(pri_inc=0 pri_com=0 sec_inc=0 sec_com=0 sup_inc=0 sup_com=0)
mfx, predict(outcome(2)) at(pri_inc=0 pri_com=0 sec_inc=0 sec_com=0 sup_inc=0 sup_com=0)
mfx, predict(outcome(3)) at(pri_inc=0 pri_com=0 sec_inc=0 sec_com=0 sup_inc=0 sup_com=0)


