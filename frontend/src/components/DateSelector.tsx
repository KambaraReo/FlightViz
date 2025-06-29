import { useEffect, useState } from 'react';
import { fetchAvailableDates } from '../utils/api/tracks';

type DateSelectorProps = {
  selectedDate: string;
  setSelectedDate: (date: string) => void;
};

const DateSelector = ({
  selectedDate,
  setSelectedDate
}: DateSelectorProps) => {
  const [dates, setDates] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(true);
    fetchAvailableDates()
      .then(setDates)
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="bg-black p-4 w-full text-left mx-auto rounded shadow z-[1000] border border-gray-700 font-mono text-white">
      <label htmlFor="date-select" className="mr-2 text-green-400 text-sm">
        Date:
      </label>
      <select
        id="date-select"
        value={selectedDate}
        onChange={(e) => setSelectedDate(e.target.value)}
        className="bg-gray-900 text-green-400 border border-green-500 rounded px-3 py-1 text-sm focus:ring-1 focus:ring-green-400 focus:outline-none disabled:opacity-50"
        disabled={loading}
      >
        <option value="" className="text-center">
          {loading ? 'Loading...' : 'Select'}
        </option>
        {!loading &&
          dates.map((date) => (
            <option key={date} value={date}>
              {date}
            </option>
          ))}
      </select>
    </div>
  );
};

export default DateSelector;
