clear all
set more off

cd "/Users/sbc/projects/PhD-Business-Economics-DEN-UDD/Econometria-II-DEN/Tarea3/"

use "data/casen_2024.dta", clear


*******************************************************
* 1. PREPARAR DATOS
*******************************************************

keep if yoprcor > 0
drop if missing(yoprcor, esc)

gen lyoprcor = ln(yoprcor)


*******************************************************
* 2. MUESTRA COMPLETA
*******************************************************

* MCO
reg lyoprcor esc

* HC1
reg lyoprcor esc, vce(robust)

* Paired bootstrap, R = 999
bootstrap _b[_cons] _b[esc], reps(999) seed(12345): ///
    reg lyoprcor esc

estat bootstrap, percentile


*******************************************************
* 3. WILD BOOTSTRAP-t
*******************************************************

* Modelo original
reg lyoprcor esc, vce(robust)

scalar b0  = _b[_cons]
scalar b1  = _b[esc]
scalar se0 = _se[_cons]
scalar se1 = _se[esc]

predict yhat, xb
predict uhat, resid


capture program drop wildboot

program define wildboot, rclass

    tempvar v ystar

    * Pesos -1 / +1
    gen `v' = cond(runiform() < .5, -1, 1)

    * Crear y*
    gen `ystar' = yhat + uhat*`v'

    * Reestimar con HC1
    quietly reg `ystar' esc, vce(robust)

    * Guardar beta* y t*
    return scalar b0 = _b[_cons]
    return scalar b1 = _b[esc]

    return scalar t0 = (_b[_cons] - b0) / _se[_cons]
    return scalar t1 = (_b[esc] - b1) / _se[esc]

end


simulate b0=r(b0) b1=r(b1) ///
         t0=r(t0) t1=r(t1), ///
         reps(999) seed(12345): wildboot


* EE wild
sum b0
scalar se_wild0 = r(sd)

sum b1
scalar se_wild1 = r(sd)

* Percentiles t*
_pctile t0, p(2.5 97.5)
scalar q025_0 = r(r1)
scalar q975_0 = r(r2)

_pctile t1, p(2.5 97.5)
scalar q025_1 = r(r1)
scalar q975_1 = r(r2)

* IC wild bootstrap-t
scalar LI_wild0 = b0 - q975_0*se0
scalar LS_wild0 = b0 - q025_0*se0

scalar LI_wild1 = b1 - q975_1*se1
scalar LS_wild1 = b1 - q025_1*se1

display "Beta 0: " b0
display "EE Wild: " se_wild0
display "IC 95%: [" LI_wild0 ", " LS_wild0 "]"

display "Beta 1: " b1
display "EE Wild: " se_wild1
display "IC 95%: [" LI_wild1 ", " LS_wild1 "]"


*******************************************************
* 4. MUESTRA N = 100
*******************************************************

use "data/casen_2024.dta", clear

keep if yoprcor > 0
drop if missing(yoprcor, esc)

gen lyoprcor = ln(yoprcor)

set seed 12345
sample 100, count


*******************************************************
* 5. N = 100
*******************************************************

* MCO
reg lyoprcor esc

* HC1
reg lyoprcor esc, vce(robust)

* Paired bootstrap
bootstrap _b[_cons] _b[esc], reps(999) seed(12345): ///
    reg lyoprcor esc

estat bootstrap, percentile


*******************************************************
* 6. PREGUNTA 6: CAMBIAR R
*******************************************************

* R = 199
bootstrap _b[_cons] _b[esc], reps(199) seed(12345): ///
    reg lyoprcor esc

estat bootstrap, percentile

* R = 999
bootstrap _b[_cons] _b[esc], reps(999) seed(12345): ///
    reg lyoprcor esc

estat bootstrap, percentile

* R = 4999
bootstrap _b[_cons] _b[esc], reps(4999) seed(12345): ///
    reg lyoprcor esc

estat bootstrap, percentile
