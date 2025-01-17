use bank_loan;
select * from financial_loan;

select count(*) from financial_loan;

alter table financial_loan
add column con_issue_date date;

-- Conveting the date values in the 'issue_date' column to a valid date format and adding the values into column 'con_issue_date'.

update financial_loan
SET con_issue_date = CASE
    when issue_date like '__/__/____' then str_to_date(issue_date, '%d/%m/%Y') -- DD/MM/YYYY
    when issue_date like '__-__-____' then str_to_date(issue_date, '%d-%m-%Y') -- DD-MM-YYYY
    when issue_date like '____-__-__' then str_to_date(issue_date, '%Y-%m-%d') -- YYYY-MM-DD
    else null
end;

alter table financial_loan
drop column issue_date;

alter table financial_loan
change column con_issue_date issue_date Date;

-- Adding column as 'con_last_credit_pull_date' to table

alter table financial_loan
add column con_last_credit_pull_date date;

select * from financial_loan; 

update financial_loan
SET con_last_credit_pull_date = CASE
    when last_credit_pull_date like '__/__/____' then str_to_date(last_credit_pull_date, '%d/%m/%Y') -- DD/MM/YYYY
    when last_credit_pull_date like '__-__-____' then str_to_date(last_credit_pull_date, '%d-%m-%Y') -- DD-MM-YYYY
    when last_credit_pull_date like '____-__-__' then str_to_date(last_credit_pull_date, '%Y-%m-%d') -- YYYY-MM-DD
    else null
end;
alter table financial_loan
drop column last_credit_pull_date;

alter table financial_loan
change column con_last_credit_pull_date last_credit_pull_date Date;

-- next_payment_date
alter table financial_loan
add column con_next_payment_date date;

update financial_loan
SET con_next_payment_date = CASE
    when next_payment_date like '__/__/____' then str_to_date(next_payment_date, '%d/%m/%Y') -- DD/MM/YYYY
    when next_payment_date like '__-__-____' then str_to_date(next_payment_date, '%d-%m-%Y') -- DD-MM-YYYY
    when next_payment_date like '____-__-__' then str_to_date(next_payment_date, '%Y-%m-%d') -- YYYY-MM-DD
    else null
end;

alter table financial_loan
drop column next_payment_date;

alter table financial_loan
change column con_next_payment_date next_payment_date Date;

-- last_payment_date
alter table financial_loan
add column con_last_payment_date date;

update financial_loan
SET con_last_payment_date = CASE
    when last_payment_date like '__/__/____' then str_to_date(last_payment_date, '%d/%m/%Y') -- DD/MM/YYYY
    when last_payment_date like '__-__-____' then str_to_date(last_payment_date, '%d-%m-%Y') -- DD-MM-YYYY
    when last_payment_date like '____-__-__' then str_to_date(last_payment_date, '%Y-%m-%d') -- YYYY-MM-DD
    else null
end;
alter table financial_loan
drop column last_payment_date;

select * from financial_loan;

alter table financial_loan
change column con_last_payment_date last_payment_date Date;

-- put last_payment_date after last_credit_pull_date

ALTER TABLE financial_loan 
MODIFY COLUMN last_payment_date date
after last_credit_pull_date;



/* calculating the total application recived */

select count(id) as Total_loan_applications
from financial_loan;

-- calculating  MTD(month to date) total loan applications

select count(id) as MTD_Total_loan_applications
from financial_loan
where Month(issue_date) = 12 and year(issue_date) = 2021; -- current month(4314)

-- calculating PMTD(previous month to date) total loan applications

select count(id) as PMTD_Total_loan_applications
from financial_loan
where Month(issue_date) = 11 and year(issue_date) = 2021; -- previous month (4035)

-- calculating the MOM(month over month) total loan application
with MTD_app as(
select count(id) as MTD_Total_loan_applications
from financial_loan
where Month(issue_date) = 12 and year(issue_date) = 2021),
PMTD_app as (
select count(id) as PMTD_Total_loan_applications
from financial_loan
where Month(issue_date) = 11 and year(issue_date) = 2021)

select ((MTD. MTD_Total_loan_applications - PMTD.PMTD_Total_loan_applications)/PMTD.PMTD_Total_loan_applications *100) AS MOM_Total_loan_applications
from MTD_app MTD, PMTD_app PMTD;  -- (6.9145)


/*calculating the total funded amount */
select * from financial_loan;

select sum(loan_amount) as Total_loan_amount
from financial_loan; -- (435757075)

-- calculating the MTD total funded amount
select sum(loan_amount) as MTD_Total_loan_amount
from financial_loan
where Month(issue_date) = 12 and year(issue_date) = 2021; -- month to date ('53981425')

select sum(loan_amount) as PMTD_Total_loan_amount
from financial_loan
where Month(issue_date) = 11 and year(issue_date) = 2021; -- month to date (''47754825')

with MTD_funded as(
select sum(loan_amount) as MTD_Total_loan_amount
from financial_loan
where Month(issue_date) = 12 and year(issue_date) = 2021),
PMTD_funded as (
select sum(loan_amount) as PMTD_Total_loan_amount
from financial_loan
where Month(issue_date) = 11 and year(issue_date) = 2021)

select ((MTD. MTD_Total_loan_amount - PMTD.PMTD_Total_loan_amount)/PMTD.PMTD_Total_loan_amount *100) AS MOM_Total_loan_amount
from MTD_funded MTD, PMTD_funded PMTD;  -- MOM(month over month)('13.0387')


/* calculating Total amount recieved. */

select * from financial_loan;
select sum(total_payment) as Total_payment_recieved
from financial_loan; -- ('473070933')

-- calculating the MTD total amount recieved
select sum(total_payment) as MTD_total_amount_recieved
from financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021; -- ('58074380')

select sum(total_payment) as PMTD_total_amount_recieved
from financial_loan
where month(issue_date) = 11 and year(issue_date) = 2021; -- ('50132030')

with MTD_recieved as (
select sum(total_payment) as MTD_total_amount_recieved
from financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021),
PMTD_recieved as (
select sum(total_payment) as PMTD_total_amount_recieved
from financial_loan
where month(issue_date) = 11 and year(issue_date) = 2021)

select ((MTD.MTD_total_amount_recieved - PMTD.PMTD_total_amount_recieved)/PMTD.PMTD_total_amount_recieved *100) AS MOM_Total_amount_recieved
from MTD_recieved MTD, PMTD_recieved PMTD;  -- MOM('15.8429')


/* calculaitng the Average interest rate */

select avg(int_rate)*100
from financial_loan; -- ('12.048831397760178') percentage

-- calculating the MTD Average interest rate (int_rate)

select avg(int_rate)*100 as MTD_avg_int_rate
from financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021; -- ('12.356040797403738')

select avg(int_rate)*100 as PMTD_avg_int_rate
from financial_loan
where month(issue_date) = 11 and year(issue_date) = 2021; -- ('11.941717472118796')

with MTD_avg as (
select avg(int_rate)*100 as MTD_avg_int_rate
from financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021),
PMTD_avg as (
select avg(int_rate)*100 as PMTD_avg_int_rate
from financial_loan
where month(issue_date) = 11 and year(issue_date) = 2021)

select ((MTD.MTD_avg_int_rate - PMTD.PMTD_avg_int_rate)/PMTD.PMTD_avg_int_rate *100) AS MOM_avg_int_rate
from MTD_avg MTD, PMTD_avg PMTD; -- ('3.4695455344031783')


/* calculating average debt to income ratio (dti) */

select avg(dti)*100
from financial_loan; -- ('13.32743311903776')

select avg(dti)*100 as MTD_total_avg_dti_ratio
from financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021; -- ('13.66553778395922')

select avg(dti)*100 as PMTD_total_avg_dti_ratio
from financial_loan
where month(issue_date) = 11 and year(issue_date) = 2021; -- ('13.302733581164852')

with MTD_avg_dti as (
select avg(dti)*100 as MTD_total_avg_dti_ratio
from financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021),
PMTD_avg_dti as (
select avg(dti)*100 as PMTD_total_avg_dti_ratio
from financial_loan
where month(issue_date) = 11 and year(issue_date) = 2021)

select ((MTD.MTD_total_avg_dti_ratio - PMTD.PMTD_total_avg_dti_ratio)/PMTD.PMTD_total_avg_dti_ratio *100) AS MOM_avg_dti_ratio
from MTD_avg_dti MTD, PMTD_avg_dti PMTD; -- ('2.7272906021966534')


/* Good loan */
-- calculating the Good loan application percentage (loan_status)

select * from financial_loan;
select (count(CASE when loan_status = 'Fully Paid' Or loan_status = 'Current' then id end)*100)/count(id) as Good_loan_percentage
from financial_loan; -- ('86.1753')

-- calculating Total Good loan application cf-(5333),fp-(32145)

select count(id) as Good_loan_applications
from financial_loan 
where loan_status = 'Fully Paid' OR loan_status = 'Current'; -- ('33243')

-- calculating the good loan funded amount

select sum(loan_amount) as Good_loan_funded_amount
from financial_loan
where loan_status = 'Fully Paid' OR loan_status = 'Current';-- ('370224850')

-- calculating the Good loan recieved amount
select sum(total_payment) as Good_loan_recieved_amount
from financial_loan
where loan_status = 'Fully Paid' OR loan_status = 'Current';   -- ('435786170')


/* Bad Loan */

--  calculating the bad loan application percentage
select * from financial_loan;
select (count(case when loan_status = 'Charged Off' then id end)*100)/count(id) as Bad_loan_application_percentage
from financial_loan; -- ('13.8247')

-- calculating the bad loan applictions

select count(id) as Bad_loan_applications
from financial_loan
where loan_status = 'Charged Off'; -- (5333)

-- calculating Bad loan funded amount

select sum(loan_amount) as Bad_loan_funded_amount
from financial_loan
where loan_status = 'Charged Off'; -- ('65532225')

-- calculating the Bad loan recieved amount

select sum(total_payment) as Bad_loan_funded_amount
from financial_loan
where loan_status = 'Charged Off'; -- ('37284763')

/* calculating the loan_count, Total_Amount_Recieved, Total_Funded_Amount , Inetrest_Rate, DTI on the bases of the laon status */

select loan_status,
count(id) as Loan_Count,
sum(total_payment) as Total_Amount_Recieved,
sum(loan_amount) as Total_Funded_Amount,
avg(int_rate*100) as Inetrest_Rate,
avg(dti*100) as DTI
from financial_loan
group by loan_status;

-- calculating MTD_Total_Amount_Recieved, MTD_Total_Funded_Amount on the basis of loan_status

select
     loan_status,
     sum(loan_amount) as MTD_Total_Funded_Amount,
     sum(total_payment) as MTD_Total_Amount_Recieved
from financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021
group by loan_status;

-- calculating monthly Total_Loan_Application , Total_Funded_Amount and Total_Amount_Recieved
-- financial loan report overview - on the basis of month
select 
month(issue_date) as month_number,
monthname(issue_date) as month_name,
count(id) as Total_Loan_Application,
sum(loan_amount) as Total_Funded_Amount,
sum(total_payment) as Total_Amount_Recieved
from financial_loan
group by month(issue_date), monthname(issue_date)
order by month(issue_date);

-- financial loan report overview- on the basis of state
select
address_state as state,
count(id) as Total_Loan_Application,
sum(loan_amount) as Total_Funded_Amount,
sum(total_payment) as Total_Amount_Recieved
from financial_loan
group by address_state
order by address_state;

select * from financial_loan;

-- financial loan report overview- term

select
term as Term,
count(id) as Total_Loan_Application,
sum(loan_amount) as Total_Funded_Amount,
sum(total_payment) as Total_Amount_Recieved
from financial_loan
group by term
order by term;

-- financial loan report overview- employee length

select
emp_length as Employee_length,
count(id) as Total_Loan_Application,
sum(loan_amount) as Total_Funded_Amount,
sum(total_payment) as Total_Amount_Recieved
from financial_loan
group by emp_length
order by emp_length;

-- financial loan report overview- purpose of the loan
select
purpose as Purpose_of_loan,
count(id) as Total_Loan_Application,
sum(loan_amount) as Total_Funded_Amount,
sum(total_payment) as Total_Amount_Recieved
from financial_loan
group by purpose
order by purpose;

-- financial loan report overview- home ownership

select
home_ownership as Home_Ownership,
count(id) as Total_Loan_Application,
sum(loan_amount) as Total_Funded_Amount,
sum(total_payment) as Total_Amount_Recieved
from financial_loan
group by home_ownership
order by home_ownership;