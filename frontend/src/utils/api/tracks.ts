type TrackPoint = {
  timestamp: string;
  flight_id: string;
  lat: number;
  lon: number;
  alt: number;
  aircraft_type: string;
};

const fetchOneDayTrack = async (flightId: string): Promise<TrackPoint[]> => {
  try {
    const response = await fetch(`/api/v1/flights/${flightId}/track`, {
      headers: {
        Accept: 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`Failed to fetch ${flightId} track`);
    }

    const data: TrackPoint[] = await response.json();
    return data;
  } catch (error) {
    console.error(`Error fetching track:`, error);
    return [];
  }
};

const fetchFlightIds = async (): Promise<string[]> => {
  try {
    const response = await fetch('/api/v1/flights', {
      headers: {
        Accept: 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error('Failed to fetch flight IDs');
    }

    const data: string[] = await response.json();
    return data;
  } catch (error) {
    console.error('Error fetching flight Ids:', error);
    return [];
  }
};

const fetchAvailableDates = async (): Promise<string[]> => {
  try {
    const response = await fetch('/api/v1/flights/available_dates', {
      headers: {
        Accept: 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error('Failed to fetch available dates');
    }

    const data: string[] = await response.json();
    return data;
  } catch (error) {
    console.error('Error fetching available dates:', error);
    return [];
  }
};

export type { TrackPoint }
export { fetchOneDayTrack, fetchFlightIds, fetchAvailableDates }
