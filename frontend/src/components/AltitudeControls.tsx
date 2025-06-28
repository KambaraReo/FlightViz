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
    <div className="fixed bottom-4 right-8 bg-black bg-opacity-80 p-4 m-2 rounded border border-green-500 text-green-400 font-mono text-sm z-[999] shadow-lg">
      <button
        onClick={() => setColorByAltitude(!colorByAltitude)}
        className={`mb-3 px-3 py-1 w-48 rounded border text-sm transition hover:border-green-300 focus:outline-none ${
          colorByAltitude
            ? 'bg-green-600 border-green-700 text-black'
            : 'bg-black border-green-500 text-green-400 hover:bg-green-500 hover:text-black'
        }`}
      >
        {colorByAltitude ? 'Altitude Color: ON' : 'Altitude Color: OFF'}
      </button>

      {colorByAltitude && (
        <div>
          <h4 className="mb-2 font-bold text-green-300">Altitude Legend</h4>
          {levels.map(({ color, label }) => (
            <div key={label} className="flex items-center gap-2 mb-1">
              <div style={{ backgroundColor: color, width: 20, height: 10 }} />
              <span>{label}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default AltitudeControls;
