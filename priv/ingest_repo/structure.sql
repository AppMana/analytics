CREATE TABLE if not exists appmana.sessions ON CLUSTER '{cluster}'
(
    `session_id`       UInt64,
    `sign`             Int8,
    `domain`           String,
    `user_id`          UInt64,
    `hostname`         String,
    `is_bounce`        UInt8,
    `entry_page`       String,
    `exit_page`        String,
    `pageviews`        Int32,
    `events`           Int32,
    `duration`         UInt32,
    `referrer`         String,
    `referrer_source`  String,
    `country_code` LowCardinality(FixedString(2)),
    `screen_size` LowCardinality(String),
    `operating_system` LowCardinality(String),
    `browser` LowCardinality(String),
    `start`            DateTime,
    `timestamp`        DateTime,
    `utm_medium`       String,
    `utm_source`       String,
    `utm_campaign`     String,
    `browser_version` LowCardinality(String),
    `operating_system_version` LowCardinality(String),
    `subdivision1_code` LowCardinality(String),
    `subdivision2_code` LowCardinality(String),
    `city_geoname_id`  UInt32,
    `utm_content`      String,
    `utm_term`         String,
    `transferred_from` String,
    `entry_meta.key`   Array(String),
    `entry_meta.value` Array(String)
)
    ENGINE = ReplicatedCollapsingMergeTree('/clickhouse/tables/{shard}/appmana/sessions', '{replica}', sign)
        PARTITION BY toYYYYMM(start)
        ORDER BY (domain, toDate(start), user_id, session_id)
        SAMPLE BY user_id
        SETTINGS index_granularity = 8192;


CREATE TABLE if not exists appmana.ingest_counters ON CLUSTER '{cluster}'
(
    `event_timebucket` DateTime,
    `domain` LowCardinality(String),
    `site_id` Nullable(UInt64),
    `metric` LowCardinality(String),
    `value`            UInt64
)
    ENGINE = ReplicatedSummingMergeTree('/clickhouse/tables/{shard}/appmana/ingest_counters', '{replica}', value)
        ORDER BY (domain, toDate(event_timebucket), metric, toStartOfMinute(event_timebucket))
        SETTINGS index_granularity = 8192;

CREATE TABLE if not exists appmana.imported_visitors ON CLUSTER '{cluster}'
(
    `site_id`        UInt64,
    `date`           Date,
    `visitors`       UInt64,
    `pageviews`      UInt64,
    `bounces`        UInt64,
    `visits`         UInt64,
    `visit_duration` UInt64
)
    ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/appmana/imported_visitors', '{replica}')
        ORDER BY (site_id, date)
        SETTINGS index_granularity = 8192;

CREATE TABLE if not exists appmana.imported_sources ON CLUSTER '{cluster}'
(
    `site_id`        UInt64,
    `date`           Date,
    `source`         String,
    `utm_medium`     String,
    `utm_campaign`   String,
    `utm_content`    String,
    `utm_term`       String,
    `visitors`       UInt64,
    `visits`         UInt64,
    `visit_duration` UInt64,
    `bounces`        UInt32
)
    ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/appmana/imported_sources', '{replica}')
        ORDER BY (site_id, date, source)
        SETTINGS index_granularity = 8192;


CREATE TABLE if not exists appmana.imported_pages ON CLUSTER '{cluster}'
(
    `site_id`      UInt64,
    `date`         Date,
    `hostname`     String,
    `page`         String,
    `visitors`     UInt64,
    `pageviews`    UInt64,
    `exits`        UInt64,
    `time_on_page` UInt64
)
    ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/appmana/imported_pages', '{replica}')
        ORDER BY (site_id, date, hostname, page)
        SETTINGS index_granularity = 8192;

CREATE TABLE if not exists appmana.imported_operating_systems ON CLUSTER '{cluster}'
(
    `site_id`          UInt64,
    `date`             Date,
    `operating_system` String,
    `visitors`         UInt64,
    `visits`           UInt64,
    `visit_duration`   UInt64,
    `bounces`          UInt32
)
    ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/appmana/imported_operating_systems', '{replica}')
        ORDER BY (site_id, date, operating_system)
        SETTINGS index_granularity = 8192;

CREATE TABLE if not exists appmana.imported_locations ON CLUSTER '{cluster}'
(
    `site_id`        UInt64,
    `date`           Date,
    `country`        String,
    `region`         String,
    `city`           UInt64,
    `visitors`       UInt64,
    `visits`         UInt64,
    `visit_duration` UInt64,
    `bounces`        UInt32
)
    ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/appmana/imported_locations', '{replica}')
        ORDER BY (site_id, date, country, region, city)
        SETTINGS index_granularity = 8192;


CREATE TABLE if not exists appmana.imported_exit_pages ON CLUSTER '{cluster}'
(
    `site_id`   UInt64,
    `date`      Date,
    `exit_page` String,
    `visitors`  UInt64,
    `exits`     UInt64
)
    ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/appmana/imported_exit_pages', '{replica}')
        ORDER BY (site_id, date, exit_page)
        SETTINGS index_granularity = 8192;

CREATE TABLE if not exists appmana.imported_entry_pages ON CLUSTER '{cluster}'
(
    `site_id`        UInt64,
    `date`           Date,
    `entry_page`     String,
    `visitors`       UInt64,
    `entrances`      UInt64,
    `visit_duration` UInt64,
    `bounces`        UInt32
)
    ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/appmana/imported_entry_pages', '{replica}')
        ORDER BY (site_id, date, entry_page)
        SETTINGS index_granularity = 8192;

CREATE TABLE if not exists appmana.imported_devices ON CLUSTER '{cluster}'
(
    `site_id`        UInt64,
    `date`           Date,
    `device`         String,
    `visitors`       UInt64,
    `visits`         UInt64,
    `visit_duration` UInt64,
    `bounces`        UInt32
)
    ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/appmana/imported_devices', '{replica}')
        ORDER BY (site_id, date, device)
        SETTINGS index_granularity = 8192;

CREATE TABLE if not exists appmana.imported_browsers ON CLUSTER '{cluster}'
(
    `site_id`        UInt64,
    `date`           Date,
    `browser`        String,
    `visitors`       UInt64,
    `visits`         UInt64,
    `visit_duration` UInt64,
    `bounces`        UInt32
)
    ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/appmana/imported_browsers', '{replica}')
        ORDER BY (site_id, date, browser)
        SETTINGS index_granularity = 8192;

CREATE TABLE if not exists appmana.events ON CLUSTER '{cluster}'
(
    `name`             String,
    `domain`           String,
    `user_id`          UInt64,
    `session_id`       UInt64,
    `hostname`         String,
    `pathname`         String,
    `referrer`         String,
    `referrer_source`  String,
    `country_code` LowCardinality(FixedString(2)),
    `screen_size` LowCardinality(String),
    `operating_system` LowCardinality(String),
    `browser` LowCardinality(String),
    `timestamp`        DateTime,
    `utm_medium`       String,
    `utm_source`       String,
    `utm_campaign`     String,
    `meta.key`         Array(String),
    `meta.value`       Array(String),
    `browser_version` LowCardinality(String),
    `operating_system_version` LowCardinality(String),
    `subdivision1_code` LowCardinality(String),
    `subdivision2_code` LowCardinality(String),
    `city_geoname_id`  UInt32,
    `utm_content`      String,
    `utm_term`         String,
    `transferred_from` String
)
    ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/appmana/events', '{replica}')
        PARTITION BY toYYYYMM(timestamp)
        ORDER BY (domain, toDate(timestamp), user_id)
        SAMPLE BY user_id
        SETTINGS index_granularity = 8192;


CREATE TABLE IF NOT EXISTS appmana.schema_migrations ON CLUSTER '{cluster}'
(
    `version`     Int64,
    `inserted_at` DateTime
)
    ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/appmana/schema_migrations', '{replica}')
        ORDER BY version
        SETTINGS index_granularity = 8192;

INSERT INTO "appmana"."schema_migrations" (version, inserted_at)
VALUES (20200915070607, '2023-03-08 10:03:33'),
       (20200918075025, '2023-03-08 10:03:33'),
       (20201020083739, '2023-03-08 10:03:33'),
       (20201106125234, '2023-03-08 10:03:33'),
       (20210323130440, '2023-03-08 10:03:33'),
       (20210712214034, '2023-03-08 10:03:33'),
       (20211017093035, '2023-03-08 10:03:33'),
       (20211112130238, '2023-03-08 10:03:33'),
       (20220310104931, '2023-03-08 10:03:33'),
       (20220404123000, '2023-03-08 10:03:33'),
       (20220421161259, '2023-03-08 10:03:33'),
       (20220422075510, '2023-03-08 10:03:33'),
       (20230124140348, '2023-03-08 10:03:33'),
       (20230210140348, '2023-03-08 10:03:33'),
       (20230214114402, '2023-03-08 10:03:33');
