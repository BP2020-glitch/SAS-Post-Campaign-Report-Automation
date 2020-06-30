 ## /*Post-campaign Revenue Analysis*/

  /*Report automating using Macro variable*/
  %let mydata= %str(/folders/myfolders/sasdata/reportdata); 
  libname mydata "&mydata";

  proc sort data=mydata.surv_data  out=surv_data(drop=monthly_fee);
  by customer_ID;
  run;

  proc sort data=mydata.tel out=tel;
  by customer_ID;
  run;

  proc sql;   
  create table tel_data as
  select a.*, b.*
  from surv_data as a ,tel as b
  where input(a.customer_ID, best12.)=b.customer_ID;  
  quit;


  /*Check the distribution of revenue*/
  proc univariate data=tel_data ;
  var TOT_REV_AMT;
  histogram TOT_REV_AMT/normal(mu=est sigma=est);
  run;
	
  data tel_data_1;
  set tel_data;
  length rev_class $13;
	if tot_rev_amt lt 0 then rev_class="1: <$0"; 
    else if tot_rev_amt le 25 then rev_class="2: $0-$25"; 
    else if tot_rev_amt le 45 then rev_class="3: $25.01-$45"; 
    else if tot_rev_amt le 70 then rev_class="4: $45.01-$70"; 
    else if tot_rev_amt le 100 then rev_class="5: $70.1-$100"; 
    else rev_class="6: $100+";
  Run;


  /*Check the distribution of age*/
    proc univariate data=tel_data ;
    var cust_age;
	histogram cust_age/normal(mu=est sigma=est);
	run;


	data tel_data_1;
	set tel_data;
	length rev_class age_class $ 30.;

    if tot_rev_amt lt 0 then rev_class="1: <$0"; 
    else if tot_rev_amt le 25 then rev_class="2: $0-$25"; 
    else if tot_rev_amt le 45 then rev_class="3: $25.01-$45"; 
    else if tot_rev_amt le 70 then rev_class="4: $45.01-$70"; 
    else if tot_rev_amt le 100 then rev_class="5: $70.1-$100"; 
    else rev_class="6: $100+";

	 if cust_age le 24 then age_class="1: <=24"; 
     else if cust_age le 30 then age_class="2: <=30";
     else if cust_age le 45 then age_class="3: <=45"; 
     else if cust_age le 60 then age_class="4: <=60"; 
     else age_class="5: 60+";
	 run;

  /*Campaign Reporting*/
  proc tabulate data=tel_data_1;
  class age_class rev_class market;
  table age_class= "Age" market="Region", rev_class=""*(n="Num of customers" colpctn="Percent of Row")  all="total";
  run;


  proc format;
  picture pctf
  low-high="009.99%"
  ;
  run;

  proc tabulate data=tel_data_1;
  class age_class rev_class market;

  table age_class= "Age" market="Region", rev_class=""*(n="Num of customers" colpctn="Percent of Row"*f=pctf.)  all="total";
  run;







