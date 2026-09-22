clear all
set more off
set seed 12345

cd "/Users/sbc/projects/PhD-Business-Economics-DEN-UDD/Econometria-II-DEN/Tarea3"

capture log close
log using "Tarea3_resultados.log", replace text

use "casen_2024.dta", clear


*==============================================================*
* TAREA 3: BOOTSTRAP, HETEROCEDASTICIDAD Y TAMAÑO MUESTRAL
*==============================================================*


*--------------------------------------------------------------*
* 0. VARIABLES UTILIZADAS
*--------------------------------------------------------------*

describe yoprcor esc edad

* Mostrar nombre y etiqueta de las variables
foreach v in yoprcor esc edad {
    display "`v' = `: variable label `v''"
}


*--------------------------------------------------------------*
* 1. PREPARACIÓN DE LA MUESTRA
*--------------------------------------------------------------*

* El enunciado solicita ingreso de la ocupación principal > 0
keep if yoprcor > 0

* Mantener observaciones con información de escolaridad
drop if missing(yoprcor, esc)

* Logaritmo del ingreso
gen lyoprcor = ln(yoprcor)

label variable lyoprcor ///
    "Log ingreso ocupación principal corregido"

summarize lyoprcor yoprcor esc

count

scalar N_full = r(N)


*==============================================================*
* 2. MUESTRA COMPLETA
*==============================================================*


*--------------------------------------------------------------*
* I. MCO CONVENCIONAL
*--------------------------------------------------------------*

reg lyoprcor esc

scalar b_ols  = _b[esc]
scalar se_ols = _se[esc]

scalar crit_ols = invttail(e(df_r), .025)

scalar li_ols = b_ols - crit_ols*se_ols
scalar ls_ols = b_ols + crit_ols*se_ols


*--------------------------------------------------------------*
* II. MCO CON ERRORES ROBUSTOS HC1
*--------------------------------------------------------------*

reg lyoprcor esc, vce(robust)

scalar b_hc1  = _b[esc]
scalar se_hc1 = _se[esc]

scalar crit_hc1 = invttail(e(df_r), .025)

scalar li_hc1 = b_hc1 - crit_hc1*se_hc1
scalar ls_hc1 = b_hc1 + crit_hc1*se_hc1


*==============================================================*
* III. PAIRED BOOTSTRAP
*     INTERVALO PERCENTIL
*==============================================================*

capture program drop paired_boot

program define paired_boot, rclass

    preserve

    bsample

    quietly regress lyoprcor esc

    return scalar beta1 = _b[esc]

    restore

end


tempfile paired_full

simulate beta1=r(beta1), ///
    reps(999) seed(12345) ///
    saving(`paired_full', replace) nodots: ///
    paired_boot


preserve

use `paired_full', clear

_pctile beta1, p(2.5 97.5)

scalar li_pair = r(r1)
scalar ls_pair = r(r2)

summarize beta1

scalar b_pair_mean = r(mean)
scalar se_pair      = r(sd)

restore


*==============================================================*
* IV. WILD BOOTSTRAP
*     INTERVALO BASADO EN ESTADÍSTICO t
*==============================================================*

* Estimación en la muestra original
reg lyoprcor esc, vce(robust)

scalar beta_hat = _b[esc]
scalar se_hat   = _se[esc]

* Valores ajustados y residuos de la estimación original
predict double yhat, xb
predict double uhat, resid


capture program drop wild_boot

program define wild_boot, rclass

    tempvar v ystar

    /*
    Pesos Rademacher:

            -1 con probabilidad 0.5
             1 con probabilidad 0.5

    E(v) = 0
    Var(v) = 1
    */

    generate double `v' = ///
        cond(runiform() < .5, -1, 1)

    /*
    Generamos:

    y_i* = yhat_i + uhat_i v_i
    */

    generate double `ystar' = ///
        yhat + uhat*`v'

    quietly regress `ystar' esc, vce(robust)

    /*
    Estadístico bootstrap-t:

               beta1* - beta1_hat
    t* = -----------------------------
                    se(beta1*)
    */

    return scalar tstar = ///
        (_b[esc] - beta_hat)/_se[esc]

end


tempfile wild_full

simulate tstar=r(tstar), ///
    reps(999) seed(54321) ///
    saving(`wild_full', replace) nodots: ///
    wild_boot


preserve

use `wild_full', clear

_pctile tstar, p(2.5 97.5)

scalar q025 = r(r1)
scalar q975 = r(r2)

restore


/*
IC bootstrap-t:

[ beta_hat - q_0.975 se_hat ,
  beta_hat - q_0.025 se_hat ]
*/

scalar li_wild = beta_hat - q975*se_hat
scalar ls_wild = beta_hat - q025*se_hat


*==============================================================*
* 3. RESULTADOS MUESTRA COMPLETA
*==============================================================*

display ""
display "======================================================"
display "MUESTRA COMPLETA"
display "======================================================"

display "N = " N_full

display ""
display "MCO convencional"
display "beta1 = " %9.6f b_ols
display "SE    = " %9.6f se_ols
display "IC95% = [" %9.6f li_ols ", " %9.6f ls_ols "]"

display ""
display "HC1"
display "beta1 = " %9.6f b_hc1
display "SE    = " %9.6f se_hc1
display "IC95% = [" %9.6f li_hc1 ", " %9.6f ls_hc1 "]"

display ""
display "Paired bootstrap percentil"
display "Media bootstrap = " %9.6f b_pair_mean
display "SE bootstrap    = " %9.6f se_pair
display "IC95% = [" %9.6f li_pair ", " %9.6f ls_pair "]"

display ""
display "Wild bootstrap-t"
display "beta1 = " %9.6f beta_hat
display "IC95% = [" %9.6f li_wild ", " %9.6f ls_wild "]"


*==============================================================*
* 4. CONSTRUIR UNA ÚNICA MUESTRA ALEATORIA DE N = 100
*==============================================================*

/*
Muy importante:

La muestra de N = 100 se obtiene UNA VEZ y se mantiene
igual para todos los ejercicios posteriores.
*/

set seed 20240818

generate double random = runiform()

sort random

generate muestra100 = (_n <= 100)

count if muestra100 == 1

drop random


*==============================================================*
* 5. MCO CONVENCIONAL N = 100
*==============================================================*

reg lyoprcor esc if muestra100 == 1

scalar b100_ols  = _b[esc]
scalar se100_ols = _se[esc]

scalar crit100_ols = invttail(e(df_r), .025)

scalar li100_ols = ///
    b100_ols - crit100_ols*se100_ols

scalar ls100_ols = ///
    b100_ols + crit100_ols*se100_ols


*==============================================================*
* 6. HC1 N = 100
*==============================================================*

reg lyoprcor esc if muestra100 == 1, vce(robust)

scalar b100_hc1  = _b[esc]
scalar se100_hc1 = _se[esc]

scalar crit100_hc1 = invttail(e(df_r), .025)

scalar li100_hc1 = ///
    b100_hc1 - crit100_hc1*se100_hc1

scalar ls100_hc1 = ///
    b100_hc1 + crit100_hc1*se100_hc1


*==============================================================*
* 7. PAIRED BOOTSTRAP N = 100
*==============================================================*

capture program drop paired100

program define paired100, rclass

    preserve

    keep if muestra100 == 1

    bsample

    quietly regress lyoprcor esc

    return scalar beta1 = _b[esc]

    restore

end


tempfile paired100_999

simulate beta1=r(beta1), ///
    reps(999) seed(12345) ///
    saving(`paired100_999', replace) nodots: ///
    paired100


preserve

use `paired100_999', clear

_pctile beta1, p(2.5 97.5)

scalar li100_pair = r(r1)
scalar ls100_pair = r(r2)

summarize beta1

scalar se100_pair = r(sd)

restore


*==============================================================*
* 8. WILD BOOTSTRAP N = 100
*==============================================================*

reg lyoprcor esc if muestra100 == 1, vce(robust)

scalar beta100_hat = _b[esc]
scalar se100_hat   = _se[esc]

predict double yhat100 if muestra100 == 1, xb
predict double uhat100 if muestra100 == 1, resid


capture program drop wild100

program define wild100, rclass

    tempvar v ystar

    generate double `v' = ///
        cond(runiform() < .5, -1, 1) ///
        if muestra100 == 1

    generate double `ystar' = ///
        yhat100 + uhat100*`v' ///
        if muestra100 == 1

    quietly regress `ystar' esc ///
        if muestra100 == 1, vce(robust)

    return scalar tstar = ///
        (_b[esc] - beta100_hat)/_se[esc]

end


tempfile wild100_999

simulate tstar=r(tstar), ///
    reps(999) seed(54321) ///
    saving(`wild100_999', replace) nodots: ///
    wild100


preserve

use `wild100_999', clear

_pctile tstar, p(2.5 97.5)

scalar q100_025 = r(r1)
scalar q100_975 = r(r2)

restore


scalar li100_wild = ///
    beta100_hat - q100_975*se100_hat

scalar ls100_wild = ///
    beta100_hat - q100_025*se100_hat


*==============================================================*
* 9. RESULTADOS N = 100
*==============================================================*

display ""
display "======================================================"
display "MUESTRA N = 100"
display "======================================================"

display ""
display "MCO convencional"
display "beta1 = " %9.6f b100_ols
display "SE    = " %9.6f se100_ols
display "IC95% = [" %9.6f li100_ols ", " %9.6f ls100_ols "]"

display ""
display "HC1"
display "beta1 = " %9.6f b100_hc1
display "SE    = " %9.6f se100_hc1
display "IC95% = [" %9.6f li100_hc1 ", " %9.6f ls100_hc1 "]"

display ""
display "Paired bootstrap"
display "SE bootstrap = " %9.6f se100_pair
display "IC95% = [" %9.6f li100_pair ", " %9.6f ls100_pair "]"

display ""
display "Wild bootstrap-t"
display "IC95% = [" %9.6f li100_wild ", " %9.6f ls100_wild "]"


*==============================================================*
* 10. N = 100: EFECTO DEL NÚMERO DE RÉPLICAS
*     PROCEDIMIENTO ELEGIDO: PAIRED BOOTSTRAP
*==============================================================*


*--------------------------------------------------------------*
* R = 199
*--------------------------------------------------------------*

tempfile paired199

simulate beta1=r(beta1), ///
    reps(199) seed(777) ///
    saving(`paired199', replace) nodots: ///
    paired100

preserve

use `paired199', clear

_pctile beta1, p(2.5 97.5)

scalar li199 = r(r1)
scalar ls199 = r(r2)
scalar ancho199 = ls199-li199

restore


*--------------------------------------------------------------*
* R = 999
*--------------------------------------------------------------*

tempfile paired999

simulate beta1=r(beta1), ///
    reps(999) seed(777) ///
    saving(`paired999', replace) nodots: ///
    paired100

preserve

use `paired999', clear

_pctile beta1, p(2.5 97.5)

scalar li999 = r(r1)
scalar ls999 = r(r2)
scalar ancho999 = ls999-li999

restore


*--------------------------------------------------------------*
* R = 4,999
*--------------------------------------------------------------*

tempfile paired4999

simulate beta1=r(beta1), ///
    reps(4999) seed(777) ///
    saving(`paired4999', replace) nodots: ///
    paired100

preserve

use `paired4999', clear

_pctile beta1, p(2.5 97.5)

scalar li4999 = r(r1)
scalar ls4999 = r(r2)
scalar ancho4999 = ls4999-li4999

restore


*==============================================================*
* 11. COMPARACIÓN DEL NÚMERO DE RÉPLICAS
*==============================================================*

display ""
display "======================================================"
display "N = 100: NÚMERO DE RÉPLICAS BOOTSTRAP"
display "======================================================"

display ""
display "R = 199"
display "IC95% = [" %9.6f li199 ", " %9.6f ls199 "]"
display "Ancho = " %9.6f ancho199

display ""
display "R = 999"
display "IC95% = [" %9.6f li999 ", " %9.6f ls999 "]"
display "Ancho = " %9.6f ancho999

display ""
display "R = 4999"
display "IC95% = [" %9.6f li4999 ", " %9.6f ls4999 "]"
display "Ancho = " %9.6f ancho4999


log close
