
SELECT * FROM `operation analytics and investigating metric spike 1`;

 --  1) Calculate the number of jobs reviewed per hour per day for November 2020?
 
 SELECT count(job_id)/(30*24)  FROM `operation analytics and investigating metric spike 1`
 where ds between '2020-11-01' and '2020-11-30' ;
 
 
--   2) Calculate 7 day rolling average of throughput? For throughput, do you prefer daily metric or 7-day rolling and why?

with cte as (select ds, count(job_id) as job_reviewed FROM `operation analytics and investigating metric spike 1` 
group by ds) 

select ds , job_reviewed ,
avg (job_reviewed ) over (  order by ds  rows between 6 preceding and current row ) as throughput
FROM cte order by throughput desc ;


 --  3) Calculate the percentage share of each language in the last 30 days?
 
 select language, count( job_id) as num_jobs FROM `operation analytics and investigating metric spike 1`
 group by job_id ;
 select language,job_id/count(job_id)FROM `operation analytics and investigating metric spike 1` ;
 
 
-- 1) Calculate the weekly user engagement?
select * from events;

SELECT count(distinct user_id) as num_of_users_engaged_weekly,
cast(occurred_at as datetime)as occurred_at , 
extract(week from occurred_at)as week_num FROM database_1.events
group by 3;

-- 2)Calculate the user growth for product?

select activation_week,
user_id,
sum(user_id)over(order by  activation_week rows between unbounded preceding and current row ) as user_growth
from 
(SELECT 
count(distinct user_id)as user_id ,
cast(created_at as datetime)as created_at , -- using cast function to convert string type to datetime to extract week part later in query  
extract(year from activated_at)as activation_year , extract(week from activated_at)as activation_week 
FROM database_1.users
where state = 'active' -- I am taking only the active users to calculate user growth
group by activation_week)a;


-- 3) Calculate the weekly retention of users-sign up cohort?

 /* In this problem  I used the CTE function to divide the EVENT_TYPE COLUMN  in 2 parts (signup_flow and engagement)
     And the result will divide in 2 sections for each user on the basis of EVENT_NAME like (complete_signup,login,home_page ETC)
     which he might have done while signup and while engaging with respect to the week number 
     which is represented in COLUMN 4 and 8 respectively of the result section . */
 
 
with signup_date  as  (
					SELECT user_id , EVENT_TYPE , event_name, EXTRACT(WEEK From OCCURRED_at)as signup_date FROM events 
					 WHERE event_type = 'SIGNUP_FLOW' ) ,
		engagement as (
					select user_id , event_type ,event_name, extract(week from occurred_at) as engaging_week from events
				  WHERE event_type = 'engagement')

select distinct e.user_id ,s.signup_date,e.engaging_week ,
				(e.engaging_week- s.signup_date) as retention_week          -- -----> ( e.user_id  , s.event_type , s.event_name,e.event_type, e.event_name, s.signup_date , e.engaging_week) <----- FOR CROSS CHECKING 
from signup_date as s
		   join engagement as e on  e.user_id = s.user_id
          ;
          
       

--  4) Calculate the weekly engagement per device?
-- SELECT * FROM database_1.users;

SELECT count(distinct(user_id))as users, extract(week from occurred_at) as num_week ,
extract(year from occurred_at) as num_year, device 
 from events 
 where event_type ='engagement'
 group by device 
 order by num_week;
 
 -- SECOND WAY TO SOLVE QUERY ---------->
 
 select users, extract(week from occurred_at) as num_week ,
extract(year from occurred_at) as num_year, device 
from (SELECT count(distinct(user_id))as users, 
device,  occurred_at
 from events 
 where event_type ='engagement'
 group by device 
 )as a order by num_week;
 
 
 -- 5) Calculate the email engagement metrics?
 
 -- SELECT  Distinct(action),count(*) emails FROM database_1.email_events
 -- group by action;
 
 
  select 
  100*sum(case when email_category = 'email_open' then 1 else 0 end )/sum(case when email_category = 'email_sent' then 1 else 0 end) as email_open_rate,
  100*sum(case when email_category = 'email_click' then 1 else 0 end )/sum(case when email_category = 'email_sent' then 1 else 0 end) as email_click_rate
 from (
 select 
 case 
 when action = 'sent_weekly_digest'or'sent_reengagement_email' then 'email_sent'
 when action  ='email_open' then 'email_open'
 when action ='email_clickthrough' then 'email_click'
 End as Email_category
 from email_events)as a ;

 