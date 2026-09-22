* fish.do. Estimate a simple 2SLS model using storms as an instrument for price

* ssc install ivreg2
* ssc install weakivtest
* ssc install twostepweakiv
* ssc install moremata

*-> Fulton Fish Market `Stormy' instrument
use "https://github.com/scunning1975/mixtape/raw/master/Fulton.dta", clear

label variable q "Log quantity of whiting sold in pounds"
label variable p "Log average daily price per pound"

reg q p i.Mon i.Tue i.Wed i.Thu, robust
ivregress 2sls q i.Mon i.Tue i.Wed i.Thu (p = Stormy), robust first
weakivtest
twostepweakiv 2sls q (p = Stormy ) i.Mon i.Tue i.Wed i.Thu, robust
  