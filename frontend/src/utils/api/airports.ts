import { API_BASE_URL } from "./config";

type Airport = {
  country_code: string;
  icao_code: string;
  label: string;
  lat: number;
  lon: number;
};

const fetchAirports = async (status?: number): Promise<Airport[]> => {
  try {
    const query = status !== undefined ? `?status=${status}` : "";
    const response = await fetch(`${API_BASE_URL}/v1/airports${query}`, {
      headers: {
        Accept: "application/json",
      },
    });

    if (!response.ok) {
      throw new Error("Failed to fetch airports");
    }

    const data: Airport[] = await response.json();
    return data;
  } catch (error) {
    console.error("Error fetching airports:", error);
    return [];
  }
};

export type { Airport };
export { fetchAirports };
