-- first occurrence of each funnel stage per lead
create or replace view vw_lead_stage_dates as
select
  lead_id,
  min(case when stage_name = 'Contacted' then event_ts end) as first_contact_date,
  min(case when stage_name = 'Site Visit' then event_ts end) as first_site_visit_date,
  min(case when stage_name = 'Negotiation' then event_ts end) as first_negotiation_date,
  min(case when stage_name = 'Booked' then event_ts end) as booking_date,
  min(case when stage_name = 'Lost' then event_ts end) as lost_date
from crm_event_log
where stage_name is not null
group by lead_id;


-- final funnel position per lead
drop table if exists lead_funnel_summary;

create table lead_funnel_summary as
select
  lead_id,
  first_contact_date,
  first_site_visit_date,
  first_negotiation_date,
  case
    when booking_date is not null then 'Booked'
    when lost_date is not null then 'Lost'
    when first_negotiation_date is not null then 'Negotiation'
    when first_site_visit_date is not null then 'Site Visit'
    when first_contact_date is not null then 'Contacted'
    else 'Unknown'
  end as final_stage,
  coalesce(
    booking_date,
    lost_date,
    first_negotiation_date,
    first_site_visit_date,
    first_contact_date
  ) as final_stage_date
from vw_lead_stage_dates;
