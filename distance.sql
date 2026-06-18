WITH lat_lon_bounds AS (
  -- For each county, create bounding box of ~300 miles
  SELECT
    a.countyfp AS from_county,
    a.statefp AS from_state,
    a.latitude AS from_lat,
    a.longitude AS from_lon,
    b.countyfp AS to_county,
    b.statefp AS to_state,
    b.latitude AS to_lat,
    b.longitude AS to_lon
  FROM Datalab.Market_Saturation.Counties_population_centroids_pbi_extract a
  CROSS JOIN Datalab.Market_Saturation.Counties_population_centroids_pbi_extract b
  WHERE ABS(a.latitude - b.latitude) < 5
    AND ABS(a.longitude - b.longitude) < 6
    AND a.countyfp < b.countyfp
),
with_distances AS (
  SELECT
    from_county,
    from_state,
    to_county,
    to_state,
    -- Haversine formula (returns miles directly)
    2 * 3959 * ASIN(SQRT(
      POWER(SIN(RADIANS(to_lat - from_lat) / 2), 2) +
      COS(RADIANS(from_lat)) * COS(RADIANS(to_lat)) *
      POWER(SIN(RADIANS(to_lon - from_lon) / 2), 2)
    )) AS distance_miles
  FROM lat_lon_bounds
)
SELECT *
FROM with_distances
WHERE distance_miles <= 300
ORDER BY from_county, distance_miles;
