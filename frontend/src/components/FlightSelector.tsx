import { useEffect, useState } from 'react';
import { fetchFlightIds } from '../utils/api/tracks';

type FlightSelectorProps = {
  flightId: string;
  setFlightId: (flightId: string) => void;
};

const FlightSelector = ({ flightId, setFlightId }: FlightSelectorProps) => {
  const [flightIds, setFlightIds] = useState<string[]>([]);

  useEffect(() => {
    fetchFlightIds().then(setFlightIds);  // fetchFlightIds().then(data => setFlightIds(data))と同義;
  }, []);

  return (
    <div className="bg-black p-4 rounded shadow w-fit z-[1000] mb-0.5 ml-auto border border-gray-700 font-mono text-white">
      <label htmlFor="flight-select" className="mr-2 text-green-400 text-sm">
        Select Flight:
      </label>
      <select
        id="flight-select"
        value={flightId}
        onChange={(e) => setFlightId(e.target.value)}
        className="bg-gray-900 text-white border border-gray-600 rounded px-3 py-1 text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
      >
        {flightIds.map((flightId) => (
          <option value={flightId}>{flightId}</option>
        ))}
      </select>
    </div>
  );
};

export default FlightSelector;
