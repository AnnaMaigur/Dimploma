pwd
cd "C:\Users\annma\Downloads"
import delimited "C:\Users\annma\Downloads\TOT_OECD.csv", encoding(UTF-8) 
rename value HE_OECD
d
sum

label var HE_OECD "US dollar/capita"

drop indicator subject measure frequency flagcodes
save HE_OECD

import delimited "C:\Users\annma\Downloads\PHE_OECD.csv", encoding(UTF-8) clear
rename value PHE_OECD
label var PHE_OECD "US dollar/capita"

drop indicator subject measure frequency flagcodes
save PHE_OECD

import delimited "C:\Users\annma\Downloads\OOP_OECD.csv", encoding(UTF-8) clear
rename value OOP_OECD
label var OOP_OECD "US dollar/capita"

drop indicator subject measure frequency flagcodes
save OOP_OECD

import delimited "C:\Users\annma\Downloads\VOL_OECD.csv", encoding(UTF-8) clear
rename value VOL_OECD
label var VOL_OECD "US dollar/capita"

drop indicator subject measure frequency flagcodes
save VOL_OECD

/// Health spending measures the final consumption of health care goods and services (i.e. current health expenditure) including personal health care (curative care, rehabilitative care, long-term care, ancillary services and medical goods) and collective services (prevention and public health services as well as health administration), but excluding spending on investments. Health care is financed through a mix of financing arrangements including government spending and compulsory health insurance (“Government/compulsory”) as well as voluntary health insurance and private funds such as households’ out-of-pocket payments, NGOs and private corporations (“Voluntary”). This indicator is presented as a total and by type of financing (“Government/compulsory”, “Voluntary”, “Out-of-pocket”) and is measured as a share of GDP, as a share of total health spending and in USD per capita (using economy-wide PPPs). ///

*******MERGING***********
merge 1:1 time location using PHE_OECD
drop _merge
merge 1:1 time location using HE_OECD
drop _merge
merge 1:1 time location using OOP_OECD
drop _merge
save EXP_OECD



******GDP*********
import delimited "C:\Users\annma\Downloads\GDP_OECD.csv", encoding(UTF-8) clear
rename value GDP_OECD
label var GDP_OECD "US dollar/capita"

drop indicator subject measure frequency flagcodes
save GDP_OECD
merge 1:1 time location using EXP_OECD
drop _merge
save EXP_OECD, replace

**********age_structure***********
import delimited "C:\Users\annma\Downloads\65_OECD.csv", encoding(UTF-8) clear
rename value old_OECD
label var old_OECD "% of population"

drop indicator subject measure frequency flagcodes
save old_OECD
merge 1:1 time location using EXP_OECD
drop _merge
save EXP_OECD, replace

import delimited "C:\Users\annma\Downloads\15_OECD.csv", encoding(UTF-8) clear
rename value young_OECD
label var young_OECD "% of population"

drop indicator subject measure frequency flagcodes
save young_OECD
merge 1:1 time location using EXP_OECD
drop _merge
save EXP_OECD, replace


***********Unemployment**************
import delimited "C:\Users\annma\Downloads\Unem_OECD.csv", encoding(UTF-8) clear
rename value Unem_OECD
label var Unem_OECD "% of labour force"

drop indicator subject measure frequency flagcodes
save Unem_OECD
merge 1:1 time location using EXP_OECD
drop _merge
save EXP_OECD, replace



***********Doctors**************
import delimited "C:\Users\annma\Downloads\Doctors_OECD.csv", encoding(UTF-8) clear
rename value Doctors_OECD
label var Doctors_OECD "Per 1 000 inhabitants"

drop indicator subject measure frequency flagcodes
save Doctors_OECD
merge 1:1 time location using EXP_OECD
drop _merge
save EXP_OECD, replace



***********Government spending**************
import delimited "C:\Users\annma\Downloads\GovSpend_OECD.csv", encoding(UTF-8) clear
rename value GovSpend_OECD
label var GovSpend_OECD "% of GDP"

drop indicator subject measure frequency flagcodes
save GovSpend_OECD, replace
merge 1:1 time location using EXP_OECD
drop _merge
save EXP_OECD, replace


***********Government deficit OECD**************
//General government deficit is defined as the balance of income and expenditure of government, including capital income and capital expenditures. "Net lending" means that government has a surplus, and is providing financial resources to other sectors, while "net borrowing" means that government has a deficit, and requires financial resources from other sectors. This indicator is measured as a percentage of GDP. All OECD countries compile their data according to the 2008 System of National Accounts (SNA 2008).//
import delimited "C:\Users\annma\Downloads\GovDef_OECD.csv", encoding(UTF-8) clear
rename value GovDef_OECD
label var GovDef_OECD "% of GDP"

drop indicator subject measure frequency flagcodes
save GovDef_OECD
use GovDef_OECD
merge 1:1 time location using EXP_OECD
rename _merge merge_govdef
save EXP_OECD, replace
sort time location



use DAH, clear
save DAH
// Using the IHME DAH Database (2018) to generate DAH by channel, source, and recipient
*country estimates.
// Copy and paste code into a .do file and run in Stata 13.
clear all
set more off
local DATA "FILL IN DATA PATH WHERE USER STORED DOWNLOADED IHME DATABASE"
local OUT "FILL IN FOLDER PATH WHERE USER WANTS GRAPHS STORED"
local deflate_yr "18"
use DAH, clear
// Prepare data by dropping transfers between channels that are double counted
drop if elim_ch == 1
drop elim_ch
// Convert DAH variables to numeric values
destring *dah*, replace force
tempfile data
save DAH1
** ***********************
// 3.) Recipient country totals
** ***********************
use DAH1, clear
// Calculate total DAH by recipient country
collapse (sum) dah_`deflate_yr', by(recipient_country recipient_isocode year)
sort recipient_country year

rename  recipient_isocode location
rename year time
merge 1:1 time location using EXP_OECD
drop recipient_country
rename _merge merge_DAH
drop if merge_DAH==1

save EXP_OECD, replace





***************Labour productivity****************
///Labour productivity growth is a key dimension of economic performance and an essential driver of changes in living standards. Growth in gross domestic product (GDP) per capita can be broken down into growth in labour productivity, measured as growth in GDP per hour worked, and changes in the extent of labour utilisation, measured as changes in hours worked per capita. High labour productivity growth can reflect greater use of capital, and/or a decrease in the employment of low-productivity workers, or general efficiency gains and innovation.///

import delimited "C:\Users\annma\Downloads\LabProd_OECD.csv", encoding(UTF-8) clear
rename value LabProd_OECD_OECD
label var LabProd_OECD "Annual growth rate (%), growth in GDP per hour worked"

drop indicator subject measure frequency flagcodes
save LabProd_OECD_OECD
merge 1:1 time location using EXP_OECD
rename _merge merge_labprod
save EXP_OECD, replace

***************Wages******************
import delimited "C:\Users\annma\Downloads\AvWages_OECD.csv", encoding(UTF-8) clear
rename value AvWages_OECD
label var AvWages_OECD "Average wages are obtained by dividing the national-accounts-based total wage bill by the average number of employees in the total economy, which is then multiplied by the ratio of the average usual weekly hours per full-time employee to the average usually weekly hours for all employees. This indicator is measured in USD constant prices using 2016 base year and Purchasing Power Parities (PPPs) for private consumption of the same year."

drop indicator subject measure frequency flagcodes
save AvWages_OECD

merge 1:1 time location using EXP_OECD
rename _merge merge_avwages
save EXP_OECD, replace
************health coverage*************
//Share of population eligible for a defined set of health care goods and services under public programmes.
//This series refers to the share of the population eligible to health care goods and services that are included in total public health expenditure. Coverage in this sense is independent of the scope of cost-sharing.
import delimited "C:\Users\annma\Downloads\GovHealthProt_OECD.csv", encoding(UTF-8) clear
keep if measure == "% of total population covered"
rename value HealthCov_OECD
label var HealthCov_OECD "Total public and primary private health insurance, % of total population covered"
rename cou location
rename year time
keep location time HealthCov_OECD
save HealthCov_OECD
merge 1:1 time location using EXP_OECD
rename _merge merge_healthcoverage
drop if time < 1970
save EXP_OECD, replace

**********Taxes on goods and services***********
import delimited "C:\Users\annma\Downloads\TaxOnGoodsAndServ_OECD.csv", encoding(UTF-8) clear
rename value TaxGoodServ_OECD
label var TaxGoodServ_OECD "Total, % of GDP"
//Tax on goods and services is defined as all taxes levied on the production, extraction, sale, transfer, leasing or delivery of goods, and the rendering of services, or on the use of goods or permission to use goods or to perform activities. They consist mainly of value added and sales taxes. This covers: multi-stage cumulative taxes; general sales taxes - whether levied at manufacture/production, wholesale or retail level; value-added taxes; excises; taxes levied on the import and export of goods; taxes levied in respect of the use of goods and taxes on permission to use goods, or perform certain activities; taxes on the extraction, processing or production of minerals and other products. This indicator relates to government as a whole (all government levels) and is measured in percentage both of GDP and of total taxation.//

drop indicator subject measure frequency flagcodes
save TaxGoodServ_OECD
merge 1:1 time location using EXP_OECD
rename _merge taxgoodservices
save EXP_OECD, replace

**********Taxes on personal income***********
import delimited "C:\Users\annma\Downloads\TaxPersInc_OECD.csv", encoding(UTF-8) clear
rename value TaxPersInc_OECD
label var TaxPersInc_OECD "Total, % of GDP"
//Tax on personal income is defined as the taxes levied on the net income (gross income minus allowable tax reliefs) and capital gains of individuals. This indicator relates to government as a whole (all government levels) and is measured in percentage both of GDP and of total taxation.//

drop indicator subject measure frequency flagcodes
save TaxPersInc_OECD
merge 1:1 time location using EXP_OECD
rename _merge merge_taxpersinc
save EXP_OECD, replace

***********Tax revenue**************
import delimited "C:\Users\annma\Downloads\TaxRev_OECD.csv", encoding(UTF-8) clear
rename value TaxRev_OECD
label var TaxRev_OECD "Total, % of GDP"
//Tax revenue is defined as the revenues collected from taxes on income and profits, social security contributions, taxes levied on goods and services, payroll taxes, taxes on the ownership and transfer of property, and other taxes. Total tax revenue as a percentage of GDP indicates the share of a country's output that is collected by the government through taxes. It can be regarded as one measure of the degree to which the government controls the economy's resources. The tax burden is measured by taking the total tax revenues received as a percentage of GDP. This indicator relates to government as a whole (all government levels) and is measured in million USD and percentage of GDP.//

drop indicator subject measure frequency flagcodes
save TaxRev_OECD
merge 1:1 time location using EXP_OECD
rename _merge merge_taxrevenue
save EXP_OECD, replace

***********Governemnt debt**************
import delimited "C:\Users\annma\Downloads\GovDebt_OECD.csv", encoding(UTF-8) clear
rename value GovDebt_OECD
label var GovDebt_OECD "Total, % of GDP"
//General government debt-to-GDP ratio measures the gross debt of the general government as a percentage of GDP. It is a key indicator for the sustainability of government finance. Debt is calculated as the sum of the following liability categories (as applicable): currency and deposits; debt securities, loans; insurance, pensions and standardised guarantee schemes, and other accounts payable. Changes in government debt over time primarily reflect the impact of past government deficit//

drop indicator subject measure frequency flagcodes
save GovDebt_OECD
merge 1:1 time location using EXP_OECD
rename _merge merge_govdebt
save EXP_OECD, replace

**********Gini***********
*WB
import delimited "C:\Users\annma\Downloads\Gini_WB.csv", encoding(UTF-8) clear
nrow
rename v2 location
drop v1 v3 v4
rename (_1961-_2019) gini#, addnumber(1961)
reshape long gini, i(location) j(year)
rename year time
drop _1960
drop if time < 1970
save gini_WB, replace
merge 1:1 time location using EXP_OECD
drop if _merge==1
rename _merge merge_giniwb
gen gini_WB = gini/100
drop gini
save EXP_OECD, replace

*OECD
import delimited "C:\Users\annma\Downloads\Gini_OECD.csv", encoding(UTF-8) clear
rename value gini_OECD
label var gini_OECD "Gini coefficient, 0 = complete equality; 1 = complete inequality"
//Income is defined as household disposable income in a particular year. It consists of earnings, self-employment and capital income and public cash transfers; income taxes and social security contributions paid by households are deducted. The income of the household is attributed to each of its members, with an adjustment to reflect differences in needs for households of different sizes. Income inequality among individuals is measured here by five indicators. The Gini coefficient is based on the comparison of cumulative proportions of the population against cumulative proportions of income they receive, and it ranges between 0 in the case of perfect equality and 1 in the case of perfect inequality. //

drop indicator subject measure frequency flagcodes
save gini_OECD
merge 1:1 time location using EXP_OECD
rename _merge merge_ginioecd
save EXP_OECD, replace
*gen dgini=gini_WB-gini_OECD
*sum dgini
*drop dgini
gen gini = gini_OECD
replace gini = gini_WB if gini_OECD == .
*(1,229 real changes made)
save EXP_OECD, replace



***********Hospital beds*************
import delimited "C:\Users\annma\Downloads\Beds_OECD.csv", encoding(UTF-8) clear
keep if variable == "Total hospital beds"
keep if measure == "Number"
rename value Beds_OECD
label var Beds_OECD "Number of hospital beds"
rename (yea cou) (time location)
drop var variable unit measure flags flagcodes country year
save Beds_OECD, replace
merge 1:1 time location using EXP_OECD
rename _merge merge_beds
save EXP_OECD, replace

import delimited "C:\Users\annma\Downloads\BedsPubHosp_OECD.csv", encoding(UTF-8) clear
keep if variable == "Beds in publicly owned hospitals"
keep if measure == "Number"
rename value PubBeds_OECD
label var PubBeds_OECD "Beds in publicly owned hospitals"
rename (yea cou) (time location)
drop var variable unit measure flags flagcodes country year
save PubBeds_OECD, replace
merge 1:1 time location using EXP_OECD
rename _merge merge_pubbeds
save EXP_OECD, replace
gen RatioPubBeds = PubBeds_OECD/Beds_OECD
sum RatioPubBeds
save EXP_OECD, replace

***********Crude death rate*************
import delimited "C:\Users\annma\Downloads\CrudeDR_WB.csv", encoding(UTF-8) clear
drop in 1/2
drop v64 v65 v66 
nrow
rename v2 location
drop v1 v3 v4
rename (_1960-_2018) CrudeDR#, addnumber(1960)
reshape long CrudeDR, i(location) j(year)
rename year time
drop if time < 1970
save CrudeDR_WB, replace
merge 1:1 time location using EXP_OECD
drop if _merge==1
rename _merge merge_crudedr
save EXP_OECD, replace

************IMR**************
import delimited "C:\Users\annma\Downloads\IMR_OECD.csv", encoding(UTF-8) clear
rename value IMR_OECD
label var IMR_OECD "Total, Deaths/1 000 live births"
//The infant mortality rate is defined as the number of deaths of children under one year of age, expressed per 1 000 live births. Some of the international variation in infant mortality rates is due to variations among countries in registering practices for premature infants. The United States and Canada are two countries which register a much higher proportion of babies weighing less than 500g, with low odds of survival, resulting in higher reported infant mortality. In Europe, several countries apply a minimum gestational age of 22 weeks (or a birth weight threshold of 500g) for babies to be registered as live births. This indicator is measured in terms of deaths per 1 000 live births.//

drop indicator subject measure frequency flagcodes
save IMR_OECD
merge 1:1 time location using EXP_OECD
rename _merge merge_imr
save EXP_OECD, replace

*************Inflation*************
import delimited "C:\Users\annma\Downloads\cpi.csv", encoding(UTF-8) clear
drop in 1/2
drop v65 v66 
nrow
rename v2 location
drop v1 v3 v4
rename (_1960-_2019) cpi#, addnumber(1960)
reshape long cpi, i(location) j(year)
rename year time
drop if time < 1970
save CPI, replace
merge 1:1 time location using EXP_OECD
drop if _merge==1
rename _merge merge_cpi

*This is in real terms
*drop PHE_real
gen HE_real = HE_OECD/cpi*100
gen PHE_real = PHE_OECD/cpi*100
gen PrHE_real = (OOP_OECD+VOL_OECD)/cpi*100
gen GDP_real = (GDP_OECD)/cpi*100
save EXP_OECD, replace
drop HE_real PHE_real PrHE_real GDP_real
save EXP_OECD, replace

************GOVDEBT_WB**************
import delimited "C:\Users\annma\Downloads\GovDebt_WB (2).csv", encoding(UTF-8) clear
rename (v6-v50) GovDebt_WB#, addnumber(1980)

keep if subindicatortype == "% of GDP"
keep if indicator == "General government gross debt"
drop countryname indicatorid indicator subindicatortype
rename countryiso3 location
reshape long GovDebt_WB, i(location) j(year)
rename year time
drop if time < 1970
save GovDebt_WB, replace
merge 1:1 time location using EXP_OECD
drop if _merge==1
drop merge_govdebtfwb
rename _merge merge_govdebtfwb
gen GovDebt = GovDebt_OECD
replace GovDebt = GovDebt_WB if GovDebt == .
drop check
gen check =GovDebt_OECD-GovDebt_WB
sum check
drop GovDebt
drop check
*по WB на 500 наблюдений больше, буду их использовать
save EXP_OECD, replace
************GOVDEBT_WB**************
import delimited "C:\Users\annma\Downloads\GovDebt_WB (2).csv", encoding(UTF-8) clear
rename (v6-v50) GovBal_WB#, addnumber(1980)

keep if subindicatortype == "% of GDP"
keep if indicator == "General government structural balance"
drop countryname indicatorid indicator subindicatortype
rename countryiso3 location
reshape long GovBal_WB, i(location) j(year)
rename year time
drop if time < 1970
save GovBal_WB, replace
merge 1:1 time location using EXP_OECD
drop if _merge==1

rename _merge merge_govbalwb
gen GovBal = GovDef_OECD
replace GovBal = GovBal_WB if GovBal == .
gen check =GovDebt_OECD-GovDebt_WB
sum check
drop GovDebt
drop check
*по WB на 500 наблюдений больше, буду их использовать
save EXP_OECD, replace


*****************GINI WIID**************
import excel "C:\Users\annma\Downloads\wiidglobal.xlsx", sheet("Sheet1") firstrow clear
keep if area == "Country"
keep if subarea == "Country"
keep c3 year gini*
rename c3 location
rename year time
drop if time < 1970
merge 1:1 time location using EXP_OECD
drop if _merge==1
drop check
gen check = gini - gini_old
sum check
drop _merge
save EXP_OECD, replace


************IMR**************
import delimited "C:\Users\annma\Downloads\HLTHRES_28_EN.csv", encoding(UTF-8) clear
drop in 1/16
nrow
drop COUNTRY_GRP 
drop OWNER_ENTITY
rename VALUE Pubbeds_WHO
rename (COUNTRY YEAR) (location time)
label var IMR_OECD "Beds in publicly owned hospitals, total"
//The infant mortality rate is defined as the number of deaths of children under one year of age, expressed per 1 000 live births. Some of the international variation in infant mortality rates is due to variations among countries in registering practices for premature infants. The United States and Canada are two countries which register a much higher proportion of babies weighing less than 500g, with low odds of survival, resulting in higher reported infant mortality. In Europe, several countries apply a minimum gestational age of 22 weeks (or a birth weight threshold of 500g) for babies to be registered as live births. This indicator is measured in terms of deaths per 1 000 live births.//

drop indicator subject measure frequency flagcodes
save IMR_OECD
merge 1:1 time location using EXP_OECD
rename _merge merge_imr
save EXP_OECD, replace

**********************************************
*             classification                 *
**********************************************
// i just copied data from excel
nrow
rename (_1987-_2019) group#, addnumber(1987)
rename var1 location
drop var2
reshape long group, i(location) j(year)
rename year time
merge 1:1 time location using EXP_OECD
drop if _merge==1
drop _merge
replace group = "." if group == ".."
rename group group_string
replace group_string = "5" if group == "."
destring group_string, gen(group)
replace group = . if group == 5
save EXP_OECD, replace

**********************************************
*             unem for rus                   *
**********************************************
import delimited "C:\Users\annma\Downloads\Unem_WB.csv", encoding(UTF-8) clear
drop in 1/2
nrow
drop v1 v3 v4
rename v2 location
drop _
rename (_1960-_2020) Unem_WB#, addnumber(1960)
reshape long Unem_WB, i(location) j(year)
label var Unem_WB "Unemployment, total (% of total labor force) (modeled ILO estimate)"
drop if year <1970
drop if year >2019
rename year time

save Unem_WB
merge 1:1 time location using EXP_OECD
drop if _merge==1
drop _merge
drop check
gen check = Unem_OECD - Unem_WB
sum check
gen Unem = Unem_OECD
replace Unem = Unem_WB if Unem == .
save EXP_OECD, replace


**********************************************
*                  TAX_WB                    *
**********************************************
import delimited "C:\Users\annma\Downloads\TAX_WB.csv", encoding(UTF-8) clear
drop in 1/2
nrow
drop v1 v3 v4
rename v2 location
drop _
rename (_1960-_2020) TAX_WB#, addnumber(1960)
reshape long TAX_WB, i(location) j(year)
label var TAX_WB "Tax revenue (% of GDP)"
drop if year <1970
drop if year >2019
rename year time

save TAX_WB
merge 1:1 time location using EXP_OECD
drop if _merge==1
drop _merge
drop check
gen check = TaxRev_OECD - TAX_WB
sum check
*Tax revenue refers to compulsory transfers to the central government for public purposes. Certain compulsory transfers such as fines, penalties, and most social security contributions are excluded. Refunds and corrections of erroneously collected tax revenue are treated as negative revenue.

gen TAX = TAX_WB
*replace Unem = Unem_WB if Unem == .
save EXP_OECD, replace

**********************************************
*             Employment_WB                  *
**********************************************
import delimited "C:\Users\annma\Downloads\EMP_WB.csv", encoding(UTF-8) clear
rename (v5-v31) EMP_WB#, addnumber(1990)
drop in 1
rename v2 location
drop v1 v3 v4
drop _
reshape long EMP_WB, i(location) j(year)
label var EMP_WB "Total employment, total (ages 15+)"
drop if year <1970
drop if year >2019
rename year time

save TAX_WB
merge 1:1 time location using EXP_OECD
drop if _merge==1
drop _merge
drop check
gen check = TaxRev_OECD - TAX_WB
sum check
*Tax revenue refers to compulsory transfers to the central government for public purposes. Certain compulsory transfers such as fines, penalties, and most social security contributions are excluded. Refunds and corrections of erroneously collected tax revenue are treated as negative revenue.

gen TAX = TAX_WB
*replace Unem = Unem_WB if Unem == .
save EXP_OECD, replace



***********Tax revenue**************
import delimited "C:\Users\annma\Downloads\HEALTH_PROT_25042021112102645.csv", encoding(UTF-8) clear
keep if measure == "% of total population"
keep if variable =="Total health care"
keep cou year value 
rename (value cou year) (PubIns location time)
label var PubIns "Total, % of population"


save PubIns_OECD, replace
merge 1:1 time location using EXP_OECD
drop if _merge==1
drop _merge
drop check
gen check = HealthCov_OECD - PubIns
sum check
save EXP_OECD, replace


**********************************************
*                 GDP2010                    *
**********************************************
import delimited "C:\Users\annma\Downloads\GDP2010.csv", encoding(UTF-8) clear
drop in 1/2
nrow
drop _2020 _
drop v1 v3 v4
rename v2 location
rename (_1960-_2019) GDP2010_WB#, addnumber(1960)
reshape long GDP2010_WB, i(location) j(year)
label var GDP2010_WB "Tax revenue (% of GDP)"
drop if year <1970
drop if year >2019
rename year time

save GDP2010_WB
merge 1:1 time location using EXP_OECD
drop if _merge==1
drop _merge
drop check

save EXP_OECD, replace


**********************************************
*                 GDP2010                    *
**********************************************
import delimited "C:\Users\annma\Downloads\GDP_LCU.csv", encoding(UTF-8) clear
drop in 1/2
nrow
drop _2020 _
drop v1 v3 v4
rename v2 location
rename (_1960-_2019) GDP_LCU#, addnumber(1960)
reshape long GDP_LCU, i(location) j(year)
label var GDP_LCU "constant local currency"
drop if year <1970
drop if year >2019
rename year time

save GDP_LCU
merge 1:1 time location using EXP_OECD
drop if _merge==1
drop _merge

save EXP_OECD, replace


**********************************************
*                 deflator                   *
**********************************************
import delimited "C:\Users\annma\Downloads\def.csv", encoding(UTF-8) clear
drop in 1/2
nrow
drop _2020 _
drop v1 v3 v4
rename v2 location
rename (_1960-_2019) def_#, addnumber(1960)
reshape long def_, i(location) j(year)
rename def_ def
label var def "GDP deflator (base year varies by country)"
drop if year <1970
drop if year >2019
rename year time

save def
merge 1:1 time location using EXP_OECD
drop if _merge==1
drop _merge
drop check

save EXP_OECD, replace

**********************************************
*                 EMP_OECD                   *
**********************************************
import delimited "C:\Users\annma\Downloads\EMPL_OECD.csv", encoding(UTF-8) clear
keep location time value
rename value EMP_OECD
label var EMP_OECD "thousands persons"
drop if time <1970
drop if time >2019

save EMP_OECD
merge 1:1 time location using EXP_OECD
drop if _merge==1
drop _merge
save EXP_OECD, replace


**********************************************
*                 Comp_WB                    *
**********************************************
import delimited "C:\Users\annma\Downloads\Comp_WB.csv", encoding(UTF-8) clear
drop in 1/2
nrow
drop _2020 _
drop v1 v3 v4
rename v2 location
rename (_1960-_2019) Comp_WB#, addnumber(1960)
reshape long Comp_WB, i(location) j(year)
label var Comp_WB "Compensation of employees (current LCU)"
drop if year <1970
drop if year >2019
rename year time

save Comp_WB
merge 1:1 time location using EXP_OECD
drop if _merge==1
drop _merge

save EXP_OECD, replace
drop AvWages_WB
gen AvWages_WB = Comp_WB/(EMP_OECD*1000)
drop check
gen check  = AvWages_WB - AvWages_OECD
sum check

**********************************************
*                  HCE_WB                    *
**********************************************
import delimited "C:\Users\annma\Downloads\HCE_WB.csv", encoding(UTF-8) clear
drop in 1/2
nrow
drop _2020 _
drop v1 v3 v4
rename v2 location
rename (_1960-_2019) HCE_WB#, addnumber(1960)
reshape long HCE_WB, i(location) j(year)
label var HCE_WB "Current health expenditure per capita (current US$)"
drop if year <1970
drop if year >2019
rename year time

save HCE_WB

**********************************************
*               Nom wageNCU                  *
**********************************************
import delimited "C:\Users\annma\Downloads\NomWage.csv", delimiter(";") numer iccols(3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30) clear 
drop in 1
nrow
drop _2020 _
drop Indicator
rename (_1990-_2017) NomWage#, addnumber(1990)
reshape long NomWage, i(Country) j(year)
label var NomWage "Gross Average Monthly Wages by Country and Year, US$, at current Exchange Rates"
rename year time

save NomWage
import delimited "C:\Users\annma\Downloads\HCE_WB.csv", encoding(UTF-8) clear
drop in 1/2
nrow
drop _2020 _
keep v1 v2 
rename (v1 v2) (Country location)
save country
use NomWage, clear
merge m:1 Country using country
replace location = "CZE" if Country == "Czechia"
drop if Country == "Kyrgyzstan"
replace location = "SVK" if Country == "Slovakia"
drop if Country == "Republic of Moldova"

drop if _merge == 2
drop Country _merge 

save NomWage, replace
merge 1:1 time location using EXP_OECD
drop if _merge==1
drop _merge

save EXP_OECD, replace

**********************************************
*                  Nom wage                  *
**********************************************
import delimited "C:\Users\annma\Downloads\NomWageNCU.csv", delimiter(";") numericcols(3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30) clear 
drop in 1
nrow
drop Indicator
rename (_1990-_2017) NomWageNCU#, addnumber(1990)
reshape long NomWageNCU, i(Country) j(year)
label var NomWageNCU "Gross Average Monthly Wages by Country and Year, NC, at current prices"
rename year time

save NomWageNCU
import delimited "C:\Users\annma\Downloads\HCE_WB.csv", encoding(UTF-8) clear
drop in 1/2
nrow
drop _2020 _
keep v1 v2 
rename (v1 v2) (Country location)
save country
use NomWage, clear
merge m:1 Country using country
replace location = "CZE" if Country == "Czechia"
drop if Country == "Kyrgyzstan"
replace location = "SVK" if Country == "Slovakia"
drop if Country == "Republic of Moldova"

drop if _merge == 2
drop Country _merge 

save NomWageNCU, replace
merge 1:1 time location using EXP_OECD
drop if _merge==1
drop _merge

save EXP_OECD, replace

************************************
*              HCE_NCU             *
************************************
import delimited "C:\Users\annma\Downloads\HCE_NCU.csv", encoding(UTF-8) clear
keep if financingscheme == "All financing schemes"
keep if function == "Current expenditure on health (all functions)"
keep if v8 == "Per capita, current prices"
///вот это не доделала
keep location time value 
rename value HCE_NCU
label var HCE_NCU "Current expenditure on health (all functions), Per capita, current prices"


save HCE_NCU
merge 1:1 time location using EXP_OECD
drop if _merge==1
drop _merge
drop check
save EXP_OECD, replace




**************Variables**************
cd "C:\Users\annma\Downloads"
use EXP_OECD, clear
sort  location time
drop if time > 2019
list location if time == 2016
drop if location=="EU28"|location=="G20"|location=="OECD"|location=="G-7"|location=="EU27"|location=="EU27_2020"|location=="OECDE"|location=="OAVG"|location=="WLD"|location=="EA19"|location=="EA"
*I dropped BGR
// I decided to replace dah_17 =. with 0
replace dah_17=0 if dah_17==.
//I am not sure but maybe it is better to delete all the observations where dependent vars equal .
*drop if HE_OECD==. & PHE_OECD == . & OOP_OECD == . & VOL_OECD == .
encode location, generate(country)
xtset country time



**************Baumol's variable****************
gen g_wage = D.AvWages_OECD / L.AvWages_OECD *100
gen Baum = g_wage - LabProd_OECD if g_wage!=. & LabProd_OECD!=.
xtsum Baum
sum g_wage LabProd_OECD
*drop Baum

********Data description***********
xtsum HE_OECD PHE_OECD OOP_OECD VOL_OECD 
xtsum IMR_OECD RatioPubBeds GovDebt_OECD gini TaxRev_OECD TaxPersInc_OECD TaxGoodServ_OECD HealthCov_OECD AvWages_OECD LabProd_OECD dah_17 GovSpend_OECD Doctors_OECD Unem_OECD young_OECD old_OECD 
*The final graph for app.1
graph hbar OOP_OECD PHE_OECD VOL_OECD if HE_OECD!=. & PHE_OECD != . & OOP_OECD != . & VOL_OECD != . & time>2000, over(location,label(labsize(1.5))) stack ytitle("Health spending in US dollars/capita", size(medium)) intensity(25) 

graph hbar PrHE_real PHE_real if HE_real!=. & PHE_real != . & PrHE_real != . & time>2000, over(location,label(labsize(1.5))) stack ytitle("Health spending in US dollars 2010/capita", size(medium)) intensity(25) 

*The final graph for app.2

bysort time: egen mHE=mean(HE_OECD) if HE_OECD!=.
bysort time: egen mPHE=mean(PHE_OECD) if PHE_OECD!=.
bysort time: egen mOOP=mean(OOP_OECD) if OOP_OECD!=.
bysort time: egen mVOL=mean(VOL_OECD) if VOL_OECD!=.

twoway scatter mHE time, msymbol(circle_hollow) || connected mPHE time, msymbol(circle_hollow) || connected mOOP time, msymbol(circle_hollow) || connected mVOL time, msymbol(circle_hollow)
*The same but in real terms
bysort time: egen mHE_real=mean(HE_real) if HE_real!=.
bysort time: egen mPHE_real=mean(PHE_real) if PHE_real!=.
bysort time: egen mPrHE_real=mean(PrHE_real) if PrHE_real!=.
list location time if cpi < 0.0009
list location PHE_OECD PHE_real cpi if time == 1976
drop if location == "SVN" | location == "HRV"
drop if location == "ISL" | location == "BRA"
list location PHE_OECD PHE_real mPHE cpi if time == 1977| time == 1978|time == 1979
drop mHE_real mPHE_real mPrHE_real
bysort time: egen mHE_real=mean(HE_real) if HE_real!=.
bysort time: egen mPHE_real=mean(PHE_real) if PHE_real!=.
bysort time: egen mPrHE_real=mean(PrHE_real) if PrHE_real!=.

twoway scatter mHE_real time if time <2019, msymbol(circle_hollow) || connected mPHE_real time if time <2019, msymbol(circle_hollow) || connected mPrHE_real time if time <2019, msymbol(circle_hollow)
****The same but without USA****
bysort time: egen mHE_withoutUSA=mean(HE_OECD) if HE_OECD!=. & location != "USA"
bysort time: egen mPHE_withoutUSA=mean(PHE_OECD) if PHE_OECD!=. & location != "USA"
bysort time: egen mOOP_withoutUSA=mean(OOP_OECD) if OOP_OECD!=. & location != "USA"
bysort time: egen mVOL_withoutUSA=mean(VOL_OECD) if VOL_OECD!=. & location != "USA"

twoway scatter mHE_withoutUSA time, msymbol(circle_hollow) || connected mPHE_withoutUSA time, msymbol(circle_hollow) || connected mOOP_withoutUSA time, msymbol(circle_hollow) || connected mVOL_withoutUSA time, msymbol(circle_hollow)


*twoway scatter Baum country if time == 2016|| connected HE_OECD country if time == 2016, msymbol(circle_hollow)

*Looking for outliers
twoway scatter HE_real time if time <2019, msymbol(circle_hollow) || connected mHE_real time if time <2019, msymbol(circle_hollow)
twoway scatter PHE_real time if time <2019, msymbol(circle_hollow) || connected mPHE_real time if time <2019, msymbol(circle_hollow)
twoway scatter PrHE_real time if time <2019, msymbol(circle_hollow) || connected mPrHE_real time if time <2019, msymbol(circle_hollow)

hist HE_real, normal
hist PHE_real, normal
hist PrHE_real, normal
hist GDP_real, normal
hist old_OECD, normal
hist young_OECD, normal

hist PrHE_real, normal


*ln form
gen lnHE_nom = ln(HE_OECD)
gen lnPHE_nom = ln(PHE_OECD)
gen lnPrHE_nom = ln(OOP_OECD + VOL_OECD)
gen lnGDP_nom = ln(GDP_OECD)
gen lnDAH = ln(dah_17)
gen lnUNEM = ln(Unem_OECD)
gen lnDOC = ln(Doctors_OECD)
gen ln15 = ln(young_OECD)
gen ln65 = ln(old_OECD)
gen lnDR = ln(CrudeDR)
gen lnIMR = ln(IMR_OECD)
gen lnPubBeds = ln(RatioPubBeds)
gen lnGINI = ln(gini)
gen lnGovDebt = ln(GovDebt_OECD)
gen lnTAX = ln(TaxRev_OECD)
gen lnTaxPers = ln(TaxPersInc_OECD)
gen lnTaxGS = ln(TaxGoodServ_OECD)
gen lnINS = ln(HealthCov_OECD)
gen lnWAGE = ln(AvWages_OECD)
gen lnHE_real = ln(HE_real)
gen lnPHE_real = ln(PHE_real)
gen lnPrHE_real = ln(PrHE_real)
gen lnGDP_real = ln(GDP_real)
gen lnGovDef = ln(GovDef_OECD)
gen lnBeds = ln(Beds_OECD)
kdensity lnHE_real, normal



*Panel data
xtsum lnHE_real lnPHE_real lnPrHE_real
xtsum IMR_OECD RatioPubBeds GovDebt_OECD gini TaxPersInc_OECD TaxGoodServ_OECD HealthCov_OECD AvWages_OECD LabProd_OECD GovSpend_OECD Doctors_OECD Unem_OECD young_OECD old_OECD 

*correlations
pwcorr lnGDP_real lnUNEM lnDOC ln15 ln65 lnPubBeds lnGINI lnGovDebt lnTAX lnINS lnTaxPers lnTaxGS lnIMR lnGovDef
pwcorr lnTAX lnTaxGS lnTaxPers lnGINI
* доктор и ВВП, доктор и 15, 15 и 65, Джини и налоги, налоги и 65, imr и ВВП, imr и 15, 65




**************Poolability***************
*1) по времени
global LIST "lnGDP_real lnUNEM lnDOC ln65 lnPubBeds lnGINI lnGovDebt lnTaxGS lnTaxPer lnINS lnGovDef lnIMR"
/* усреднение по индивидам в каждой волне */
foreach x of varlist lnHE_real lnPHE_real lnPrHE_real lnGDP_real lnUNEM lnDOC ln65 lnPubBeds lnGINI lnGovDebt lnTaxGS lnTaxPer lnINS lnGovDef lnIMR {
    egen mt`x' = mean(`x'), by(time)
	gen dt`x' = `x'-mt`x'
}
* оценивание модели (0) без ограничений *I excluded GovDef PubBeds and Gini because of the lack of obs 
global REG1 "dtlnGDP_real dtlnUNEM dtlnDOC dtln65 dtlnGovDebt dtlnTaxGS dtlnTaxPer dtlnINS dtlnIMR"
scalar rss_ur=0
scalar n_ur=0
scalar df_ur=0

forvalue i=1995/2018 {
qui reg dtlnHE_real $REG1 if time==`i'
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
reg dtlnHE_real $REG1 if time > 1994 & time< 2019, noconstant
scalar rss_r1 = e(rss)
scalar n_r1=e(N)
scalar df_r1=e(df_r)
scalar list rss_r1 n_r1 df_r1
scalar list rss_r1 n_r1 df_r1 
scalar df_r1_cor = df_r1 - 23
scalar list rss_r1 n_r1 df_r1_cor
xtreg lnHE_real lnGDP_real lnUNEM lnDOC ln65 lnGovDebt lnTaxGS lnTaxPer lnINS lnIMR if time > 1994 & time< 2019, fe
/* Estimation of model (2) Pool */
qui reg lnHE_real lnGDP_real lnUNEM lnDOC ln65 lnGovDebt lnTaxGS lnTaxPer lnINS lnIMR if time > 1994 & time< 2019
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


*1) по странам
global LIST "lnGDP_real lnUNEM lnDOC ln65 lnPubBeds lnGINI lnGovDebt lnTaxGS lnTaxPer lnINS lnGovDef lnIMR"
foreach x of varlist lnHE_real lnPHE_real lnPrHE_real lnGDP_real lnUNEM lnDOC ln65 lnPubBeds lnGINI lnGovDebt lnTaxGS lnTaxPer lnINS lnGovDef lnIMR {
	egen sum`x' = sum(`x') if time > 1994 & time< 2019, by(country)
}
drop if sumlnUNEM==0 & sumlnDOC==0 & sumln65==0 & sumlnPubBeds==0 & sumlnGINI==0 & sumlnGovDebt==0 & sumlnTaxGS==0 & sumlnTaxPer==0 & sumlnINS==0 & sumlnGovDef==0 & sumlnIMR==0
/* усреднение по индивидам в каждой волне */
foreach x of varlist lnHE_real lnPHE_real lnPrHE_real lnGDP_real lnUNEM lnDOC ln65 lnPubBeds lnGINI lnGovDebt lnTaxGS lnTaxPer lnINS lnGovDef lnIMR {
    egen mt1`x' = mean(`x') if time > 1994 & time< 2019, by(country)
	*попробую заменить пропуски средним значениями 
	replace `x' = mt1`x' if `x' == .
	gen dt1`x' = `x'-mt1`x' if time > 1994 & time< 2019
}
* оценивание модели (0) без ограничений *I excluded GovDef PubBeds and Gini because of the lack of obs 
global REG2 "dt1lnGDP_real dt1lnUNEM dt1lnDOC dt1ln65 dt1lnGovDebt dt1lnTaxGS dt1lnTaxPer dt1lnINS dt1lnIMR"
scalar rss_ur=0
scalar n_ur=0
scalar df_ur=0

drop if country == 5
*I dropped BGR
forvalue i=2/58 {
qui reg dt1lnHE_real $REG2 if country==`i' & time > 1994 & time< 2019
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
reg dt1lnHE_real $REG2 & time > 1994 & time< 2019, noconstant
scalar rss_r1 = e(rss)
scalar n_r1=e(N)
scalar df_r1=e(df_r)
scalar list rss_r1 n_r1 df_r1
scalar list rss_r1 n_r1 df_r1 
scalar df_r1_cor = df_r1 - 23
scalar list rss_r1 n_r1 df_r1_cor
xtreg lnHE_real lnGDP_real lnUNEM lnDOC ln65 lnGovDebt lnTaxGS lnTaxPer lnINS lnIMR if time > 1994 & time< 2019, fe
/* Estimation of model (2) Pool */
qui reg lnHE_real lnGDP_real lnUNEM lnDOC ln65 lnGovDebt lnTaxGS lnTaxPer lnINS lnIMR & time > 1994 & time< 2019
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

*Models
reg lnHE_real lnGDP_real lnUNEM lnDOC ln15 ln65 lnPubBeds lnGINI lnGovDebt lnTAX lnINS lnGovDef
//R-squared       =    0.9690
*Now let's try to exclude correlated vars (65 and TAX) but I decided to include taxGS and taxpersInc and lnIMR
reg lnHE_real lnGDP_real lnUNEM lnDOC ln65 lnPubBeds lnGINI lnGovDebt lnTaxGS lnTaxPer lnINS lnGovDef lnIMR
*Exclude lnGovDef
reg lnHE_real lnGDP_real lnUNEM lnDOC ln65 lnPubBeds lnGINI lnGovDebt lnTaxGS lnTaxPer lnINS lnIMR
*Exclude lnDOC
reg lnHE_real lnGDP_real lnUNEM ln65 lnPubBeds lnGINI lnGovDebt lnTaxGS lnTaxPer lnINS lnIMR
*Exclude lnGini
reg lnHE_real lnGDP_real lnUNEM ln65 lnPubBeds lnGovDebt lnTaxGS lnTaxPer lnINS lnIMR
// R-squared       =    0.9440
//это лучшая, все значимо
est store pool
*drop _est_pool
*FE
xtreg lnHE_real lnGDP_real lnUNEM ln65 lnPubBeds lnGovDebt lnTaxGS lnTaxPer lnINS lnIMR, fe
est store fe
*drop _est_fe
*RE
xtreg lnHE_real lnGDP_real lnUNEM ln65 lnPubBeds lnGovDebt lnTaxGS lnTaxPer lnINS lnIMR, re
xttest0
est store re
*drop _est_re
est tab pool fe re, b(%7.4f) stats (N r2) star
hausman fe re
outreg2 [pool fe re ]  using test.doc, nolabel replace
drop _est_pool _est_fe _est_re






*Without Unem_OECD
reg lnHE lnGDP lnDOC ln15 ln65 lnPubBeds lnGINI lnGovDebt lnTAX lnINS Baum
// R-squared       =    0.9451
xtreg lnHE lnGDP lnDOC ln15 ln65 lnPubBeds lnGINI lnGovDebt lnTAX lnINS Baum, fe
xtreg lnHE lnGDP lnDOC ln65 lnPubBeds lnGINI lnGovDebt lnTAX lnINS Baum, fe

reg lnPHE lnGDP lnUNEM lnDOC ln15 ln65 lnPubBeds lnGINI lnGovDebt lnTAX lnINS Baum lnGovSpend
reg lnPHE lnGDP lnUNEM lnDOC ln15 ln65 lnPubBeds lnGINI lnGovDebt lnTAX Baum lnGovSpend

reg lnPHE lnGDP lnUNEM lnDOC ln15 ln65 lnPubBeds lnGINI lnGovDebt lnTAX Baum 

reg lnPHE lnGDP lnUNEM lnDOC ln15 ln65 lnPubBeds lnGovDebt lnTAX Baum 

reg lnPHE lnGDP lnUNEM lnDOC ln15 lnPubBeds lnGovDebt lnTAX Baum lnIMR lnDR

reg lnPHE lnGDP lnDOC ln15 lnPubBeds lnGovDebt lnTAX Baum lnIMR
*ожидаемая продолжительность жизни (средняя). Не зависит от возрастной структуры
reg lnOOP lnGDP lnUNEM lnDOC ln15 ln65 lnPubBeds lnGINI lnGovDebt lnTaxPers lnTaxGS lnINS Baum lnGovSpend lnPHE


reg lnHE_real lnGDP_real lnUNEM lnPubBeds lnGovDebt lnINS ln




