CREATE TABLE leads_master (
    lead_id TEXT PRIMARY KEY,
    lead_created_ts TIMESTAMP,
    lead_source_raw TEXT,
    raw_campaign_name TEXT,
    customer_type TEXT,
    preferred_unit_type TEXT,
    budget_min NUMERIC,
    budget_max NUMERIC,
    lead_score INTEGER,
    assigned_exec_id TEXT,
    project_id TEXT,
    project_name TEXT,
    city TEXT
);

CREATE TABLE sales_executives (
    exec_id TEXT PRIMARY KEY,
    exec_name TEXT,
    experience_months INTEGER,
    team TEXT
);

CREATE TABLE crm_event_log (
    event_id INTEGER PRIMARY KEY,
    lead_id TEXT NOT NULL,
    event_type TEXT,
    event_ts TIMESTAMP,
    stage_name TEXT,
    event_channel TEXT,
    initiated_by TEXT,
    response_status TEXT,
    sla_breached_flag BOOLEAN,
    CONSTRAINT fk_event_lead
      FOREIGN KEY (lead_id)
      REFERENCES leads_master (lead_id)
);

CREATE TABLE bookings (
    lead_id TEXT PRIMARY KEY,
    booking_ts TIMESTAMP,
    project_name TEXT,
    city TEXT,
    unit_type TEXT,
    payment_plan TEXT,
    loan_required_flag BOOLEAN,
    base_price NUMERIC,
    discount NUMERIC,
    final_price NUMERIC,
    booking_status TEXT,
    CONSTRAINT fk_booking_lead
      FOREIGN KEY (lead_id)
      REFERENCES leads_master (lead_id)
);