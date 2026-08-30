-- Query 1: Find monitoring stations within 5 km of Gangtok
SELECT 
    ms.id,
    ms.station_code,
    ms.name AS station_name,
    ms.station_type,
    ms.latitude,
    ms.longitude,
    ROUND(
        (ST_Distance(
            ms.geom::geography, 
            ST_SetSRID(ST_MakePoint(88.6138, 27.3389), 4326)::geography
        ) / 1000)::numeric, 2
    ) AS distance_km
FROM monitoring_stations ms
WHERE ST_DWithin(
    ms.geom::geography,
    ST_SetSRID(ST_MakePoint(88.6138, 27.3389), 4326)::geography,
    5000
)
ORDER BY distance_km ASC;


-- Query 2: Find villages inside CRITICAL or VERY_HIGH risk zones
SELECT 
    v.id AS village_id,
    v.name AS village_name,
    d.name AS district_name,
    v.population,
    rz.name AS risk_zone_name,
    rz.risk_level,
    rz.risk_score
FROM villages v
JOIN districts d ON v.district_id = d.id
JOIN risk_zones rz ON ST_Within(v.geom, rz.geom)
WHERE rz.risk_level IN ('CRITICAL', 'VERY_HIGH')
ORDER BY rz.risk_score DESC;


-- Query 3: Find historical landslides within 10 km of Rumtek Village
SELECT 
    hl.id AS event_id,
    hl.event_time,
    hl.severity,
    hl.trigger_type,
    hl.casualties,
    hl.description,
    ROUND(
        (ST_Distance(
            hl.geom::geography, 
            v.geom::geography
        ) / 1000)::numeric, 2
    ) AS distance_from_rumtek_km
FROM historical_landslides hl,
     villages v
WHERE v.name = 'Rumtek Village'
  AND ST_DWithin(hl.geom::geography, v.geom::geography, 10000)
ORDER BY hl.event_time DESC;


-- Query 4: Heavy Rainfall Telemetry (> 50mm in last 6h)
SELECT 
    ms.station_code,
    ms.name AS station_name,
    eo.observed_at,
    eo.rainfall_mm,
    eo.soil_moisture,
    eo.displacement_mm,
    eo.ground_vibration
FROM environmental_observations eo
JOIN monitoring_stations ms ON eo.station_id = ms.id
WHERE eo.observed_at >= NOW() - INTERVAL '6 HOURS'
  AND eo.rainfall_mm > 50.0
ORDER BY eo.observed_at DESC;


-- Query 5: Active Evacuation Alerts with Risk & Population Details
SELECT 
    a.id AS alert_id,
    a.alert_level,
    a.title,
    a.message,
    a.affected_population,
    rz.name AS risk_zone_name,
    rp.risk_score,
    rp.confidence,
    rp.model_name,
    rp.model_version,
    rp.input_features->>'rainfall_6h' AS rainfall_6h_mm,
    rp.input_features->>'displacement_mm' AS displacement_mm
FROM alerts a
JOIN risk_predictions rp ON a.prediction_id = rp.id
JOIN risk_zones rz ON rp.risk_zone_id = rz.id
WHERE a.status = 'ACTIVE'
ORDER BY rp.risk_score DESC;


-- Query 6: Overlap between Historical Landslides and Current Risk Zones
SELECT 
    rz.name AS current_risk_zone,
    rz.risk_level,
    hl.id AS historical_event_id,
    hl.event_time,
    hl.severity AS historical_severity,
    hl.description
FROM risk_zones rz
JOIN historical_landslides hl ON ST_Intersects(rz.geom, hl.geom);
