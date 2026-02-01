-- funnel volume
create or replace view vw_funnel_volume as
select 
    count(*) as total_leads,
    count(first_contact_date) as contacted,
    count(first_site_visit_date) as site_visit,
    count(first_negotiation_date) as negotiation,
    count(case when final_stage = 'Booked' then 1 end) as booked
from lead_funnel_summary;


-- funnel conversion percentages
select 
    round(contacted * 100.0 / total_leads, 2)        as lead_to_contact_pct,
    round(site_visit * 100.0 / contacted, 2)         as contact_to_site_visit_pct,
    round(negotiation * 100.0 / site_visit, 2)       as visit_to_negotiation_pct,
    round(booked * 100.0 / negotiation, 2)           as negotiation_to_booking_pct
from vw_funnel_volume;


-- funnel drop-off counts
select
    count(first_contact_date) - count(first_site_visit_date) as drop_after_contact,
    count(first_site_visit_date) - count(first_negotiation_date) as drop_after_site_visit,
    count(first_negotiation_date) -
    count(case when final_stage = 'Booked' then 1 end) as drop_after_negotiation
from lead_funnel_summary;


-- funnel volume by lead source
select
    lm.lead_source_raw,
    count(*) as total_leads,
    count(lfs.first_contact_date) as contacted,
    count(lfs.first_site_visit_date) as site_visit,
    count(lfs.first_negotiation_date) as negotiation,
    count(case when lfs.final_stage = 'Booked' then 1 end) as booked
from lead_funnel_summary lfs
join leads_master lm
  on lm.lead_id = lfs.lead_id
group by lm.lead_source_raw
order by total_leads desc;


-- source-wise conversion rate
with source_funnel as (
    select
        lm.lead_source_raw,
        count(*) as total_leads,
        count(case when lfs.final_stage = 'Booked' then 1 end) as booked
    from lead_funnel_summary lfs
    join leads_master lm
      on lm.lead_id = lfs.lead_id
    group by lm.lead_source_raw
)
select
    lead_source_raw,
    total_leads,
    booked,
    round(booked * 100.0 / total_leads, 2) as booking_conversion_pct
from source_funnel
order by booking_conversion_pct desc;


-- source-wise drop-off diagnosis
select
    lm.lead_source_raw,
    count(lfs.first_contact_date) - count(lfs.first_site_visit_date) as drop_after_contact,
    count(lfs.first_site_visit_date) - count(lfs.first_negotiation_date) as drop_after_site_visit,
    count(lfs.first_negotiation_date) -
    count(case when lfs.final_stage = 'Booked' then 1 end) as drop_after_negotiation
from lead_funnel_summary lfs
join leads_master lm
  on lm.lead_id = lfs.lead_id
group by lm.lead_source_raw
order by drop_after_contact desc;
