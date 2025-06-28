type AltitudeControlsProps = {
  colorByAltitude: boolean;
  setColorByAltitude: (value: boolean) => void;
};

const AltitudeControls = ({ colorByAltitude, setColorByAltitude }: AltitudeControlsProps) => {
  const levels = [
    { color: '#FF4500', label: '≤ 3000ft' },
    { color: '#FFA500', label: '3001 ~ 18000ft' },
    { color: '#FFFF00', label: '18001 ~ 29000ft' },
    { color: '#00FF00', label: '29001 ~ 41000ft' },
    { color: '#00BFFF', label: '> 41001ft' },
  ];

  return (
    <div className="bg-black bg-opacity-80 p-4 w-full mx-auto text-left rounded border border-gray-700 text-green-400 font-mono text-sm z-[999] shadow-lg">
      <span className="mr-2">Altitude:</span>
      <button
        onClick={() => setColorByAltitude(!colorByAltitude)}
        className={`px-3 py-1 w-14 rounded border text-sm transition hover:border-green-300 focus:outline-none ${
          colorByAltitude
            ? 'bg-green-600 border-green-700 text-black'
            : 'bg-black border-green-500 text-green-400 hover:bg-green-500 hover:text-black'
        }`}
      >
        {colorByAltitude ? 'ON' : 'OFF'}
      </button>

      {colorByAltitude && (
        <div className="mt-4 px-4 py-2 bg-gray-800 rounded">
          <h4 className="mb-2 pb-1 text-center text-green-300 border-b border-gray-600">Altitude Legend</h4>
          <div className="mx-auto">
            {levels.map(({ color, label }) => (
              <div key={label} className="flex items-center gap-2 mb-1">
                <div style={{ backgroundColor: color, width: 20, height: 10 }} />
                <span>{label}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default AltitudeControls;
