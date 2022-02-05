cd "..."
use salario, clear

hist inghor
su inghor
g ling=ln(1+inghor)

g edad2=edad^2
g exper2=exper^2
stepwise, pr(0.10): reg ling hombre casado lengnativa lengextran cronico agua desague electricidad cocina piso metropoli urbano edad  edad2

reg ling hombre  metropoli urbano edad  edad2   exper exper2 educ
ivreg ling hombre  metropoli urbano edad  edad2  exper exper2 (educ=educpadre educmadre)
ivreg2 ling hombre  metropoli urbano edad  edad2  exper exper2 (educ=educpadre educmadre)
ivendog
ivhettest
ivvif

ivreg2 ling hombre  metropoli urbano edad  edad2  exper exper2 (educ=educpadre educmadre), gmm

ivreg2 ling hombre  metropoli urbano edad  edad2  exper exper2 (educ=educpadre educmadre menor18 ), gmm
estimates store m1
reg ling hombre  metropoli urbano edad  edad2  exper exper2 educ
estimates store m2
hausman m1 m2

ivreg2 ling hombre  metropoli urbano edad  edad2  exper exper2 (educ=educpadre educmadre menor18 ), gmm
ivhettest
ivvif

