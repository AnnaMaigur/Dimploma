111111
pwd
cd "C:\Users\annma\Downloads"
import delimited "C:\Users\annma\Downloads\HEshare.csv", encoding(UTF-8) clear
keep if subject == "TOT"
rename value HEshare
label var HEshare "% of GDP"
drop indicator subject measure frequency flagcodes
save HEshare

import delimited "C:\Users\annma\Downloads\PHEshare.csv", encoding(UTF-8) clear
rename value PHEshare
label var PHEshare "% of GDP"
drop indicator subject measure frequency flagcodes
save PHEshare, replace

import delimited "C:\Users\annma\Downloads\VOLshare.csv", encoding(UTF-8) clear
rename value VOLshare
label var VOLshare "% of GDP"
drop indicator subject measure frequency flagcodes
save VOLshare

import delimited "C:\Users\annma\Downloads\OOPshare.csv", encoding(UTF-8) clear
rename value OOPshare
label var OOPshare "% of GDP"
drop indicator subject measure frequency flagcodes
save OOPshare

import delimited "C:\Users\annma\Downloads\realGDP.csv", encoding(UTF-8) clear
rename value GDP2015
rename GDP2015 GDP
label var GDP "GDP per head, US $, constant prices, constant PPPs, reference year 2015"
keep location time GDP2015 
save GDP2015


***********************************************
*                DOCUMENT                     *
***********************************************
cd "C:\Users\annma\Downloads"

use OOPshare, clear
merge 1:1 time location using VOLshare
rename VOLshare PrHEshare 
gen VOLshare = PrHEshare-OOPshare
label var PrHEshare "% of GDP"
drop _merge
merge 1:1 time location using PHEshare
drop _merge
merge 1:1 time location using HEshare
drop _merge
merge 1:1 time location using GDP2015
drop if _merge==2
rename _merge merge_GDP
gen HE_real= HEshare*GDP/100
gen PHE_real= PHEshare*GDP/100
gen PrHE_real= PrHEshare*GDP/100
gen OOP_real= OOPshare*GDP/100
gen VOL_real= VOLshare*GDP/100


merge 1:1 time location using EXP_OECD
drop if _merge==1
drop if _merge==2
save EXP_OECD, replace




use EXP_OECD, clear
sort time location
drop if time > 2019
drop if location=="EU28"|location=="G20"|location=="OECD"|location=="G-7"|location=="EU27"|location=="EU27_2020"|location=="OECDE"|location=="OAVG"|location=="WLD"|location=="EA19"|location=="EA"
*I dropped BGR
// I decided to replace dah_17 =. with 0
*replace dah_17=0 if dah_17==.
//I am not sure but maybe it is better to delete all the observations where dependent vars equal .
*drop if HE_real==. & PHE_real == . & PrHE_real == . 
encode location, generate(country)
xtset country time
drop merge*
save EXP_withRUS, replace
****************************************************


*****************Graph 1***************************
*drop m*
drop if location =="IDN"|location =="IND"|location =="CHN"|location =="RUS"|location =="LVA"|location =="LTU"|location =="ZAF"|location =="SVN"|location =="COL"
bysort time: egen mHE=mean(HE_real) if HE_real!=. &  PHE_real!=. &  PrHE_real!=. 
bysort time: egen mPHE=mean(PHE_real) if HE_real!=. &  PHE_real!=.&  PrHE_real!=. 
bysort time: egen mPrHE=mean(PrHE_real) if HE_real!=. &  PHE_real!=.&  PrHE_real!=. 

twoway scatter mHE time, msymbol(circle_hollow) || connected mPHE time, msymbol(circle_hollow) || connected mPrHE time, msymbol(circle_hollow) 
translate figure.gph figure.wmf
graph export mygraph.wmf, replace
******************Graph 2***************************
graph hbar PrHE_real PHE_O if PHE_real != . & PrHE_real != . & time>2000, over(location,label(labsize(1.5))) stack ytitle("Health spending in US $, constant prices, constant PPPs, reference year 2015.", size(medium)) intensity(25) 

graph hbar VOL_real OOP_real PHE_real if PHE_real != . & OOP_real != . & VOL_real!=. & time>2000 &(location != "IDN"&location != "IND"), over(location,label(labsize(1.5))) stack ytitle("Health spending in US $, constant prices, constant PPPs, reference year 2015.", size(medium)) intensity(25) 

* Оказывается OOP не входит в общие расходы
*drop if location == "USA"
use EXP_withRUS, replace
gen lnDAH = ln(dah_17)
*gen lnUNEM = ln(Unem_OECD)
gen lnUNEM = ln(Unem)
gen lnDOC = ln(Doctors_OECD)
gen ln15 = ln(young_OECD)
gen ln65 = ln(old_OECD)
gen lnDR = ln(CrudeDR)
gen lnIMR = ln(IMR_OECD)
gen lnPubBeds = ln(RatioPubBeds)
gen lnGINI = ln(gini)
*gen lnGovDebt = ln(GovDebt_OECD)
*gen lnTAX = ln(TaxRev_OECD)
gen lnTAX = ln(TAX_WB)

gen lnTaxPers = ln(TaxPersInc_OECD)
gen lnTaxGS = ln(TaxGoodServ_OECD)
*gen lnINS = ln(HealthCov_OECD)
gen lnINS = ln(PubIns)

gen lnWAGE = ln(AvWages_OECD)
gen lnHE = ln(HE_real)
gen lnPHE = ln(PHE_real)
gen lnPrHE = ln(PrHE_real)
gen lnGDP = ln(GDP)
gen lnGovDef = ln(GovDef_OECD)
gen lnGovDebt = ln(GovDebt_WB)
gen lnGovSpend = ln(GovSpend_OECD)
gen lnGovBal = ln(GovBal_WB)
gen lnPHEshare = ln(PHE_real/HE_real)
save EXP_withRUS, replace
keep lnHE lnPHE lnPrHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare lnTaxGS lnTaxPers country location time group
asdoc pwcorr lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnTaxPers lnTaxGS lnINS lnPHEshare

*drop if time <1995


********************************************
*              MODELS                      *
********************************************
*                HE                        *
****************REG1************************
*reg lnHE lnGDP lnUNEM lnDOC ln15 ln65  lnGINI lnGovDebt lnTAX lnINS lnPHEshare lnGovDef 
*1 пока что эта итоговая R-squared       =    0.9310
reg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare 
reg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare if time>1994 & time<2019
*2
reg lnHE lnGDP lnUNEM lnDOC ln65 lnGINI lnGovDebt lnTAX lnINS
*3
xtreg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare, fe
xtreg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare if time>1994 & time<2019, fe

*xtreg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnPubBeds lnGINI lnGovDebt lnTAX lnINS, fe
//I tried to exclude GINI and 15, but i did not include it in text
*reg lnHE lnGDP lnUNEM lnDOC ln65 lnPubBeds lnGovDebt lnTAX lnINS
*xtreg lnHE lnGDP lnUNEM lnDOC ln65 lnPubBeds lnGovDebt lnTAX lnINS, fe

********************************************
*          Without time effects            *
******************************************** 

//this is the final pooled reg
reg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare 
est store poolHE
xtreg lnHE lnGDP lnUNEM lnDOC ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare , fe
est store feHE
*drop _est_fe
*RE
xtreg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare , re
xttest0
est store reHE
*drop _est_re
*est tab pool fe re, b(%7.4f) stats (N r2) star
hausman feHE reHE
outreg2 [poolHE feHE reHE ]  using test.doc, nolabel replace
*drop _est_pool _est_fe _est_re

***********************************************
*                 With time effect            *
***********************************************
quietly tabulate time, generate(new_)
rename (new_1-new_50) year_#, addnumber(1970)

reg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1983-year_2017
est store poolHE_t
testparm year_1983-year_2017

xtreg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1983-year_2017, fe
est store feHE_t
testparm year_1983-year_2017

xtreg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1983-year_2017, re
testparm year_1981-year_2018
xttest0
est store reHE_t
*est tab pool_t fe_t re_t, b(%7.4f) stats (N r2) star
hausman feHE_t reHE_t, sigmamore
outreg2 [poolHE feHE reHE poolHE_t feHE_t reHE_t]  using test.doc, nolabel replace
*est tab pool fe re pool_t fe_t re_t, b(%7.4f) stats (N r2) star
*test year_1981-year_2018
*drop _est_poolHE_t _est_feHE_t _est_reHE_t

///дамми на годы значимы


//time vars are significant so that it is better to check poolability

*********************************************
*               Poolability                 *    
*********************************************
*1) по времени
*Firstly, let's look at xtsum
asdoc xtsum lnHE lnPHE lnPrHE
global LIST "lnGDP_real lnUNEM lnDOC ln65 lnPubBeds lnGINI lnGovDebt lnTaxGS lnTaxPer lnINS lnGovDef lnIMR"
/* усреднение по индивидам в каждой волне */
foreach x of varlist lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare {
    egen mt`x' = mean(`x'), by(time)
	gen dt`x' = `x'-mt`x'
}
* оценивание модели (0) без ограничений *I excluded GovDef PubBeds and Gini because of the lack of obs 
global REG1 "dtlnGDP dtlnUNEM dtlnDOC dtln15 dtln65 dtlnGINI dtlnGovDebt dtlnTAX dtlnINS dtlnPHEshare"
scalar rss_ur=0
scalar n_ur=0
scalar df_ur=0

forvalue i=1995/2018 {
qui reg dtlnHE $REG1 if time==`i'
scalar z`i'=e(rss)
scalar df`i'=e(df_r)
scalar n`i'=e(N)
scalar rss_ur=rss_ur+z`i'
scalar n_ur=n_ur+n`i'
scalar df_ur=df_ur+df`i'
scalar list rss_ur n_ur df_ur 
}
scalar list rss_ur n_ur df_ur 

/* Estimation of model (1) with FE of country */
reg dtlnHE $REG1 if time > 1994 & time< 2019, noconstant
scalar rss_r1 = e(rss)
scalar n_r1=e(N)
scalar df_r1=e(df_r)
scalar list rss_r1 n_r1 df_r1
scalar list rss_r1 n_r1 df_r1 
scalar df_r1_cor = df_r1 - 23
scalar list rss_r1 n_r1 df_r1_cor


/* Estimation of model (2) Pool */
qui reg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare if time > 1994 & time< 2019
scalar rss_r2 = e(rss)
scalar n_r2=e(N)
scalar df_r2=e(df_r)
scalar list rss_r2 n_r2 df_r2 

scalar fh1 =((rss_r1 - rss_ur)/(df_r1_cor-df_ur))/(rss_ur/df_ur)
scalar pval1 = Ftail(df_r1_cor-df_ur,df_ur,fh1)

scalar fh2 =((rss_r2 - rss_ur)/(df_r2-df_ur))/(rss_ur/df_ur)
scalar pval2 = Ftail(df_r2-df_ur,df_ur,fh2)

scalar fh3 =((rss_r2-rss_r1)/(df_r2-df_r1_cor))/(rss_r1/df_r1_cor)
scalar pval3 = Ftail(df_r2-df_r1_cor,df_r1_cor,fh3)
scalar list pval1 pval2 pval3  fh1 fh2 fh3
*pval, pval2, pval3 – уровень значимости для тестирования эквивалентности моделей 1 и 2, 1 и 3, 2 и 3 соответственно

*     pval1 =  .99999962
*     pval2 =  .99998567
*     pval3 =  .04402433
*       fh1 =  .53839198
*       fh2 =  .60292712
*       fh3 =   1.5871383






*********************************************
* Time autocorrelation test (Wooldrige test)*
*********************************************
findit xtserial
ssc install xtserial
xtserial lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1983-year_2017


*********************************************
*      Spatial autocorrelation test         *    
*********************************************
findit xttest2
ssc install xttest2
xtreg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1983-year_2017, fe 
*drop RES
predict RES, e
xttest2
*rvfplot
scatter RES time if time >1990, yline(0)
*Heteroskedastity
ssc install xttest3
xtreg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1981-year_2018, fe
*Тест работает даже при нарушении нормальности ошибки, однако имеет низкую мощность при больших N и малых T.
xttest3
//тест на наличие пространственной автокорреляции
xtcd2
*************************************************
*         Heteroscedastisity correction         *
*************************************************    
*xtreg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1981-year_2018, fe 
*est store fe
*xtreg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1981-year_2018, fe robust
*est store _est_feHE_rob
*drop feHE_rob
*xtreg lnHE lnGDP lnUNEM lnDOC ln65 lnPubBeds lnGovDebt lnGINI lnTaxGS lnTaxPers lnINS, fe cluster(country)
*est store fe_cl
*reg lnHE lnGDP lnUNEM lnDOC ln65 lnPubBeds lnGovDebt lnGINI lnTaxGS lnTaxPers lnINS
*est store pool
*xtgls lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1981-year_2018, panels(hetero)
*est store pool_het
*outreg2 [fe fe_rob fe_cl pool pool_het]  using models.doc, nolabel replace

///The final
xtreg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1981-year_2018, fe cluster(country)
est store feHE_rob
outreg2 [poolHE feHE reHE poolHE_t feHE_t reHE_t feHE_rob]  using test.doc, nolabel replace



****************************************************
*              Clusters poolability                *
****************************************************
// Сперва посмотрим что получилось
use EXP_withRUS, clear
asdoc bysort group: sum HE_real PHE_real PrHE_real if time > 1986

*install first
*drop group_new
ssc inst mipolate
bysort country : mipolate group time if time<1989, gen(group_new) groupwise
replace group_new = group if group_new == .
asdoc bysort group_new: sum HE_real PHE_real PrHE_real


*gen group_new = group
replace group_new = . if group_new == 1
replace group_new = 3 if group_new == 2
 sum group_new
*reg dtlnHE $REG1 if group_new==2

drop mt* dt*
foreach x of varlist lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare {
    egen mt`x' = mean(`x') if time > 1983 & time < 2018, by(group_new)
	gen dt`x' = `x'-mt`x' if time > 1983 & time < 2018
}
* оценивание модели (0) без ограничений 
global REG1 "dtlnGDP dtlnUNEM dtlnDOC dtln15 dtln65 dtlnGINI dtlnGovDebt dtlnTAX dtlnINS dtlnPHEshare"
scalar rss_ur=0
scalar n_ur=0
scalar df_ur=0


 
forvalue i=3/4 {
qui reg dtlnHE $REG1 if group_new==`i'
scalar z`i'=e(rss)
scalar df`i'=e(df_r)
scalar n`i'=e(N)
scalar rss_ur=rss_ur+z`i'
scalar n_ur=n_ur+n`i'
scalar df_ur=df_ur+df`i'
scalar list rss_ur n_ur df_ur 
}
scalar list rss_ur n_ur df_ur 

/* Estimation of model (1) with FE of country */
reg dtlnHE $REG1 if group_new >2 , noconstant
scalar rss_r1 = e(rss)
scalar n_r1=e(N)
scalar df_r1=e(df_r)
scalar list rss_r1 n_r1 df_r1
scalar list rss_r1 n_r1 df_r1 
scalar df_r1_cor = df_r1 - 1
scalar list rss_r1 n_r1 df_r1_cor


/* Estimation of model (2) Pool */
qui reg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare if  group_new > 2 & time > 1983 & time < 2018
scalar rss_r2 = e(rss)
scalar n_r2=e(N)
scalar df_r2=e(df_r)
scalar list rss_r2 n_r2 df_r2 

scalar fh1 =((rss_r1 - rss_ur)/(df_r1_cor-df_ur))/(rss_ur/df_ur)
scalar pval1 = Ftail(df_r1_cor-df_ur,df_ur,fh1)

scalar fh2 =((rss_r2 - rss_ur)/(df_r2-df_ur))/(rss_ur/df_ur)
scalar pval2 = Ftail(df_r2-df_ur,df_ur,fh2)

scalar fh3 =((rss_r2-rss_r1)/(df_r2-df_r1_cor))/(rss_r1/df_r1_cor)
scalar pval3 = Ftail(df_r2-df_r1_cor,df_r1_cor,fh3)
scalar list pval1 pval2 pval3  fh1 fh2 fh3

******************************
*     pval1 =  1.294e-35     *  
*     pval2 =  3.386e-24     * 
*     pval3 =          .     *
*       fh1 =  20.726959     *
*       fh2 =  14.077292     *
*       fh3 =          .     *
******************************

forvalue i=3/4 {
reg dtlnHE $REG1 if group_new==`i'
}

forvalue i=3/4 {
xtreg dtlnHE $REG1 if group_new==`i', fe
}

forvalue i=3/4 {
qui reg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare  if group_new==`i'
est store poolHE`i'
qui xtreg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare  if group_new==`i', fe
est store feHE`i'


qui xtreg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare  if group_new==`i', re
est store reHE`i'

qui reg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1981-year_2018 if group_new==`i'
est store poolHE`i'_t
testparm year_1981-year_2018

xtreg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1981-year_2018 if group_new==`i', fe
est store feHE`i'_t
testparm year_1981-year_2018
xttest3

qui xtreg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1981-year_2018 if group_new==`i', re
est store reHE`i'_t
*xttest0
testparm year_1981-year_2018
predict RESHE`i', e

qui xtreg lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1981-year_2018 if group_new==`i', fe robust
est store feHE`i'_rob
}

help hausman
hausman feHE3_t reHE3_t
hausman feHE4_t reHE4_t
scatter RESHE3 time if time >1995, yline(0)
scatter RESHE4 time if time >1981, yline(0)
list time lnHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare if location == "RUS" 

outreg2 [feHE3_rob feHE4_rob]  using test.doc, nolabel replace


****************************************************
*                     PHE                          *
****************************************************
*drop RES3 RES4
forvalue i=3/4 {
qui reg lnPHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare  if group_new==`i'
est store poolPHE`i'
xtreg lnPHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare  if group_new==`i', fe
est store fePHE`i'


qui xtreg lnPHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare  if group_new==`i', re
est store rePHE`i'

qui reg lnPHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1981-year_2018 if group_new==`i'
est store poolPHE`i'_t
testparm year_1981-year_2018

xtreg lnPHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1981-year_2018 if group_new==`i', fe
est store fePHE`i'_t
testparm year_1981-year_2018
xttest3


qui xtreg lnPHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1981-year_2018 if group_new==`i', re
est store rePHE`i'_t
*xttest0
testparm year_1981-year_2018
predict RESPHE`i', e

qui xtreg lnPHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare year_1981-year_2018 if group_new==`i', fe robust
est store fePHE`i'_rob
}

hausman fePHE3_t rePHE3_t
hausman fePHE4_t rePHE4_t
scatter RESPHE3 time if time >1995, yline(0)
scatter RESPHE4 time if time >1981, yline(0)
list time lnPHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare if location == "RUS" 
*list country if RES3!=.

outreg2 [fePHE3_rob fePHE4_rob]  using test.doc, nolabel replace

************************************************
*                    PrHE                      *
************************************************
drop RES*
forvalue i=3/4 {
qui reg lnPrHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTaxGS lnTaxPers lnINS lnPHEshare  if group_new==`i'
est store poolPrHE`i'
xtreg lnPrHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTaxGS lnTaxPers lnINS lnPHEshare  if group_new==`i', fe
est store fePrHE`i'


qui xtreg lnPrHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTaxGS lnTaxPers lnINS lnPHEshare  if group_new==`i', re
est store rePrHE`i'

qui reg lnPrHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTaxGS lnTaxPers lnINS lnPHEshare year_1981-year_2018 if group_new==`i'
est store poolPrHE`i'_t
testparm year_1981-year_2018

xtreg lnPrHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTaxGS lnTaxPers lnINS lnPHEshare year_1981-year_2018 if group_new==`i', fe
est store fePrHE`i'_t
testparm year_1981-year_2018
*xttest3


xtreg lnPrHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTaxGS lnTaxPers lnINS lnPHEshare year_1981-year_2018 if group_new==`i', re
est store rePrHE`i'_t
*xttest0
testparm year_1981-year_2018
predict RESPrHE`i', e

qui xtreg lnPrHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTaxGS lnTaxPers lnINS lnPHEshare year_1981-year_2018 if group_new==`i', fe robust
est store fePrHE`i'_rob
}

hausman fePrHE3_t rePrHE3_t
hausman fePrHE4_t rePrHE4_t
scatter RESPrHE3 time if time >1995, yline(0)
scatter RESPrHE4 time if time >1981, yline(0)

xtreg lnPrHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTaxGS lnTaxPers lnINS lnPHEshare year_1990-year_2018 if group_new==3 , re robust
testparm year_1981-year_2018
est store rePrHE3_rob

xtreg lnPrHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTaxGS lnTaxPers lnINS lnPHEshare if group_new==4, fe robust
est store fePrHE4_rob

list time lnPHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTAX lnINS lnPHEshare if location == "RUS" 
list country if RES3!=.

outreg2 [fePHE3_rob fePHE4_rob rePrHE3_rob fePrHE4_rob]  using test.doc, nolabel replace

outreg2 [feHE3_rob feHE4_rob fePHE3_rob fePHE4_rob rePrHE3_rob fePrHE4_rob]  using test.doc, nolabel replace
xtreg lnPrHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTaxGS lnTaxPers lnINS lnPHEshare  if group_new==3, re
xtreg lnPrHE lnGDP lnUNEM lnDOC ln15 ln65 lnGINI lnGovDebt lnTaxGS lnTaxPers lnINS lnPHEshare year_1981-year_2018 if group_new==3, re




*************************************************
*                 Baumol                        *
*************************************************
* I will use AvWages_OECD, Emp_OECD, GDP2010 & HE_OECD
cd "C:\Users\annma\Downloads"
use EXP_OECD, clear
sort time location
drop if time > 2019
drop if location=="EU28"|location=="G20"|location=="OECD"|location=="G-7"|location=="EU27"|location=="EU27_2020"|location=="OECDE"|location=="OAVG"|location=="WLD"|location=="EA19"|location=="EA"
*I dropped BGR
// I decided to replace dah_17 =. with 0
*replace dah_17=0 if dah_17==.
//I am not sure but maybe it is better to delete all the observations where dependent vars equal .
*drop if HE_real==. & PHE_real == . & PrHE_real == . 
encode location, generate(country)
xtset country time
drop if HE_OECD == . | GDP2010 == . | EMP_OECD == .| NomWage == .
keep HE_OECD GDP2010 EMP_OECD NomWage country location time
save baumol, replace
sort time location



gen lnHCE = ln(HE_OECD)
gen lnGDP = ln(GDP2010)
gen lnEMP = ln(EMP_OECD)
gen lnAvWages = ln(NomWage)

reg d.lnHCE d.lnGDP d.lnEMP d.lnAvWages
xtreg d.lnHCE d.lnGDP d.lnEMP d.lnAvWages,  fe 
xtreg d.lnHCE d.lnGDP d.lnEMP d.lnAvWages,  re
xttest0
xtline HE_real, overlay
xtline HE_real, i(country) t(time) legend(off) overlay
xtline GDP, i(country) t(time) legend(off) overlay
ssc install wid
help wid




asdoc sum HE_real


