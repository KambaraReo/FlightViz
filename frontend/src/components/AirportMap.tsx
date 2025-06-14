import { useEffect, useState } from "react";
import { MapContainer, TileLayer, Polyline } from 'react-leaflet';
import AirportMarker from './AirportMarker';
import { fetchAirports } from '../utils/api/airports';
import type { Airport } from '../utils/api/airports';
import { fetchOneDayTrack, type TrackPoint } from '../utils/api/tracks';

const AirportMap = () => {
  const [airports, setAirports] = useState<Airport[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const status = 1;
  const [flightId, setFlightId] = useState<string>('AP00119');
  const [track, setTrack] = useState<TrackPoint[]>([]);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const [airportData, trackData] = await Promise.all([
          fetchAirports(status),
          fetchOneDayTrack(flightId)
        ]);
        setAirports(airportData);
        setTrack(trackData);
      } catch (err) {
        console.error("データの取得に失敗しました", err);
        setError("データの取得に失敗しました");
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [flightId]);

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
      {track.length > 0 && (
        <Polyline
          positions={track.map((point) => [point.lat, point.lon])}
          pathOptions={{
            color: '#39FF14',
            weight: 1,
            opacity: 0.7,
          }}
        />
      )}
    </MapContainer>
  ));
};

export default AirportMap;
