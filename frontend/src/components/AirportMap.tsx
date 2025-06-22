import { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Polyline, Marker} from 'react-leaflet';
import AirportMarker from './AirportMarker';
import AnimationSlider from './AnimationSlider';
import { fetchAirports } from '../utils/api/airports';
import { fetchOneDayTrack, type TrackPoint } from '../utils/api/tracks';
import L from "leaflet";

import type { Airport } from '../utils/api/airports';

type AirportMapProps = {
  flightId: string;
};

const radarIcon = L.divIcon({
  html: `<div style="
    width: 10px;
    height: 10px;
    border: 2px solid yellow;
    background-color: transparent;
    box-sizing: border-box;
    border-radius: 0;
  "></div>`,
  className: '',
  iconSize: [10, 10],
});

const AirportMap = ({ flightId }: AirportMapProps) => {
  const [airports, setAirports] = useState<Airport[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const status = 1;
  const [track, setTrack] = useState<TrackPoint[]>([]);
  const [animationIndex, setAnimationIndex] = useState<number>(0);
  const [isPlaying, setIsPlaying] = useState<boolean>(false);

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
        setAnimationIndex(0);
      } catch (err) {
        console.error("データの取得に失敗しました", err);
        setError("データの取得に失敗しました");
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [flightId]);

  useEffect(() => {
    if (!isPlaying || track.length === 0) return;

    const interval = setInterval(() => {
      setAnimationIndex((prevIndex) => {
        if (prevIndex < track.length - 1) {
          return prevIndex + 1;
        } else {
          setIsPlaying(false);
          clearInterval(interval);
          return prevIndex;
        }
      });
    }, 500);

    return () => clearInterval(interval);
  }, [isPlaying, track]);

  return loading ? (
    <p>Loading...</p>
  ) : ( error ? (
    <p>{error}</p>
  ): (
    <>
      <div className="mb-2 space-x-2">
        <button
          onClick={() => {
            setAnimationIndex(0);
            setIsPlaying(true);
          }}
          className="bg-blue-500 text-white px-3 py-1 rounded"
        >
          Play
        </button>
        <button
          onClick={() => setIsPlaying(false)}
          className="bg-gray-500 text-white px-3 py-1 rounded"
        >
          Pause
        </button>
      </div>

      <AnimationSlider
        animationIndex={animationIndex}
        setAnimationIndex={setAnimationIndex}
        max={track.length > 0 ? track.length - 1 : 0}
      />

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
          <>
            {/* <Polyline
              positions={track.map((point) => [point.lat, point.lon])}
              pathOptions={{
                color: '#39FF14',
                weight: 1,
                opacity: 0.7,
              }}
            /> */}

            {animationIndex > 0 && (
              <Polyline
                positions={track.slice(0, animationIndex + 1).map(p => [p.lat, p.lon])}
                color="yellow"
                weight={2}
                opacity={0.8}
              />
            )}

            {/* {animationIndex < track.length && (
              <Marker
                position={[
                  track[animationIndex].lat,
                  track[animationIndex].lon,
                ]}
                icon={radarIcon}
              />
            )} */}
            {track.length > 0 && (
              <Marker
                position={[track[animationIndex].lat, track[animationIndex].lon]}
                icon={radarIcon}
              />
            )}
          </>
        )}
      </MapContainer>
    </>
  ));
};

export default AirportMap;
