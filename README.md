# 🏔️ Landslide Early Warning System - Core Geospatial Database (`landslide_db`)

High-performance PostgreSQL + PostGIS database foundation designed for **SIH 2026 (Problem Statement SIH26001)**. Built specifically for geospatial polygon queries, environmental time-series observations, ML risk predictions, historical disaster tracking, and early warning alert dispatch.

---

## 🏗️ Architecture & Entity Relationship Flow

```
                      ┌───────────────┐
                      │    STATES     │
                      └───────┬───────┘
                              │
                      ┌───────▼────────┐
                      │   DISTRICTS    │
                      └───────┬────────┘
                              │
                ┌─────────────┼─────────────┐
                │             │             │
                ▼             ▼             ▼
           VILLAGES      DATA SOURCES    RISK ZONES
                              │             │
               ┌──────────────┼─────────────┘
               ▼              ▼              ▼
           RAINFALL       SEISMIC       SATELLITE
          OBSERVATIONS   OBSERVATIONS   OBSERVATIONS
               │              │              │
               └──────────────┼──────────────┘
                              ▼
                    HISTORICAL LANDSLIDES
                              │
                              ▼
                      AI PREDICTIONS
                              │
                              ▼
                           ALERTS
```

---

## 📁 Repository Structure

```
SIH 26/
├── docker-compose.yml           # PostgreSQL 16 + PostGIS 3.4 + pgAdmin 4 Docker deployment
├── README.md                    # Database documentation & query guide
└── database/
    ├── 01_schema.sql            # Core DDL (PostGIS extension, 10 MVP tables & GiST indexes)
    ├── 02_seed_data.sql         # Realistic Northeast India geospatial data (Sikkim, Meghalaya)
    ├── 03_queries.sql           # PostGIS queries (ST_DWithin, ST_Within, ST_Intersects)
    └── test_schema.py           # Verification script for DDL and seed files
```

---

## 📊 Core MVP Schema Entities (10 Tables)

| # | Table Name | PostGIS Type / Key Features | Purpose |
|---|---|---|---|
| 1 | `states` | `GEOMETRY(MULTIPOLYGON, 4326)` | Administrative state boundaries (Sikkim, Meghalaya, etc.) |
| 2 | `districts` | `GEOMETRY(MULTIPOLYGON, 4326)` | District spatial boundaries |
| 3 | `villages` | `GEOMETRY(POINT, 4326)` | Villages & human settlements with population statistics |
| 4 | `data_sources` | Metadata fields | Weather APIs, Satellite feeds (Sentinel-1/2), Seismic networks |
| 5 | `monitoring_stations` | `GEOMETRY(POINT, 4326)` | Rain gauges, AWS, tiltmeters, ground displacement sensors |
| 6 | `environmental_observations` | Composite B-Tree Indexes | High-frequency telemetry (rainfall_mm, soil_moisture, vibration) |
| 7 | `historical_landslides` | `GEOMETRY(POINT, 4326)` | Past landslide events dataset for ML training & validation |
| 8 | `risk_zones` | `GEOMETRY(MULTIPOLYGON, 4326)` | Dynamic hazard polygons with risk scores & levels |
| 9 | `risk_predictions` | `JSONB` for dynamic inputs | AI/ML model output log (XGBoost/LSTM hazard predictions) |
| 10 | `alerts` | Foreign Key to Predictions | Emergency warnings, status, & target population affected |

---

## 🚀 How to Run locally

### Option 1: Using Docker & Docker Compose (Recommended)

1. Launch PostgreSQL + PostGIS container:
   ```bash
   docker-compose up -d
   ```
2. The database will automatically initialize `landslide_db`, create all 10 tables, spatial indexes, and insert Northeast India seed data.
3. Access **pgAdmin 4** in your browser at `http://localhost:5050`
   - Email: `admin@sih2026.gov.in`
   - Password: `admin_sih_password`

### Option 2: Using Local PostgreSQL + PostGIS

1. Connect to PostgreSQL via `psql` or pgAdmin:
   ```sql
   CREATE DATABASE landslide_db;
   \c landslide_db
   ```
2. Execute the migration scripts in order:
   ```bash
   psql -U postgres -d landslide_db -f database/01_schema.sql
   psql -U postgres -d landslide_db -f database/02_seed_data.sql
   ```

---

## 🔍 Key PostGIS Spatial Queries

### 1. Find Monitoring Stations within 5 km Radius
```sql
SELECT station_code, name, 
       ROUND((ST_Distance(geom::geography, ST_SetSRID(ST_MakePoint(88.6138, 27.3389), 4326)::geography)/1000)::numeric, 2) AS dist_km
FROM monitoring_stations
WHERE ST_DWithin(geom::geography, ST_SetSRID(ST_MakePoint(88.6138, 27.3389), 4326)::geography, 5000);
```

### 2. Identify Villages inside Critical Hazard Polygons
```sql
SELECT v.name AS village, rz.name AS risk_zone, rz.risk_level, rz.risk_score
FROM villages v
JOIN risk_zones rz ON ST_Within(v.geom, rz.geom)
WHERE rz.risk_level IN ('CRITICAL', 'VERY_HIGH');
```

---

## 🧪 Run Verification Test Script

```bash
python3 database/test_schema.py
```
