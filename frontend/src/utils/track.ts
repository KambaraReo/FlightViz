const getColorByAltitude = (altitude: number): string => {
  if (altitude <= 3000) return '#FF4500';
  if (altitude <= 18000) return '#FFA500';
  if (altitude <= 29000) return '#FFFF00';
  if (altitude <= 41000) return '#00FF00';
  return '#00BFFF';
};

export { getColorByAltitude }
