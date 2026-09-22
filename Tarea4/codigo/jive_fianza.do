* judge_fe.do
* Ejemplo de variables instrumentales y JIVE de Mixtape

clear all
capture log close
set more off

* Instalar JIVE (solo la primera vez)
net from https://www.stata-journal.com/software/sj6-3/
net install st0108

* Cargar datos
use "https://github.com/scunning1975/mixtape/raw/master/judge_fe.dta", clear

* Definir instrumentos y controles
global judge_pre judge_pre_1 judge_pre_2 judge_pre_3 judge_pre_4 ///
    judge_pre_5 judge_pre_6 judge_pre_7 judge_pre_8

global demo black age male white

global off fel mis sum F1 F2 F3 F M1 M2 M3 M

global prior priorCases priorWI5 prior_felChar prior_guilt ///
    onePrior threePriors

global control2 day day2 day3 bailDate t1 t2 t3 t4 t5 t6

* ============================================================
* 1. MCO: comparación sin instrumentar jail3
* ============================================================

* Controles mínimos
reg guilt jail3 $control2, robust

* Controles máximos
reg guilt jail3 possess robbery DUI1st drugSell aggAss ///
    $demo $prior $off $control2, robust

* ============================================================
* 2. Primera etapa: relación entre jueces y prisión preventiva
* ============================================================

* Controles mínimos
reg jail3 $judge_pre $control2, robust

* Controles máximos
reg jail3 $judge_pre possess robbery DUI1st drugSell aggAss ///
    $demo $prior $off $control2, robust

* ============================================================
* 3. Variables instrumentales: 2SLS
* ============================================================

* Controles mínimos
ivregress 2sls guilt $control2 (jail3 = $judge_pre), ///
    vce(robust) first

* Controles máximos
ivregress 2sls guilt possess robbery DUI1st drugSell aggAss ///
    $demo $prior $off $control2 (jail3 = $judge_pre), ///
    vce(robust) first

* ============================================================
* 4. JIVE: estimador jackknife de variables instrumentales
* ============================================================

* Controles mínimos
jive guilt $control2 (jail3 = $judge_pre), robust

* Controles máximos
jive guilt possess robbery DUI1st drugSell aggAss ///
    $demo $prior $off $control2 (jail3 = $judge_pre), robust
