cd "V:\reach_libya"
import delimited reach_libya_dd7km.csv, clear


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

reg tx_fatal prov*, vce(cluster id)
reg tx_fatal high_school, vce(cluster id)

// difference-in-differences

//// fatalities
gen fatalpost = tx_fatal*time
table tx_fatal time
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
table tx_fatal time

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

// mere exposure to fatalities with covariates (most accurate model?)
gen exposed = 1 if tx_fatal != 0
replace exposed = 0 if exposed != 1
table exposed
gen exposedpost = exposed*time
reg students exposed time exposedpost high_school prov*, vce(cluster id)

/*
. reg students exposed time exposedpost high_school prov*, vce(cluster id)
note: prov_12 omitted because of collinearity

Linear regression                               Number of obs     =      7,759
                                                F(26, 3925)       =      38.05
                                                Prob > F          =     0.0000
                                                R-squared         =     0.1973
                                                Root MSE          =     220.85

                                 (Std. Err. adjusted for 3,926 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
     exposed |   107.9353   11.12717     9.70   0.000     86.11976    129.7509
        time |   6.155508   1.796535     3.43   0.001     2.633279    9.677738
 exposedpost |  -10.96973   7.138562    -1.54   0.124    -24.96537    3.025915
 high_school |    54.9802   7.848198     7.01   0.000     39.59327    70.36713
      prov_1 |   70.53813   27.15636     2.60   0.009     17.29623      123.78
      prov_2 |   205.3862   30.19182     6.80   0.000      146.193    264.5793
      prov_3 |   86.97463   29.79979     2.92   0.004     28.55011    145.3992
      prov_4 |   129.6997   31.65451     4.10   0.000     67.63887    191.7605
      prov_5 |   -20.6471   27.92184    -0.74   0.460    -75.38979    34.09558
      prov_6 |   5.634722   37.70397     0.15   0.881     -68.2865    79.55594
      prov_7 |  -83.25184   26.12154    -3.19   0.001    -134.4649   -32.03876
      prov_8 |   48.50281   27.63252     1.76   0.079     -5.67264    102.6783
      prov_9 |   24.86783   31.92577     0.78   0.436    -37.72483    87.46049
     prov_10 |   63.24566   43.17701     1.46   0.143    -21.40584    147.8972
     prov_11 |  -89.36921     25.745    -3.47   0.001    -139.8441   -38.89436
     prov_12 |          0  (omitted)
     prov_13 |   117.6701    40.7754     2.89   0.004     37.72716    197.6131
     prov_14 |    54.2104   36.92422     1.47   0.142    -18.18207    126.6029
     prov_15 |  -55.20449   28.23321    -1.96   0.051    -110.5576      .14866
     prov_16 |  -55.51346   25.86188    -2.15   0.032    -106.2174   -4.809477
     prov_17 |   29.73101   27.73731     1.07   0.284    -24.64989    84.11191
     prov_18 |  -9.679181   32.09354    -0.30   0.763    -72.60077     53.2424
     prov_19 |  -30.91918   28.88558    -1.07   0.285    -87.55135    25.71299
     prov_20 |  -30.57315   27.11666    -1.13   0.260    -83.73722    22.59093
     prov_21 |  -10.48027   26.82551    -0.39   0.696    -63.07352    42.11297
     prov_22 |   147.7189   39.75835     3.72   0.000     69.76995    225.6679
     prov_23 |  -43.51937   26.55207    -1.64   0.101    -95.57653    8.537791
       _cons |   179.1228   25.35428     7.06   0.000      129.414    228.8316
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

reg students tx_event time eventspost high_school prov*, vce(cluster id)
/*
. reg students tx_event time eventspost high_school prov*, vce(cluster id)
note: prov_12 omitted because of collinearity

Linear regression                               Number of obs     =      7,759
                                                F(26, 3925)       =      41.53
                                                Prob > F          =     0.0000
                                                R-squared         =     0.2011
                                                Root MSE          =     220.33

                                 (Std. Err. adjusted for 3,926 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    tx_event |   109.6942   7.161727    15.32   0.000      95.6531    123.7352
        time |   5.159553   2.440287     2.11   0.035     .3752041    9.943903
  eventspost |  -3.098368   4.126494    -0.75   0.453    -11.18864    4.991905
 high_school |   53.12863   7.742859     6.86   0.000     37.94823    68.30904
      prov_1 |   80.76902   25.94928     3.11   0.002     29.89367    131.6444
      prov_2 |   213.7399   29.33176     7.29   0.000     156.2329    271.2468
      prov_3 |   95.15964   29.12155     3.27   0.001     38.06484    152.2544
      prov_4 |   87.13633   30.37618     2.87   0.004     27.58175    146.6909
      prov_5 |   -5.89181   27.01008    -0.22   0.827    -58.84693    47.06331
      prov_6 |    57.1048    37.1251     1.54   0.124    -15.68151    129.8911
      prov_7 |  -102.2633    25.8486    -3.96   0.000    -152.9412   -51.58531
      prov_8 |   32.43324   26.72293     1.21   0.225    -19.95889    84.82537
      prov_9 |   76.40475    31.2292     2.45   0.014     15.17775    137.6317
     prov_10 |   99.71621   41.34701     2.41   0.016     18.65257    180.7799
     prov_11 |  -83.09467   24.90008    -3.34   0.001     -131.913   -34.27636
     prov_12 |          0  (omitted)
     prov_13 |   155.3463   40.09772     3.87   0.000     76.73196    233.9606
     prov_14 |   71.45138   36.44213     1.96   0.050     .0040932    142.8987
     prov_15 |  -26.55311   27.19514    -0.98   0.329    -79.87105    26.76482
     prov_16 |  -54.15728   24.83526    -2.18   0.029    -102.8485   -5.466051
     prov_17 |   61.20915   26.98779     2.27   0.023     8.297739    114.1206
     prov_18 |   16.48139   29.94219     0.55   0.582    -42.22233    75.18511
     prov_19 |  -38.54834   27.66986    -1.39   0.164    -92.79699    15.70032
     prov_20 |  -7.591224   26.15684    -0.29   0.772     -58.8735    43.69105
     prov_21 |   20.31827    26.1232     0.78   0.437    -30.89804    71.53459
     prov_22 |   179.0996   39.90781     4.49   0.000     100.8576    257.3416
     prov_23 |  -69.47125   25.76544    -2.70   0.007    -119.9862   -18.95634
       _cons |   129.7498   24.64277     5.27   0.000     81.43593    178.0636
------------------------------------------------------------------------------

*/

gen exposed_event = 1 if tx_event != 0
replace exposed_event = 0 if exposed_event != 1
table exposed_event
gen exposed_eventpost = exposed_event*time
reg students exposed_event time exposed_eventpost high_school prov*, vce(cluster id)
/*
. reg students exposed_event time exposed_eventpost high_school prov*, vce(cluster id)
note: prov_12 omitted because of collinearity

Linear regression                               Number of obs     =      7,759
                                                F(26, 3925)       =      40.61
                                                Prob > F          =     0.0000
                                                R-squared         =     0.2040
                                                Root MSE          =     219.94

                                      (Std. Err. adjusted for 3,926 clusters in id)
-----------------------------------------------------------------------------------
                  |               Robust
         students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
    exposed_event |   108.7713   9.211423    11.81   0.000     90.71164    126.8309
             time |   5.814307   1.999156     2.91   0.004     1.894824     9.73379
exposed_eventpost |  -7.070745   5.514665    -1.28   0.200    -17.88262    3.741134
      high_school |   55.49601   7.802236     7.11   0.000      40.1992    70.79283
           prov_1 |   100.2311   24.82479     4.04   0.000      51.5604    148.9018
           prov_2 |   208.5489   28.45704     7.33   0.000     152.7569    264.3409
           prov_3 |   117.6869   28.07052     4.19   0.000     62.65275    172.7211
           prov_4 |   71.18077   29.61363     2.40   0.016     13.12122    129.2403
           prov_5 |   8.467111   25.70092     0.33   0.742     -41.9213    58.85553
           prov_6 |   37.69438   36.26533     1.04   0.299    -33.40628     108.795
           prov_7 |  -90.77682   24.52853    -3.70   0.000    -138.8667   -42.68695
           prov_8 |   72.85811   25.55155     2.85   0.004     22.76254    122.9537
           prov_9 |   56.91151   30.20993     1.88   0.060    -2.317139    116.1402
          prov_10 |   88.20048   40.78131     2.16   0.031     8.245925     168.155
          prov_11 |  -61.38943   23.39488    -2.62   0.009    -107.2567   -15.52217
          prov_12 |          0  (omitted)
          prov_13 |   148.8119   39.45481     3.77   0.000     71.45803    226.1657
          prov_14 |   75.69003   35.88619     2.11   0.035     5.332696    146.0474
          prov_15 |  -41.40324   25.92741    -1.60   0.110     -92.2357    9.429221
          prov_16 |  -36.37952   23.56948    -1.54   0.123     -82.5891     9.83006
          prov_17 |   59.64806   25.86777     2.31   0.021      8.93253    110.3636
          prov_18 |   21.07128   30.13973     0.70   0.485    -38.01974    80.16229
          prov_19 |  -55.42435   26.61655    -2.08   0.037    -107.6079   -3.240772
          prov_20 |   .4173672   24.80114     0.02   0.987    -48.20698    49.04171
          prov_21 |   20.87483   24.63556     0.85   0.397    -27.42488    69.17454
          prov_22 |   171.6332   38.31398     4.48   0.000     96.51597    246.7503
          prov_23 |  -33.04095   24.23882    -1.36   0.173    -80.56282    14.48091
            _cons |   146.7883   23.33596     6.29   0.000     101.0365      192.54
-----------------------------------------------------------------------------------

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

reg students took_damage time damagepost high_school prov*, vce(cluster id)

/*
. reg students took_damage time damagepost high_school prov*, vce(cluster id)
note: prov_6 omitted because of collinearity

Linear regression                               Number of obs     =      7,755
                                                F(26, 3923)       =      35.56
                                                Prob > F          =     0.0000
                                                R-squared         =     0.1716
                                                Root MSE          =     224.15

                                 (Std. Err. adjusted for 3,924 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
 took_damage |   32.16256   8.866192     3.63   0.000     14.77978    49.54534
        time |   3.923125   3.176681     1.23   0.217    -2.304977    10.15123
  damagepost |  -2.855234   4.545883    -0.63   0.530    -11.76775    6.057282
 high_school |   47.46627   7.813821     6.07   0.000     32.14674    62.78581
      prov_1 |   120.6655   29.87163     4.04   0.000     62.10009    179.2309
      prov_2 |   266.8971   32.70301     8.16   0.000     202.7806    331.0136
      prov_3 |    130.736   32.75484     3.99   0.000      66.5179    194.9541
      prov_4 |   121.5341   34.10587     3.56   0.000     54.66722     188.401
      prov_5 |   35.89427   30.91437     1.16   0.246    -24.71547    96.50401
      prov_6 |          0  (omitted)
      prov_7 |  -72.30429   29.30337    -2.47   0.014    -129.7556   -14.85302
      prov_8 |   72.64836   30.45051     2.39   0.017     12.94804    132.3487
      prov_9 |    23.7477    34.1808     0.69   0.487    -43.26611    90.76152
     prov_10 |   64.27004   44.83926     1.43   0.152    -23.64041    152.1805
     prov_11 |  -54.24305   28.63252    -1.89   0.058    -110.3791    1.892974
     prov_12 |    4.62173   37.80478     0.12   0.903    -69.49715    78.74061
     prov_13 |   158.5536   44.53272     3.56   0.000     71.24409     245.863
     prov_14 |   62.46824   40.67195     1.54   0.125    -17.27192    142.2084
     prov_15 |  -56.18892   31.02902    -1.81   0.070    -117.0235    4.645619
     prov_16 |  -38.55112   29.07616    -1.33   0.185    -95.55693    18.45469
     prov_17 |   29.72054   30.66903     0.97   0.333     -30.4082    89.84929
     prov_18 |   33.94768   33.92386     1.00   0.317    -32.56238    100.4577
     prov_19 |  -33.07724   31.75703    -1.04   0.298    -95.33908     29.1846
     prov_20 |   13.27525   30.11707     0.44   0.659    -45.77134    72.32184
     prov_21 |   29.35491   30.59912     0.96   0.337    -30.63677    89.34659
     prov_22 |   206.2642   42.44758     4.86   0.000     123.0428    289.4856
     prov_23 |  -30.14512   29.56711    -1.02   0.308    -88.11348    27.82324
       _cons |   174.2015   29.10595     5.99   0.000     117.1372    231.2657
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

// THESE DATA AT 3 KM
import delimited reach_libya_dd3km.csv, clear

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

// took damage
tab took_damage time
/*
took_damag |    Pre or Post War
         e |       pre       post |     Total
-----------+----------------------+----------
        no |     2,575      2,631 |     5,206 
       yes |     1,263      1,286 |     2,549 
-----------+----------------------+----------
     Total |     3,838      3,917 |     7,755 

*/
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

// took damage
tab took_damage time
/*
took_damag |    Pre or Post War
         e |       pre       post |     Total
-----------+----------------------+----------
        no |     2,575      2,631 |     5,206 
       yes |     1,263      1,286 |     2,549 
-----------+----------------------+----------
     Total |     3,838      3,917 |     7,755 

*/
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



////////////////////////////////////////
// separate genders


// THESE DATA AT 5 KM FOR BOYS ONLY
import delimited reach_libya_dd5km_boys.csv, clear

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
       no | 2,262  2,305
      yes |   911    934
------------------------

*/
reg students tx_fatal time fatalpost, vce(cluster id)

/*
. reg students tx_fatal time fatalpost, vce(cluster id)

Linear regression                               Number of obs     =      6,412
                                                F(3, 3258)        =      72.40
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0753
                                                Root MSE          =     126.56

                                 (Std. Err. adjusted for 3,259 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    tx_fatal |   80.95233   5.851778    13.83   0.000     69.47879    92.42586
        time |   2.734072   1.151083     2.38   0.018     .4771531    4.990992
   fatalpost |  -2.448056   2.456402    -1.00   0.319    -7.264304    2.368192
       _cons |   124.6503    2.33197    53.45   0.000      120.078    129.2226
------------------------------------------------------------------------------

*/

reg students tx_fatal time fatalpost high_school prov*, vce(cluster id)
/*
Linear regression                               Number of obs     =      6,412
                                                F(26, 3258)       =      26.14
                                                Prob > F          =     0.0000
                                                R-squared         =     0.2068
                                                Root MSE          =     117.43

                                 (Std. Err. adjusted for 3,259 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    tx_fatal |   57.29224   5.877083     9.75   0.000     45.76909    68.81539
        time |    2.78539   1.140187     2.44   0.015     .5498352    5.020945
   fatalpost |  -1.566087    2.39698    -0.65   0.514    -6.265828    3.133655
 high_school |   37.57942   4.870186     7.72   0.000     28.03048    47.12836
      prov_1 |   50.46943   19.20266     2.63   0.009     12.81892    88.11994
      prov_2 |   119.7267   19.51573     6.13   0.000     81.46235    157.9911
      prov_3 |   45.00831   18.71057     2.41   0.016     8.322636    81.69399
      prov_4 |    82.4844   22.05678     3.74   0.000     39.23785     125.731
      prov_5 |  -8.766521   18.33137    -0.48   0.633    -44.70869    27.17565
      prov_6 |   3.325036   22.60479     0.15   0.883    -40.99601    47.64608
      prov_7 |  -33.63354    18.1231    -1.86   0.064    -69.16736    1.900278
      prov_8 |   23.44028   17.95689     1.31   0.192    -11.76766    58.64823
      prov_9 |   13.77422   19.76249     0.70   0.486    -24.97394    52.52238
     prov_10 |   37.73359   25.10302     1.50   0.133    -11.48572     86.9529
     prov_11 |   -42.9204   17.28111    -2.48   0.013    -76.80334   -9.037453
     prov_12 |          0  (omitted)
     prov_13 |   28.44863    25.4291     1.12   0.263    -21.41001    78.30727
     prov_14 |   20.33089   21.25868     0.96   0.339    -21.35083    62.01262
     prov_15 |  -22.99918   18.86885    -1.22   0.223    -59.99519    13.99683
     prov_16 |  -23.56867   17.42075    -1.35   0.176    -57.72539    10.58806
     prov_17 |   19.19893   19.58103     0.98   0.327    -19.19343     57.5913
     prov_18 |  -6.238848   19.92787    -0.31   0.754    -45.31127    32.83358
     prov_19 |  -1.723799   20.94596    -0.08   0.934    -42.79239    39.34479
     prov_20 |   -5.54866   18.58022    -0.30   0.765    -41.97875    30.88143
     prov_21 |   14.97066   19.39092     0.77   0.440    -23.04896    52.99028
     prov_22 |   73.10323   25.51591     2.87   0.004     23.07438    123.1321
     prov_23 |  -19.39164   17.74004    -1.09   0.274    -54.17439    15.39111
       _cons |    83.1455   17.11465     4.86   0.000     49.58893    116.7021
------------------------------------------------------------------------------

*/

//// events
gen eventspost = tx_event*time
table tx_event time
/*

------------------------
is in     |
treatment | Pre or Post 
group     |     War     
(events)  |   pre   post
----------+-------------
       no | 1,889  1,927
      yes | 1,284  1,312
------------------------

*/
reg students tx_event time eventspost, vce(cluster id)

/*
. reg students tx_event time eventspost, vce(cluster id)

Linear regression                               Number of obs     =      6,412
                                                F(3, 3258)        =      97.02
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0901
                                                Root MSE          =     125.55

                                 (Std. Err. adjusted for 3,259 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    tx_event |    80.1676   4.949133    16.20   0.000     70.46387    89.87132
        time |   1.898205   1.185009     1.60   0.109    -.4252326    4.221642
  eventspost |   .4917827   2.188005     0.22   0.822    -3.798222    4.781787
       _cons |   115.4516   2.359969    48.92   0.000     110.8244    120.0787
------------------------------------------------------------------------------

*/

// took damage
tab took_damage time
/*
. tab took_damage time

took_damag |    Pre or Post War
         e |       pre       post |     Total
-----------+----------------------+----------
        no |     2,118      2,166 |     4,284 
       yes |     1,053      1,071 |     2,124 
-----------+----------------------+----------
     Total |     3,171      3,237 |     6,408 


*/
gen damagepost = took_damage*time
reg students took_damage time damagepost, vce(cluster id)

/*
. reg students took_damage time damagepost, vce(cluster id)

Linear regression                               Number of obs     =      6,408
                                                F(3, 3256)        =      13.48
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0111
                                                Root MSE          =     130.76

                                 (Std. Err. adjusted for 3,257 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
 took_damage |   30.19488   5.078166     5.95   0.000     20.23815     40.1516
        time |   2.737007   1.294216     2.11   0.035     .1994463    5.274568
  damagepost |  -1.789877   2.113127    -0.85   0.397     -5.93307    2.353315
       _cons |   137.7842   2.808691    49.06   0.000     132.2772    143.2912
------------------------------------------------------------------------------

*/



////////////////////////////////////////
// separate genders


// THESE DATA AT 5 KM FOR GIRLS ONLY
import delimited reach_libya_dd5km_girls.csv, clear

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
       no | 2,267  2,303
      yes |   889    914
------------------------


*/
reg students tx_fatal time fatalpost, vce(cluster id)

/*
. reg students tx_fatal time fatalpost, vce(cluster id)

Linear regression                               Number of obs     =      6,373
                                                F(3, 3242)        =      61.51
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0733
                                                Root MSE          =     133.12

                                 (Std. Err. adjusted for 3,243 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    tx_fatal |   83.78973   6.428035    13.04   0.000     71.18631    96.39315
        time |   2.280955   .8774507     2.60   0.009     .5605406    4.001369
   fatalpost |  -1.441354   3.156614    -0.46   0.648    -7.630514    4.747805
       _cons |   117.5545   2.240555    52.47   0.000     113.1614    121.9475
------------------------------------------------------------------------------

*/
reg students tx_fatal time fatalpost high_school prov*, vce(cluster id)

/*

. reg students tx_fatal time fatalpost high_school prov*, vce(cluster id)
note: prov_6 omitted because of collinearity

Linear regression                               Number of obs     =      6,373
                                                F(26, 3242)       =      20.72
                                                Prob > F          =     0.0000
                                                R-squared         =     0.1688
                                                Root MSE          =      126.3

                                 (Std. Err. adjusted for 3,243 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    tx_fatal |     61.572   6.622612     9.30   0.000     48.58707    74.55693
        time |   2.407067   .8668228     2.78   0.006     .7074908    4.106643
   fatalpost |  -.8873339   3.130175    -0.28   0.777    -7.024656    5.249989
 high_school |    34.5741   5.648192     6.12   0.000     23.49971    45.64849
      prov_1 |   51.17473   17.75776     2.88   0.004     16.35716     85.9923
      prov_2 |   89.72615   17.35095     5.17   0.000     55.70622    123.7461
      prov_3 |   42.69207   16.92739     2.52   0.012     9.502605    75.88154
      prov_4 |   68.75167   20.11322     3.42   0.001     29.31576    108.1876
      prov_5 |  -11.50959   16.16444    -0.71   0.476    -43.20313    20.18395
      prov_6 |          0  (omitted)
      prov_7 |  -38.31447   15.94776    -2.40   0.016    -69.58319   -7.045756
      prov_8 |   19.58674    15.5004     1.26   0.206    -10.80483    49.97832
      prov_9 |   11.23138   17.23604     0.65   0.515    -22.56324    45.02601
     prov_10 |   25.33965   22.34098     1.13   0.257    -18.46421    69.14351
     prov_11 |  -47.65247   14.61389    -3.26   0.001    -76.30586   -18.99907
     prov_12 |   11.74961   24.48437     0.48   0.631    -36.25678    59.75601
     prov_13 |   27.78257   25.85604     1.07   0.283    -22.91326     78.4784
     prov_14 |   29.69364   20.43091     1.45   0.146    -10.36517    69.75245
     prov_15 |  -28.84862   16.23067    -1.78   0.076    -60.67203    2.974801
     prov_16 |  -29.08967   14.63225    -1.99   0.047    -57.77907   -.4002741
     prov_17 |   8.657298    17.3874     0.50   0.619    -25.43411     42.7487
     prov_18 |  -13.21253   17.56439    -0.75   0.452    -47.65095    21.22588
     prov_19 |  -16.11299   17.10284    -0.94   0.346    -49.64645    17.42047
     prov_20 |  -7.991428   17.00681    -0.47   0.638    -41.33661    25.35375
     prov_21 |   19.21958   18.13888     1.06   0.289    -16.34524     54.7844
     prov_22 |   87.69458   33.36486     2.63   0.009     22.27623    153.1129
     prov_23 |  -20.81342   15.27021    -1.36   0.173    -50.75366    9.126815
       _cons |   83.93702   14.84743     5.65   0.000     54.82573    113.0483
------------------------------------------------------------------------------

*/




//// events
gen eventspost = tx_event*time
table tx_event time
/*

------------------------
is in     |
treatment | Pre or Post 
group     |     War     
(events)  |   pre   post
----------+-------------
       no | 1,890  1,924
      yes | 1,266  1,293
------------------------

*/
reg students tx_event time eventspost, vce(cluster id)

/*
. reg students tx_event time eventspost, vce(cluster id)

Linear regression                               Number of obs     =      6,373
                                                F(3, 3242)        =      81.88
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0786
                                                Root MSE          =     132.73

                                 (Std. Err. adjusted for 3,243 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    tx_event |   79.50797   5.263929    15.10   0.000       69.187    89.82893
        time |   2.381008   .8388277     2.84   0.005     .7363218    4.025694
  eventspost |  -.9168279   2.476498    -0.37   0.711    -5.772488    3.938832
       _cons |    109.263   2.227073    49.06   0.000     104.8963    113.6296
------------------------------------------------------------------------------

*/

// took damage
tab took_damage time
/*
took_damag |    Pre or Post War
         e |       pre       post |     Total
-----------+----------------------+----------
        no |     2,119      2,161 |     4,280 
       yes |     1,035      1,054 |     2,089 
-----------+----------------------+----------
     Total |     3,154      3,215 |     6,369 

*/
gen damagepost = took_damage*time
reg students took_damage time damagepost, vce(cluster id)

/*
. reg students took_damage time damagepost, vce(cluster id)

Linear regression                               Number of obs     =      6,369
                                                F(3, 3240)        =       7.75
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0063
                                                Root MSE          =     137.73

                                 (Std. Err. adjusted for 3,241 clusters in id)
------------------------------------------------------------------------------
             |               Robust
    students |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
 took_damage |   22.83635   5.136485     4.45   0.000     12.76526    32.90743
        time |   1.807403   1.077757     1.68   0.094    -.3057505    3.920557
  damagepost |    .772446   2.622063     0.29   0.768    -4.368623    5.913515
       _cons |   133.5762   2.973816    44.92   0.000     127.7455     139.407
------------------------------------------------------------------------------

*/










// with walkers

//// fatalities
gen fatalpost = tx_fatal*time
table tx_fatal time
reg students tx_fatal time fatalpost pct_walking_before, vce(cluster id)
reg students total_count time fatalpost pct_walking_before, vce(cluster id)
reg students tx_fatal time fatalpost total_count pct_walking_before prov*, vce(cluster id)
/*

*/



//// events
gen eventspost = tx_event*time
reg students tx_event time eventspost pct_walking_before, vce(cluster id)





