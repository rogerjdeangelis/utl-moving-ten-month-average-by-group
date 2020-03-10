Moving ten month average by group

github
https://github.com/rogerjdeangelis/utl-moving-ten-month-average-by-group

For other examples of 'proc expand', hand coding and R solutions
https://github.com/rogerjdeangelis?tab=repositories&q=rolling&type=&language=
https://github.com/rogerjdeangelis?tab=repositories&q=+moving+&type=&language=

Related to
SAS-L: https://listserv.uga.edu/cgi-bin/wa?A2=SAS-L;a4df8616.2003a

For tiny data like 40 million records(625mb) this took about 2 minutes.

Elapsed time can easily be reduced to about 25 seconds by partitioning on ID.

The following binary files are mutually exclusive.

 if mod(id,8)=1 then  write to binary file 1
else mod(id,8)=2 then  write to binary file 2
...
else mod(id,8)=0 then  write to binary file 8

Then run 8 systasks. Since I/O is very fast the R code
should drive all 8 cores to 100%. CPU utilization and elapsed will be equal
will equal the time for 50,000 IDs. You may need 16gb ram..

This was run on a vintage Dell E6420 Laptop.

Rolling moving 10 month average by group

Assuptions and minor data prep

  1.  Data prep. I summed the the response by month

       101 1 20190101 0    becomes 101  20190101  2 = (1+1+0+0)/4
       101 2 20190101 0
       101 3 20190101 1
       101 3 20190101 1

  2.  It looks like you do not have missing months.
      Otherwise fill in missing months with NA

  3.  Do not understand table 1

  4.  Just table 2 solution

  5. For very fast transfer of monthly recrds to R I create
     a stream of back to back IEEE floats which R
     can inport quickly.
  6. For a fast transport back to SAS I have R create
     a stream of back to back flosts that SAS
     can quickly import using format rb8.

  7. For checking a use a 4 month moving average

  8. 40mm run on end


*_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;

filename bin "d:/bin/binmat.bin" lrecl=32000 recfm=f;
data have;
  retain id month;
  format month yymm7.;
  call streaminit(54321);
  do id=101 to 102;
     do mnth=1 to 15;
         sumResponse=int(10*rand('uniform'));
         month=intnx('month', '01JAN2010'd, mnth-1);
         file bin;
         put (id sumresponse) (2*rb8.) @@ ;
         if id=102 and mnth>13 then leave;
         output;
      end;
  end;
run;quit;


HAVE total obs=28

Obs     ID     MONTH     MNTH    SUMRESPONSE

  1    101    2010M01      1          4    ==>  these are totals for the month
  2    101    2010M02      2          5
  3    101    2010M03      3          7
  4    101    2010M04      4          1
  5    101    2010M05      5          3
  6    101    2010M06      6          6
  7    101    2010M07      7          8
  8    101    2010M08      8          0
  9    101    2010M09      9          9
 10    101    2010M10     10          0
 11    101    2010M11     11          1
 12    101    2010M12     12          2
 13    101    2011M01     13          1
 14    101    2011M02     14          5
 15    101    2011M03     15          4
 16    102    2010M01      1          6
 17    102    2010M02      2          8
 18    102    2010M03      3          8
 19    102    2010M04      4          3
 20    102    2010M05      5          7
 21    102    2010M06      6          4
 22    102    2010M07      7          3
 23    102    2010M08      8          0
 24    102    2010M09      9          1
 25    102    2010M10     10          8
 26    102    2010M11     11          8
 27    102    2010M12     12          3
 28    102    2011M01     13          8


*            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;

WINDOW IS 4 MONTHS


Up to 40 obs WORK.BIN total obs=28
                                                       4 MONTH
Obs     ID    MONTH    MNTH    SUMRESPONSE    AVE10    WINDOW

  1    101    18263      1          4           .
  2    101    18294      2          5           .
  3    101    18322      3          7           .
  4    101    18353      4          1          4.25    4+5+7+1 = 17/4 = 4.25
  5    101    18383      5          3          4.00    5+7+1+3 = 16/4 = 4.00
  6    101    18414      6          6          4.25
  7    101    18444      7          8          4.50
  8    101    18475      8          0          4.25
  9    101    18506      9          9          5.75
 10    101    18536     10          0          4.25
 11    101    18567     11          1          2.50
 12    101    18597     12          2          3.00
 13    101    18628     13          1          1.00
 14    101    18659     14          5          2.25
 15    101    18687     15          4          3.00
 16    102    18263      1          6           .
 17    102    18294      2          8           .
 18    102    18322      3          8           .
 19    102    18353      4          3          6.25     6+8+8+3 = 25/4 =6.25
 20    102    18383      5          7          6.50
 21    102    18414      6          4          5.50
 22    102    18444      7          3          4.25
 23    102    18475      8          0          3.50
 24    102    18506      9          1          2.00
 25    102    18536     10          8          3.00
 26    102    18567     11          8          4.25
 27    102    18597     12          3          5.00
 28    102    18628     13          8          6.75


*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

* make data same as above code;
filename bin "d:/bin/binmat.bin" lrecl=32000 recfm=f;
data have;
  retain id month;
  format month yymm7.;
  call streaminit(54321);
  do id=101 to 102;
     do mnth=1 to 15;
         sumResponse=int(10*rand('uniform'));
         month=intnx('month', '01JAN2010'd, mnth-1);
         file bin;
         put (id sumresponse) (2*rb8.) @@ ;
         if id=102 and mnth>13 then leave;
         output;
      end;
  end;
run;quit;

* widow size;
%let window=4;

proc sql;
  select count(*)*2 into :_obs from have
;quit;


%utl_submit_r64(resolve('
library(SASxport);
library(TTR);
library(dplyr);
library(data.table);
read.from <- file("d:/bin/binmat.bin", "rb");
mat <- readBin(read.from, n=&_obs., "double");
str(mat);
close(read.from);
mat <- as.data.table(matrix(mat,&_obs./2,2,byrow=T));
mat[1:28];
ra<-mat %>% group_by(V1) %>% mutate(ra = runMean(V2, &window));
want<-as.vector(ra$ra);
outbin <- "d:/bin/want.bin";
writeBin(want, file(outbin, "wb"), size=8);
'));


filename bin "d:/bin/want.bin" lrecl=8 recfm=f;
data want ;
 infile bin;
 set hAVE;
 input ave10 rb8. @@;
 put ave10;
run;quit;

*_  _    ___
| || |  / _ \ _ __ ___  _ __ ___
| || |_| | | | '_ ` _ \| '_ ` _ \
|__   _| |_| | | | | | | | | | | |
   |_|  \___/|_| |_| |_|_| |_| |_|


40 million solution
;


filename bin  "d:/bin/binmat .bin" lrecl=32000 recfm=f;
data have;
  retain id month;
  format month yymm7.;
  call streaminit(54321);
  do id=101 to 400100;
     do mnth=1 to 100;
         sumResponse=int(10*rand('uniform'));
         month=intnx('month', '01JAN2010'd, mnth-1);
         file bin;
         put (id sumresponse) (2*rb8.) @@ ;
         output;
      end;
  end;
run;quit;

* 12 seconds;

%let window=10;

proc sql;
  select count(*)*2 into :_obs from have
;quit;

%utl_submit_r64(resolve('
library(SASxport);
library(TTR);
library(dplyr);
library(data.table);
read.from <- file("d:/bin/binmat.bin", "rb");
mat <- readBin(read.from, n=&_obs., "double");
close(read.from);
mat <- as.data.table(matrix(mat,&_obs./2,2,byrow=T));
ra<-mat %>% group_by(V1) %>% mutate(ra = runMean(V2, &window));
want<-as.vector(ra$ra);
outbin <- "d:/bin/want.bin";
writeBin(want, file(outbin, "wb"), size=8);
'));

* real time           1:51.63;

filename bin "d:/bin/want.bin" lrecl=8 recfm=f;
data bin ;
 infile bin;
 set hAVE;
 input ave10 rb8. @@;
run;quit;

* real time           8.17 seconds;

*            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;

WORK.WANT total obs=39,999,913

     Obs     ID        MONTH     MNTH    SUMRESPONSE    AVE10

       1    101       2010M01      1          4           .
       2    101       2010M02      2          5           .
       3    101       2010M03      3          7           .
       4    101       2010M04      4          1           .
       5    101       2010M05      5          3           .
       6    101       2010M06      6          6           .
       7    101       2010M07      7          8           .
       8    101       2010M08      8          0           .
       9    101       2010M09      9          9           .
      10    101       2010M10     10          0          4.3
      11    101       2010M11     11          1          4.0
      12    101       2010M12     12          2          3.7
      13    101       2011M01     13          1          3.1
      14    101       2011M02     14          5          3.5
      15    101       2011M03     15          4          3.6
      16    101       2011M04     16          6          3.6
      17    101       2011M05     17          8          3.6
      18    101       2011M06     18          8          4.4
     ...

39999903    400100    2010M09     90          3          3.7
39999904    400100    2010M10     91          3          3.4
39999905    400100    2010M11     92          4          3.6
39999906    400100    2010M12     93          2          3.3
39999907    400100    2011M01     94          5          3.5
39999908    400100    2011M02     95          0          3.5
39999909    400100    2011M03     96          7          3.1
39999910    400100    2011M04     97          9          3.5
39999911    400100    2011M05     98          5          3.9
39999912    400100    2011M06     99          9          4.2
39999913    400100    2011M06    100          0          4.7

FYI

  The tail recors were placed in the past buffer after
  highlighting WANT and typing tailh on the command line.


