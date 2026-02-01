-- row counts
select count(*) as total_leads from leads_master;
select count(*) as total_events from crm_event_log;
select count(*) as total_bookings from bookings;
select count(*) as total_sales_execs from sales_executives;

-- leads with no events
select count(*) as leads_with_no_events
from leads_master lm
left join crm_event_log el
  on lm.lead_id = el.lead_id
where el.lead_id is null;

-- orphan events
select count(*) as orphan_events
from crm_event_log el
left join leads_master lm
  on el.lead_id = lm.lead_id
where lm.lead_id is null;

-- orphan bookings
select count(*) as orphan_bookings
from bookings b
left join leads_master lm
  on b.lead_id = lm.lead_id
where lm.lead_id is null;

-- funnel stages present
select distinct stage_name
from crm_event_log
where stage_name is not null
order by stage_name;

-- event types present
select distinct event_type
from crm_event_log
order by event_type;

-- booking status check
select booking_status, count(*) as total
from bookings
group by booking_status;

-- events before lead creation (should be zero)
select count(*) as invalid_event_timestamps
from crm_event_log el
join leads_master lm
  on el.lead_id = lm.lead_id
where el.event_ts < lm.lead_created_ts;
