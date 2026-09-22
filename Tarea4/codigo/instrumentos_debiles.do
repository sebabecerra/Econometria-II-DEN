* weakiv.do.  

* weakiv.do

clear all
capture log close

* Instalación: ejecutar una vez en este computador
*ssc install weakivtest, replace
*ssc install twostepweakiv, replace
*ssc install avar, replace
*ssc install ivreg2, replace
*ssc install moremata, replace
*ssc install ranktest, replace

* Datos de Mixtape
use "https://raw.githubusercontent.com/scunning1975/mixtape/master/card.dta", clear

* Estimación por variables instrumentales
ivregress 2sls lwage (educ = nearc4), first vce(robust)

* Diagnóstico de instrumentos débiles: F efectivo de Olea–Pflueger
weakivtest

* Inferencia robusta ante instrumentos débiles: intervalos de confianza
twostepweakiv 2sls lwage (educ = nearc4), robust

