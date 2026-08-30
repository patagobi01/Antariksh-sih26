CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS alerts CASCADE;
DROP TABLE IF EXISTS risk_predictions CASCADE;
DROP TABLE IF EXISTS risk_zones CASCADE;
DROP TABLE IF EXISTS historical_landslides CASCADE;
DROP TABLE IF EXISTS environmental_observations CASCADE;
DROP TABLE IF EXISTS monitoring_stations CASCADE;
DROP TABLE IF EXISTS data_sources CASCADE;
DROP TABLE IF EXISTS villages CASCADE;
DROP TABLE IF EXISTS districts CASCADE;
DROP TABLE IF EXISTS states CASCADE;

CREATE TABLE states (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(10) UNIQUE,
    geom GEOMETRY(MULTIPOLYGON, 4326),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE districts (
    id SERIAL PRIMARY KEY,
    state_id INTEGER NOT NULL REFERENCES states(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    geom GEOMETRY(MULTIPOLYGON, 4326),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE villages (
    id BIGSERIAL PRIMARY KEY,
    district_id INTEGER NOT NULL REFERENCES districts(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    population INTEGER DEFAULT 0,
    elevation_m REAL,
    geom GEOMETRY(POINT, 4326),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_states_geom ON states USING GIST (geom);
CREATE INDEX idx_districts_geom ON districts USING GIST (geom);
CREATE INDEX idx_villages_geom ON villages USING GIST (geom);

CREATE TABLE data_sources (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    source_type VARCHAR(50) NOT NULL,
    provider VARCHAR(150),
    description TEXT,
    update_frequency VARCHAR(50),
    api_endpoint TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE monitoring_stations (
    id BIGSERIAL PRIMARY KEY,
    source_id INTEGER REFERENCES data_sources(id) ON DELETE SET NULL,
    station_code VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    station_type VARCHAR(50) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    elevation_m REAL,
    geom GEOMETRY(POINT, 4326),
    status VARCHAR(30) DEFAULT 'ACTIVE',
    installed_at TIMESTAMPTZ,
    last_seen TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_monitoring_stations_geom ON monitoring_stations USING GIST (geom);
CREATE INDEX idx_monitoring_stations_code ON monitoring_stations(station_code);

CREATE TABLE environmental_observations (
    id BIGSERIAL PRIMARY KEY,
    station_id BIGINT NOT NULL REFERENCES monitoring_stations(id) ON DELETE CASCADE,
    observed_at TIMESTAMPTZ NOT NULL,
    rainfall_mm REAL,
    soil_moisture REAL,
    temperature_c REAL,
    ground_vibration REAL,
    displacement_mm REAL,
    humidity_percent REAL,
    quality_flag VARCHAR(20) DEFAULT 'GOOD',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_env_obs_station_time ON environmental_observations (station_id, observed_at DESC);
CREATE INDEX idx_env_obs_rainfall ON environmental_observations (observed_at DESC) WHERE rainfall_mm > 0;

CREATE TABLE historical_landslides (
    id BIGSERIAL PRIMARY KEY,
    district_id INTEGER REFERENCES districts(id) ON DELETE SET NULL,
    village_id BIGINT REFERENCES villages(id) ON DELETE SET NULL,
    event_time TIMESTAMPTZ,
    severity VARCHAR(30),
    trigger_type VARCHAR(100),
    area_affected_km2 REAL,
    casualties INTEGER DEFAULT 0,
    estimated_damage_inr NUMERIC(15,2),
    description TEXT,
    source VARCHAR(255),
    geom GEOMETRY(POINT, 4326),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_historical_landslides_geom ON historical_landslides USING GIST (geom);
CREATE INDEX idx_historical_landslides_time ON historical_landslides(event_time DESC);

CREATE TABLE risk_zones (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    district_id INTEGER REFERENCES districts(id) ON DELETE CASCADE,
    risk_level VARCHAR(30) NOT NULL,
    risk_score NUMERIC(5,4) NOT NULL,
    valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMPTZ,
    geom GEOMETRY(MULTIPOLYGON, 4326),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_risk_zones_geom ON risk_zones USING GIST (geom);
CREATE INDEX idx_risk_zones_level ON risk_zones(risk_level);

CREATE TABLE risk_predictions (
    id BIGSERIAL PRIMARY KEY,
    risk_zone_id BIGINT REFERENCES risk_zones(id) ON DELETE CASCADE,
    prediction_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    prediction_horizon_hours INTEGER DEFAULT 6,
    risk_score NUMERIC(5,4) NOT NULL,
    risk_level VARCHAR(30) NOT NULL,
    confidence NUMERIC(5,4),
    model_name VARCHAR(100) NOT NULL,
    model_version VARCHAR(50) NOT NULL,
    input_features JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_risk_predictions_zone_time ON risk_predictions(risk_zone_id, prediction_time DESC);
CREATE INDEX idx_risk_predictions_level ON risk_predictions(risk_level);

CREATE TABLE alerts (
    id BIGSERIAL PRIMARY KEY,
    prediction_id BIGINT NOT NULL REFERENCES risk_predictions(id) ON DELETE CASCADE,
    alert_level VARCHAR(30) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    issued_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ,
    status VARCHAR(30) DEFAULT 'ACTIVE',
    affected_population INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_alerts_status ON alerts(status);
CREATE INDEX idx_alerts_issued_at ON alerts(issued_at DESC);
