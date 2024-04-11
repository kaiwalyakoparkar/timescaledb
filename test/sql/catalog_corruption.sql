-- This file and its contents are licensed under the Apache License 2.0.
-- Please see the included NOTICE for copyright information and
-- LICENSE-APACHE for a copy of the license.

\c :TEST_DBNAME :ROLE_SUPERUSER

--- Test handling of missing dimension slices
CREATE TABLE dim_test(time TIMESTAMPTZ, device int);
SELECT create_hypertable('dim_test', 'time', chunk_time_interval => INTERVAL '1 day');

-- Create two chunks
INSERT INTO dim_test values('2000-01-01 00:00:00', 1);
INSERT INTO dim_test values('2020-01-01 00:00:00', 1);

SELECT id AS dim_slice_id FROM _timescaledb_catalog.dimension_slice
  ORDER BY id DESC LIMIT 1
  \gset

-- Delete the dimension slice for the second chunk
DELETE FROM _timescaledb_catalog.chunk_constraint WHERE dimension_slice_id = :dim_slice_id;

\set ON_ERROR_STOP 0

-- Select data
SELECT * FROM dim_test;

-- Select data using ordered append
SELECT * FROM dim_test ORDER BY time;

\set ON_ERROR_STOP 1

DROP TABLE dim_test;

