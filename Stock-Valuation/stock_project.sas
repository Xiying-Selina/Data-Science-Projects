libname project "/home/u63092905/sasuser.v94/fin557/project";

proc contents data=project.stock;
run; 

/*Create new colums: Outstanding, Year, QUARTER and PB_ratio*/
/*Only select positive PB_ratio*/
data stock1;
    set project.stock;
    Outstanding = MKVALTQ/PRCCQ;
    PB_ratio = PRCCQ*Outstanding/CEQQ;
    Year = year(DATADATE);
    QUARTER = qtr(DATADATE);
    if PB_ratio > 0;
run;

/*Filter three years' data to calculate average PB_ratio*/
data stock2;
set stock1;
keep GVKEY DATADATE YEAR QUARTER SIC CONM PRCCQ PB_ratio;
where YEAR in (2015,2016,2017);
run;

/*Calculate three years average PB ratio of different companies*/
proc means data=stock2;
	var PB_ratio;
	class CONM;
	ways 1;
	output out=PBmean mean=AvgPB; 
run;

/*Find p25 and p75 of companies' average PB_ratio*/
proc univariate data= PBmean;
	var AvgPB;
run;

proc print data = PBmean;
run;


/*Average PB_ratio p25 =2.009185 and p75 = 6.092965*/ 
/*We assume that the bottom 25% of the stocks in the PB ratio are "value stocks" */
/*We assume that the top 25% of the stocks in the PB ratio are "growth stocks" */
/*Others are "general stocks"*/

/*Divide all stocks into three groups(based on p25 and p75)*/
data stock4;
	set PBmean;
	length stock_group $14;
	keep  CONM AvgPB stock_group;
	where AvgPB is not missing;
	if AvgPB=<2.009185 then do;
        stock_group="value stock";
		output;
	end;
	else if AvgPB>6.092965 then do;
         stock_group="growth stock";
		 output;
	end;
    else do;
         stock_group="general stock";
		 output;
	end;
run;

proc print data = stock4;
run;

/*Filter five years' data*/
data stock_after_2017;
set stock1;
keep GVKEY DATADATE YEAR QUARTER CONM PRCCQ;
where YEAR in (2018,2019,2020,2021,2022);
run;

/*Sort by company name*/
proc sort data=stock4;
by CONM;
run;

proc sort data=stock_after_2017;
by CONM;
run;

/*Merge stock group and stock price(after 2017) by company name*/
data stock_price;
merge stock4 stock_after_2017;
by CONM;
run;

proc sort data=stock_price;
by CONM;
run;

/*Get stock price in 2018 and 2022 to calculate stock return*/
data stock_return;
set stock_price;
by CONM;
if first.CONM = 1 then output;
else if last.CONM = 1 then output;
run;

/*Calculate stock return*/
data stock_return2;
	set stock_return;
	by CONM Year;
	PRCCQ2=lag(PRCCQ);
	if first.CONM then PRCCQ2=.;
	ret=(PRCCQ-PRCCQ2)/PRCCQ2;
run;

proc print data=stock_return2;
run;

/*Keep non-missing return*/
data stock_return3;
set stock_return2;
where ret~=.;
run;

proc print data=stock_return3;
run;

/*Get average returns of each stock group*/
proc means data=stock_return3;
var ret;
class stock_group;
ways 1;
run;


/* Create a new column: "Sector" to define industry*/
/* In our case, we have five industries and each industry contains 10 companies */
/* Define the sectors and assign TIC to them */

proc sql;
  create table sector_data as 
  select distinct TIC,CONM,
         case 
           when TIC in ('AAPL','MSFT','IBM','INTC','CSCO','ORCL','HPE','DELL','ADBE','TXN') then 'Technology'
           when TIC in ('XOM', 'CVX', 'COP', 'HAL','OXY','MPC','VLO','EOG','SLB','WMB') then 'Energy'
           when TIC in ('WMT','AMZN','HD','COST','TGT','LOW','CVS','WBA','DLTR','TJX') then 'Ratail'
           when TIC in ('JNJ','PFE','MRK','BMY','LLY','ABT','AMGN','UNH','GILD','BIIB') then 'Healthcare'
           when TIC in ('JPM','BAC','WFC','C','GS','AXP','MS','V','MA','COF') then 'Finance'
         end as Sector
  from stock1;
quit;

/* Check if all assigned well*/
proc sql;
select Sector, count(distinct TIC) as TIC_count
from sector_data
group by Sector;
quit;

/* Sort stock1 and sector_data by CONM */
proc sort data=stock1;
   by CONM;
run;

proc sort data=sector_data;
   by CONM;
run;

/* Merge the sector data with the main data */
data main_data;
   merge stock1 sector_data;
   by CONM;
run;

/* Stock avgerage performance in different industries*/
proc sql;
create table stock_group_sector as
select distinct stock4.CONM, AvgPB, stock_group, sector from stock4
left join main_data as m
on stock4.CONM = m.CONM;
quit;

proc print data=stock_group_sector;
run;

proc sql;
select stock_group,sector, count(*) as stock_number
from stock_group_sector
group by stock_group, sector
order by stock_group, stock_number desc;
quit; 

/* Combine sector to stock_return3*/
proc sql;
create table stock_industry as
select distinct stock_return3.CONM, stock_group, sector,ret from stock_return3
left join main_data as m
on stock_return3.CONM = m.CONM;
quit;

proc print data=stock_industry;
run;

/*Get average returns of each industry*/
proc means data=stock_industry;
var ret;
class Sector;
ways 1;
run;



