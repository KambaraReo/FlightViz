import { useEffect, useState } from "react";
import { MapContainer, TileLayer } from 'react-leaflet';
import AirportMarker from './AirportMarker';
import { fetchAirports } from '../utils/api/airports';
import type { Airport } from '../utils/api/airports';

const AirportMap = () => {
  const [airports, setAirports] = useState<Airport[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const status = 1;

  useEffect(() => {
    setLoading(true);

    fetchAirports(status)
      .then((data) => {
        setAirports(data);
      })
      .catch((err) => {
        console.error("Failed to fetch airports", err);
        setError("空港データの取得に失敗しました");
      })
      .finally(() => {
        setLoading(false);
      });
  }, []);

  return loading ? (
    <p>Loading...</p>
  ) : ( error ? (
    <p>{error}</p>
  ): (
    <MapContainer
      center={[36.2048, 138.2529]}
      zoom={5.0}
      className="w-full h-full"
    >
      <TileLayer
        url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
        attribution='&copy; OpenStreetMap & CartoDB'
      />
      {airports.map((airport) => (
        <AirportMarker
          key={airport.icao_code}
          code={airport.icao_code}
          label={airport.label}
          lat={airport.lat}
          lon={airport.lon}
        />
      ))}
    </MapContainer>
  ));
};

export default AirportMap;
