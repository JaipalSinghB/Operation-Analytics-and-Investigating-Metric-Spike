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
 
 