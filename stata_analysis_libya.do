cd "V:\reach_libya"
import delimited reach_libya_dd15km.csv, clear


// THESE DATA AT 15 KM
// clean and relabel for stata
label var num_events "number of events"
label var total_count "fatalities"
label var tx_fatal "is in treatment group (fatalities)"
label var tx_event "is in treatment group (events)"
label var time "Pre or Post War"
label var students "Number of Students"
replace time = "1" if time == "post"
replace time = "0" if time == "pre"
destring time, replace
label define prepost 0 "pre" 1 "post"
label values time prepost
tab qii_1province, gen(prov_) // for province-fixed effects
replace took_damage ="." if took_damage == "NA"
destring took_damage, replace
label define yesno 1 "yes" 0 "no"
label values took_damage yesno
label values tx_* yesno
/////////////////



// difference-in-differences

//// fatalities
gen fatalpost = tx_fatal*time
reg students tx_fatal time fatalpost, vce(cluster id)

/*
. reg students tx_fatal time fatalpost, vce(cluster id)

Linear regression                               Number of obs     =      7,759
                                                F(3, 3925)        =     161.90
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0893
                                                Root MSE          =     234.89

                                 (Std. Err. adjusted for 3,926 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    tx_fatal |   148.8829   7.885933    18.88   0.000     133.4219    164.3438
        time |   4.430754   1.771238     2.50   0.012     .9581194    7.903388
   fatalpost |  -3.448054   4.642368    -0.74   0.458    -12.54973    5.653627
       _cons |    203.158   3.758242    54.06   0.000     195.7897    210.5262
------------------------------------------------------------------------------
*/



//// events
gen eventspost = tx_event*time
reg students tx_event time eventspost, vce(cluster id)


/*
. reg students tx_event time eventspost, vce(cluster id)

Linear regression                               Number of obs     =      7,759
                                                F(3, 3925)        =     154.12
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0635
                                                Root MSE          =     238.19

                                 (Std. Err. adjusted for 3,926 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    tx_event |   133.9564    7.03006    19.05   0.000     120.1735    147.7393
        time |   4.886609   2.426864     2.01   0.044     .1285755    9.644643
  eventspost |  -2.803642   4.113998    -0.68   0.496    -10.86942    5.262133
       _cons |   189.6292   4.132804    45.88   0.000     181.5266    197.7319
------------------------------------------------------------------------------

*/

// took damage
tab took_damage time
gen damagepost = took_damage*time
reg students took_damage time damagepost, vce(cluster id)

/*
. reg students took_damage time damagepost, vce(cluster id)

Linear regression                               Number of obs     =      7,755
                                                F(3, 3923)        =      12.90
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0085
                                                Root MSE          =     244.86

                                 (Std. Err. adjusted for 3,924 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
 took_damage |   49.87103   8.515292     5.86   0.000     33.17621    66.56584
        time |   4.372172   3.166638     1.38   0.167     -1.83624    10.58058
  damagepost |  -3.439721   4.516283    -0.76   0.446    -12.29421    5.414762
       _cons |   263.5146    5.29207    49.79   0.000     253.1391      273.89
------------------------------------------------------------------------------

*/






//////// ROBUSTNESS WITH DIFFERENT DISTANCES






// THESE DATA AT 5 KM
import delimited reach_libya_dd5km.csv, clear

// clean and relabel for stata
label var num_events "number of events"
label var total_count "fatalities"
label var tx_fatal "is in treatment group (fatalities)"
label var tx_event "is in treatment group (events)"
label var time "Pre or Post War"
label var students "Number of Students"
replace time = "1" if time == "post"
replace time = "0" if time == "pre"
destring time, replace
label define prepost 0 "pre" 1 "post"
label values time prepost
tab qii_1province, gen(prov_) // for province-fixed effects
replace took_damage ="." if took_damage == "NA"
destring took_damage, replace
label define yesno 1 "yes" 0 "no"
label values took_damage yesno
label values tx_* yesno
/////////////////

// difference-in-differences

//// fatalities
gen fatalpost = tx_fatal*time
reg students tx_fatal time fatalpost, vce(cluster id)

/*
. reg students tx_fatal time fatalpost, vce(cluster id)

Linear regression                               Number of obs     =      7,759
                                                F(3, 3925)        =      96.72
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0744
                                                Root MSE          =     236.81

                                 (Std. Err. adjusted for 3,926 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    tx_fatal |   153.9921    11.1877    13.76   0.000     132.0579    175.9264
        time |   6.452384   1.774083     3.64   0.000     2.974173    9.930596
   fatalpost |  -12.36926   7.189333    -1.72   0.085    -26.46444    1.725924
       _cons |   235.6463   3.728777    63.20   0.000     228.3358    242.9568
------------------------------------------------------------------------------
UH OH. 
*/

////// fatalities with covariates:
reg students tx_fatal time fatalpost high_school prov*, vce(cluster id)

/*
. reg students tx_fatal time fatalpost high_school prov*, vce(cluster id)
note: prov_12 omitted because of collinearity

Linear regression                               Number of obs     =      7,759
                                                F(26, 3925)       =      36.57
                                                Prob > F          =     0.0000
                                                R-squared         =     0.1807
                                                Root MSE          =     223.13

                                 (Std. Err. adjusted for 3,926 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    tx_fatal |   141.4529   40.89091     3.46   0.001     61.28344    221.6223
        time |    5.10086   1.644946     3.10   0.002     1.875831    8.325888
   fatalpost |  -40.68081   35.16065    -1.16   0.247    -109.6157    28.25406
 high_school |   51.28557   7.858751     6.53   0.000     35.87795    66.69319
      prov_1 |   118.1063   26.91635     4.39   0.000       65.335    170.8777
      prov_2 |   256.9047   30.23817     8.50   0.000     197.6207    316.1887
      prov_3 |   128.7748   29.51445     4.36   0.000     70.90967    186.6399
      prov_4 |   128.5444   31.67103     4.06   0.000      66.4512    190.6376
      prov_5 |    22.1221   27.91313     0.79   0.428    -32.60352    76.84771
      prov_6 |   5.936042   37.73718     0.16   0.875    -68.05029    79.92237
      prov_7 |  -74.21424   26.35391    -2.82   0.005    -125.8829   -22.54558
      prov_8 |   65.61253   27.58033     2.38   0.017     11.53939    119.6857
      prov_9 |   25.29853   31.95495     0.79   0.429    -37.35133    87.94839
     prov_10 |   63.04317   43.15069     1.46   0.144    -21.55672    147.6431
     prov_11 |  -63.44887    25.5836    -2.48   0.013    -113.6073   -13.29047
     prov_12 |          0  (omitted)
     prov_13 |   138.8538   42.28735     3.28   0.001     55.94653     221.761
     prov_14 |   64.06098   37.73844     1.70   0.090    -9.927815    138.0498
     prov_15 |  -56.17805    28.2582    -1.99   0.047    -111.5802   -.7759148
     prov_16 |  -49.81464   25.85233    -1.93   0.054    -100.4999     .870633
     prov_17 |    29.1206   27.76176     1.05   0.294    -25.30823    83.54944
     prov_18 |   39.80142   32.09591     1.24   0.215    -23.12482    102.7277
     prov_19 |  -32.09449   28.88484    -1.11   0.267    -88.72519    24.53621
     prov_20 |  -7.464125   27.44602    -0.27   0.786    -61.27392    46.34568
     prov_21 |   10.87767   27.34574     0.40   0.691    -42.73552    64.49086
     prov_22 |   183.2355   41.89573     4.37   0.000      101.096    265.3749
     prov_23 |   -40.2134   26.60265    -1.51   0.131    -92.36973    11.94292
       _cons |   182.5396    25.3971     7.19   0.000     132.7469    232.3324
------------------------------------------------------------------------------

*/

//// events
gen eventspost = tx_event*time
reg students tx_event time eventspost, vce(cluster id)


/*
. reg students tx_event time eventspost, vce(cluster id)

Linear regression                               Number of obs     =      7,759
                                                F(3, 3925)        =     125.39
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0858
                                                Root MSE          =     235.35

                                 (Std. Err. adjusted for 3,926 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    tx_event |   150.6201   9.129173    16.50   0.000     132.7217    168.5185
        time |   5.722441   1.990293     2.88   0.004     1.820335    9.624546
  eventspost |    -7.1571   5.526667    -1.30   0.195    -17.99251     3.67831
       _cons |   219.9892   3.780743    58.19   0.000     212.5768    227.4016
------------------------------------------------------------------------------

*/

// took damage
tab took_damage time
gen damagepost = took_damage*time
reg students took_damage time damagepost, vce(cluster id)

/*
. reg students took_damage time damagepost, vce(cluster id)

Linear regression                               Number of obs     =      7,755
                                                F(3, 3923)        =      12.90
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0085
                                                Root MSE          =     244.86

                                 (Std. Err. adjusted for 3,924 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
 took_damage |   49.87103   8.515292     5.86   0.000     33.17621    66.56584
        time |   4.372172   3.166638     1.38   0.167     -1.83624    10.58058
  damagepost |  -3.439721   4.516283    -0.76   0.446    -12.29421    5.414762
       _cons |   263.5146    5.29207    49.79   0.000     253.1391      273.89
------------------------------------------------------------------------------

*/



// THESE DATA AT 1 KM
import delimited reach_libya_dd1km.csv, clear

// clean and relabel for stata
label var num_events "number of events"
label var total_count "fatalities"
label var tx_fatal "is in treatment group (fatalities)"
label var tx_event "is in treatment group (events)"
label var time "Pre or Post War"
label var students "Number of Students"
replace time = "1" if time == "post"
replace time = "0" if time == "pre"
destring time, replace
label define prepost 0 "pre" 1 "post"
label values time prepost
tab qii_1province, gen(prov_) // for province-fixed effects
replace took_damage ="." if took_damage == "NA"
destring took_damage, replace
label define yesno 1 "yes" 0 "no"
label values took_damage yesno
label values tx_* yesno
/////////////////

// difference-in-differences

//// fatalities
gen fatalpost = tx_fatal*time
table tx_fatal time
/*
------------------------
is in     |
treatment |
group     | Pre or Post 
(fataliti |     War     
es)       |   pre   post
----------+-------------
        0 | 3,644  3,719
        1 |   196    200
------------------------
*/
reg students tx_fatal time fatalpost, vce(cluster id)

/*
. reg students tx_fatal time fatalpost, vce(cluster id)

Linear regression                               Number of obs     =      7,759
                                                F(3, 3925)        =      18.37
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0151
                                                Root MSE          =     244.28

                                 (Std. Err. adjusted for 3,926 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    tx_fatal |   157.0765   40.55408     3.87   0.000     77.56742    236.5855
        time |   5.433273   1.632504     3.33   0.001     2.232636     8.63391
   fatalpost |  -42.79184   35.19101    -1.22   0.224    -111.7862    26.20254
       _cons |   272.1021   3.802879    71.55   0.000     264.6463    279.5579
------------------------------------------------------------------------------

*/



//// events
gen eventspost = tx_event*time
table tx_event time
/*
. table tx_event time

------------------------
is in     |
treatment | Pre or Post 
group     |     War     
(events)  |   pre   post
----------+-------------
        0 | 3,495  3,568
        1 |   345    351
------------------------
*/
reg students tx_event time eventspost, vce(cluster id)


/*

*/

// took damage
tab took_damage time
gen damagepost = took_damage*time
reg students took_damage time damagepost, vce(cluster id)

/*
. reg students tx_event time eventspost, vce(cluster id)

Linear regression                               Number of obs     =      7,759
                                                F(3, 3925)        =      20.92
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0208
                                                Root MSE          =     243.56

                                 (Std. Err. adjusted for 3,926 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    tx_event |   136.9912    26.7932     5.11   0.000     84.46126    189.5211
        time |    5.68967   1.673326     3.40   0.001        2.409    8.970341
  eventspost |   -26.8316   20.31292    -1.32   0.187    -66.65647    12.99327
       _cons |   267.8117   3.725788    71.88   0.000     260.5071    275.1164
------------------------------------------------------------------------------

*/







