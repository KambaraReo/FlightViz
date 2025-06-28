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
    <div className="bg-black p-4 w-full text-left mx-auto rounded shadow z-[1000] border border-gray-700 font-mono text-white">
      <label htmlFor="flight-select" className="mr-2 text-green-400 text-sm">
        Flight:
      </label>
      <select
        id="flight-select"
        value={flightId}
        onChange={(e) => setFlightId(e.target.value)}
        className="bg-gray-900 text-green-400 border border-green-500 rounded px-3 py-1 text-sm focus:ring-1 focus:ring-green-400 focus:outline-none"
      >
        {flightIds.map((flightId) => (
          <option key={flightId} value={flightId}>{flightId}</option>
        ))}
      </select>
    </div>
  );
};

export default FlightSelector;
