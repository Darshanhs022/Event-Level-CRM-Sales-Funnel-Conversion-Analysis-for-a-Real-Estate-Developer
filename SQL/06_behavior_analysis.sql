-- follow-up count vs booking conversion
with followup_counts as (
  select
    lead_id,
    count(*) as followup_count
  from crm_event_log
  where event_type = 'follow_up'
  group by lead_id
),
lead_followups as (
  select
    lfs.lead_id,
    coalesce(fc.followup_count, 0) as followup_count,
    lfs.final_stage
  from lead_funnel_summary lfs
  left join followup_counts fc
    on fc.lead_id = lfs.lead_id
)
select
  case
    when followup_count = 0 then '0'
    when followup_count between 1 and 2 then '1–2'
    when followup_count between 3 and 5 then '3–5'
    when followup_count between 6 and 10 then '6–10'
    else '10+'
  end as followup_bucket,
  count(*) as total_leads,
  count(case when final_stage = 'Booked' then 1 end) as booked,
  round(
    count(case when final_stage = 'Booked' then 1 end) * 100.0 / count(*),
    2
  ) as booking_conversion_pct
from lead_followups
group by followup_bucket
order by followup_bucket;


-- budget bucket vs booking conversion
with lead_budget as (
  select
    lfs.lead_id,
    (lm.budget_min + lm.budget_max) / 2.0 as avg_budget,
    lfs.final_stage
  from lead_funnel_summary lfs
  join leads_master lm
    on lm.lead_id = lfs.lead_id
  where lm.budget_min is not null
    and lm.budget_max is not null
)
select
  case
    when avg_budget < 5000000 then '< 50L'
    when avg_budget between 5000000 and 8000000 then '50–80L'
    when avg_budget between 8000000 and 12000000 then '80L–1.2Cr'
    else '> 1.2Cr'
  end as budget_bucket,
  count(*) as total_leads,
  count(case when final_stage = 'Booked' then 1 end) as booked,
  round(
    count(case when final_stage = 'Booked' then 1 end) * 100.0 / count(*),
    2
  ) as booking_conversion_pct
from lead_budget
group by budget_bucket
order by booking_conversion_pct desc;


-- sla breach vs booking conversion
with lead_sla as (
  select
    lead_id,
    max(case when sla_breached_flag = true then 1 else 0 end) as sla_breached
  from crm_event_log
  group by lead_id
)
select
  sla_breached,
  count(*) as total_leads,
  count(case when final_stage = 'Booked' then 1 end) as booked,
  round(
    count(case when final_stage = 'Booked' then 1 end) * 100.0 / count(*),
    2
  ) as booking_conversion_pct
from lead_sla ls
join lead_funnel_summary lfs
  on lfs.lead_id = ls.lead_id
group by sla_breached;
