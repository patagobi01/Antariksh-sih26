INSERT INTO states (name, code, geom) VALUES
('Sikkim', 'SK', ST_Multi(ST_GeomFromText('POLYGON((88.00 27.00, 88.90 27.00, 88.90 28.10, 88.00 28.10, 88.00 27.00))', 4326))),
('Meghalaya', 'ML', ST_Multi(ST_GeomFromText('POLYGON((89.80 25.00, 92.80 25.00, 92.80 26.10, 89.80 26.10, 89.80 25.00))', 4326))),
('Arunachal Pradesh', 'AR', ST_Multi(ST_GeomFromText('POLYGON((91.50 26.60, 97.40 26.60, 97.40 29.50, 91.50 29.50, 91.50 26.60))', 4326)));

INSERT INTO districts (state_id, name, geom) VALUES
(1, 'Gangtok District', ST_Multi(ST_GeomFromText('POLYGON((88.50 27.20, 88.75 27.20, 88.75 27.45, 88.50 27.45, 88.50 27.20))', 4326))),
(1, 'Pakyong District', ST_Multi(ST_GeomFromText('POLYGON((88.50 27.10, 88.70 27.10, 88.70 27.28, 88.50 27.28, 88.50 27.10))', 4326))),
(2, 'East Khasi Hills', ST_Multi(ST_GeomFromText('POLYGON((91.50 25.10, 92.00 25.10, 92.00 25.60, 91.50 25.60, 91.50 25.10))', 4326)));

-- ST_MakePoint(longitude, latitude)
INSERT INTO villages (district_id, name, population, elevation_m, geom) VALUES
(1, 'Gangtok Town', 100000, 1650.0, ST_SetSRID(ST_MakePoint(88.6138, 27.3389), 4326)),
(1, 'Rumtek Village', 4500, 1500.0, ST_SetSRID(ST_MakePoint(88.6015, 27.3022), 4326)),
(2, 'Pakyong Town', 12000, 1120.0, ST_SetSRID(ST_MakePoint(88.5880, 27.2370), 4326)),
(3, 'Cherrapunji (Sohra)', 14800, 1430.0, ST_SetSRID(ST_MakePoint(91.7323, 25.2702), 4326)),
(3, 'Mawsynram Village', 4200, 1400.0, ST_SetSRID(ST_MakePoint(91.5833, 25.3000), 4326));

INSERT INTO data_sources (name, source_type, provider, description, update_frequency, api_endpoint) VALUES
('IMD Rainfall Grid API', 'WEATHER_API', 'India Meteorological Department', 'Real-time gridded precipitation data over NE region', 'Hourly', 'https://api.imd.gov.in/v1/rainfall'),
('Sentinel-1 SAR Satellite Imagery', 'SATELLITE', 'ESA / Copernicus', 'InSAR ground surface displacement & deformation maps', '6 Days', 'https://scihub.copernicus.eu/dhus'),
('NCS Seismic Telemetry', 'SEISMIC_SENSOR', 'National Center for Seismology', 'Real-time ground acceleration and micro-seismic readings', 'Real-time', 'https://seismo.gov.in/api/v1/events'),
('Sikkim IoT Hill Slopes Network', 'IOT', 'State Disaster Management Authority', 'Field deployed tiltmeters and soil moisture probes', '15 Mins', 'https://iot.sikkim-sdma.gov.in/telemetry');

INSERT INTO monitoring_stations (source_id, station_code, name, station_type, latitude, longitude, elevation_m, geom, status, installed_at, last_seen) VALUES
(1, 'STN-GTK-01', 'Gangtok Ridge Weather Station', 'RAIN_GAUGE', 27.3389, 88.6138, 1650.0, ST_SetSRID(ST_MakePoint(88.6138, 27.3389), 4326), 'ACTIVE', '2024-01-15 00:00:00+00', NOW()),
(4, 'STN-RMK-02', 'Rumtek Hill Slope Tiltmeter', 'MULTI_SENSOR', 27.3022, 88.6015, 1500.0, ST_SetSRID(ST_MakePoint(88.6015, 27.3022), 4326), 'ACTIVE', '2024-03-10 00:00:00+00', NOW()),
(1, 'STN-PKY-03', 'Pakyong Airport Rain Gauge', 'RAIN_GAUGE', 27.2370, 88.5880, 1120.0, ST_SetSRID(ST_MakePoint(88.5880, 27.2370), 4326), 'ACTIVE', '2024-02-01 00:00:00+00', NOW()),
(1, 'STN-SHR-04', 'Sohra Heavy Rainfall Station', 'RAIN_GAUGE', 25.2702, 91.7323, 1430.0, ST_SetSRID(ST_MakePoint(91.7323, 25.2702), 4326), 'ACTIVE', '2023-11-20 00:00:00+00', NOW());

INSERT INTO environmental_observations (station_id, observed_at, rainfall_mm, soil_moisture, temperature_c, ground_vibration, displacement_mm, humidity_percent) VALUES
(1, NOW() - INTERVAL '3 HOURS', 12.4, 45.2, 21.5, 0.01, 0.0, 88.0),
(1, NOW() - INTERVAL '2 HOURS', 35.8, 62.8, 20.1, 0.03, 0.2, 94.0),
(1, NOW() - INTERVAL '1 HOUR',  78.2, 88.5, 19.4, 0.12, 1.8, 98.0),
(1, NOW(),                      104.5, 96.2, 18.8, 0.45, 5.4, 99.0),
(2, NOW() - INTERVAL '1 HOUR',  65.0, 82.1, 20.0, 0.38, 4.1, 95.0),
(2, NOW(),                      92.3, 94.8, 19.2, 0.82, 12.6, 99.0),
(4, NOW() - INTERVAL '1 HOUR',  140.0, 91.0, 22.0, 0.05, 0.5, 100.0),
(4, NOW(),                      185.0, 98.5, 21.2, 0.08, 1.1, 100.0);

INSERT INTO historical_landslides (district_id, village_id, event_time, severity, trigger_type, area_affected_km2, casualties, estimated_damage_inr, description, source, geom) VALUES
(1, 1, '2023-06-18 14:30:00+00', 'SEVERE', 'HEAVY_RAINFALL', 0.45, 3, 25000000.00, 'Major slope failure near Gangtok National Highway-10 due to continuous 48h monsoon rain.', 'State Disaster Management Authority', ST_SetSRID(ST_MakePoint(88.6110, 27.3350), 4326)),
(1, 2, '2022-08-11 09:15:00+00', 'MODERATE', 'CLOUDBURST', 0.20, 0, 8000000.00, 'Debris flow blocking Rumtek access road following intense cloudburst event.', 'Local News Report / GSI', ST_SetSRID(ST_MakePoint(88.5980, 27.3010), 4326)),
(3, 4, '2021-07-20 18:00:00+00', 'CATASTROPHIC', 'HEAVY_RAINFALL', 1.20, 7, 65000000.00, 'Massive mudslide washing away hill road sections near Sohra falls.', 'Geological Survey of India', ST_SetSRID(ST_MakePoint(91.7350, 25.2680), 4326));

INSERT INTO risk_zones (name, district_id, risk_level, risk_score, valid_from, valid_until, geom) VALUES
('Gangtok Hill Ridge Hazard Polygon', 1, 'VERY_HIGH', 0.8850, NOW() - INTERVAL '1 DAY', NOW() + INTERVAL '2 DAYS', 
 ST_Multi(ST_GeomFromText('POLYGON((88.59 27.31, 88.64 27.31, 88.64 27.36, 88.59 27.36, 88.59 27.31))', 4326))),
('Rumtek Slope Active Failure Zone', 1, 'CRITICAL', 0.9420, NOW() - INTERVAL '6 HOURS', NOW() + INTERVAL '1 DAY', 
 ST_Multi(ST_GeomFromText('POLYGON((88.58 27.28, 88.62 27.28, 88.62 27.32, 88.58 27.32, 88.58 27.28))', 4326))),
('Cherrapunji South EsCarpment Zone', 3, 'HIGH', 0.7600, NOW() - INTERVAL '12 HOURS', NOW() + INTERVAL '3 DAYS', 
 ST_Multi(ST_GeomFromText('POLYGON((91.70 25.24, 91.76 25.24, 91.76 25.30, 91.70 25.30, 91.70 25.24))', 4326)));

INSERT INTO risk_predictions (risk_zone_id, prediction_time, prediction_horizon_hours, risk_score, risk_level, confidence, model_name, model_version, input_features) VALUES
(1, NOW() - INTERVAL '1 HOUR', 6, 0.8850, 'VERY_HIGH', 0.9120, 'XGBoost-LandslideNet', 'v1.4', '{"rainfall_6h": 190.9, "rainfall_24h": 320.5, "soil_moisture": 96.2, "slope_deg": 38.5, "displacement_mm": 5.4}'),
(2, NOW(),                      6, 0.9420, 'CRITICAL',  0.9580, 'XGBoost-LandslideNet', 'v1.4', '{"rainfall_6h": 157.3, "soil_moisture": 94.8, "slope_deg": 42.1, "displacement_mm": 12.6, "ground_vibration": 0.82}'),
(3, NOW() - INTERVAL '2 HOURS', 12, 0.7600, 'HIGH',      0.8740, 'LSTM-TemporalHazard', 'v2.1', '{"rainfall_24h": 325.0, "soil_moisture": 98.5, "slope_deg": 33.0}');

INSERT INTO alerts (prediction_id, alert_level, title, message, issued_at, expires_at, status, affected_population) VALUES
(2, 'EMERGENCY', 'IMMINENT LANDSLIDE WARNING: Rumtek Slope', 'Extremely high risk of landslide within 6 hours due to 92mm rainfall and active slope displacement (12.6mm). Immediate evacuation advised for Rumtek slope residents.', NOW(), NOW() + INTERVAL '12 HOURS', 'ACTIVE', 4500),
(1, 'WARNING', 'HIGH LANDSLIDE RISK ALERT: Gangtok Ridge Zone', 'Torrential rain exceeding 100mm in last 3h. High probability of debris flow affecting lower Gangtok highway corridor. Exercise extreme caution.', NOW() - INTERVAL '1 HOUR', NOW() + INTERVAL '18 HOURS', 'ACTIVE', 25000);
