-- monthly lead inflow
select
  date_trunc('month', lead_created_ts) as month,
  count(*) as leads_created
from leads_master
group by 1
order by 1;


-- monthly bookings and revenue
select
  date_trunc('month', booking_ts) as month,
  count(*) as bookings,
  sum(final_price) as revenue
from bookings
where booking_status = 'Confirmed'
group by 1
order by 1;


-- time to first contact
with first_contact as (
  select
    lead_id,
    min(event_ts) as first_contact_ts
  from crm_event_log
  where stage_name = 'Contacted'
  group by lead_id
)
select
  min(first_contact_ts - lm.lead_created_ts) as min_response_time,
  max(first_contact_ts - lm.lead_created_ts) as max_response_time,
  avg(first_contact_ts - lm.lead_created_ts) as avg_response_time
from first_contact fc
join leads_master lm
  on lm.lead_id = fc.lead_id;


-- site visit to booking time
with booked_leads as (
  select
    lead_id,
    first_site_visit_date,
    final_stage_date as booking_date
  from lead_funnel_summary
  where final_stage = 'Booked'
    and first_site_visit_date is not null
)
select
  min(booking_date - first_site_visit_date) as min_days,
  max(booking_date - first_site_visit_date) as max_days,
  avg(booking_date - first_site_visit_date) as avg_days
from booked_leads;
