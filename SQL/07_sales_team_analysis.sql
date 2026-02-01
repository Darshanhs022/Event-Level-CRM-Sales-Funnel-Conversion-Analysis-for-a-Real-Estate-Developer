-- leads per executive
select
  assigned_exec_id as exec_id,
  count(*) as total_leads
from leads_master
group by assigned_exec_id
order by total_leads desc;


-- events by initiator (sales vs system)
select
  initiated_by as exec_id,
  count(*) as total_events
from crm_event_log
where initiated_by is not null
group by initiated_by
order by total_events desc;


-- conversion rate per executive
select
  lm.assigned_exec_id as exec_id,
  count(*) as total_leads,
  count(case when lfs.final_stage = 'Booked' then 1 end) as booked,
  round(
    count(case when lfs.final_stage = 'Booked' then 1 end) * 100.0 / count(*),
    2
  ) as booking_conversion_pct
from leads_master lm
join lead_funnel_summary lfs
  on lfs.lead_id = lm.lead_id
group by lm.assigned_exec_id
order by booking_conversion_pct desc;


-- revenue per executive
select
  lm.assigned_exec_id as exec_id,
  count(b.lead_id) as bookings,
  sum(b.final_price) as total_revenue
from leads_master lm
join bookings b
  on b.lead_id = lm.lead_id
where b.booking_status = 'Confirmed'
group by lm.assigned_exec_id
order by total_revenue desc;


-- average time to close per executive
select
  lm.assigned_exec_id as exec_id,
  avg(b.booking_ts - lm.lead_created_ts) as avg_time_to_close
from leads_master lm
join bookings b
  on b.lead_id = lm.lead_id
where b.booking_status = 'Confirmed'
group by lm.assigned_exec_id
order by avg_time_to_close;


-- experience vs conversion
select
  se.exec_id,
  se.experience_months,
  count(*) as total_leads,
  count(case when lfs.final_stage = 'Booked' then 1 end) as booked,
  round(
    count(case when lfs.final_stage = 'Booked' then 1 end) * 100.0 / count(*),
    2
  ) as conversion_pct
from sales_executives se
join leads_master lm
  on lm.assigned_exec_id = se.exec_id
join lead_funnel_summary lfs
  on lfs.lead_id = lm.lead_id
group by se.exec_id, se.experience_months
order by conversion_pct desc;
