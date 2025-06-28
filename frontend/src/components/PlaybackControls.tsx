import AnimationSlider from './AnimationSlider';

type PlaybackControlsProps = {
  isPlaying: boolean;
  setIsPlaying: (playing: boolean) => void;
  animationIndex: number;
  setAnimationIndex: (index: number) => void;
  speed: number;
  setSpeed: (speed: number) => void;
  max: number;
  showFullTrack: boolean;
  setShowFullTrack: (value: boolean) => void;
  disabled: boolean
};

const speedOptions = [
  { label: "0.5x", value: 1000 },
  { label: "1x", value: 500 },
  { label: "1.5x", value: 333 },
  { label: "2x", value: 250 },
  { label: "4x", value: 125 },
];

const PlaybackControls = ({
  isPlaying,
  setIsPlaying,
  animationIndex,
  setAnimationIndex,
  speed,
  setSpeed,
  max,
  showFullTrack,
  setShowFullTrack,
  disabled,
}: PlaybackControlsProps) => {
  return (
    <div className="flex flex-col gap-3 p-4 border-b bg-black text-green-400 font-mono border-green-700 shadow-inner">
      <div className="flex flex-wrap-reverse items-center gap-4 justify-between bg-black text-green-400 font-mono border-green-700 shadow-inner">
        <div className="flex flex-wrap items-center gap-2">
          {isPlaying ? (
            <button
              onClick={() => setIsPlaying(false)}
              disabled={disabled}
              className={`
                px-3 py-1 w-24 text-center border rounded transition
                bg-black border-green-500 text-green-400
                hover:bg-green-500 hover:text-black hover:border-green-300 focus:outline-none
                disabled:bg-gray-800 disabled:text-gray-400 disabled:border-gray-600 disabled:cursor-not-allowed
              `}
            >
              ⏸ Pause
            </button>
          ) : (
            <button
              onClick={() => setIsPlaying(true)}
              disabled={disabled}
              className={`
                px-3 py-1 w-24 text-center border rounded transition
                bg-black border-green-500 text-green-400
                hover:bg-green-500 hover:text-black hover:border-green-300 focus:outline-none
                disabled:bg-gray-800 disabled:text-gray-400 disabled:border-gray-600 disabled:cursor-not-allowed
              `}
            >
              ▶ Play
            </button>
          )}
          <button
            onClick={() => {
              setIsPlaying(false);
              setAnimationIndex(0);
            }}
            disabled={disabled}
            className={`
              px-3 py-1 w-24 text-center border rounded transition
              bg-black border-green-500 text-green-400
              hover:bg-green-500 hover:text-black hover:border-green-300 focus:outline-none
              disabled:bg-gray-800 disabled:text-gray-400 disabled:border-gray-600 disabled:cursor-not-allowed
            `}
          >
            ⇄ Reset
          </button>

          <label className="flex items-center gap-2">
            <span className={disabled ? 'text-gray-400' : 'text-green-400'}>
              Speed:
            </span>
            <select
              value={speed}
              onChange={(e) => setSpeed(Number(e.target.value))}
              disabled={disabled}
              className={`
                px-2 py-1 border rounded
                bg-black border-green-500 text-green-400 focus:ring-1 focus:ring-green-400 focus:outline-none
                disabled:bg-gray-800 disabled:text-gray-400 disabled:border-gray-600 disabled:cursor-not-allowed
              `}
            >
              {speedOptions.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </label>
        </div>

        <div>
          <span className="mr-2">Mode:</span>
          <button
            onClick={() => setShowFullTrack(!showFullTrack)}
            className="px-3 py-1 w-32 bg-black border border-green-500 rounded hover:bg-green-500 hover:text-black hover:border-green-300 focus:outline-none transition"
          >
            {showFullTrack ? 'Full Track' : 'Animation'}
          </button>
        </div>
      </div>

      <AnimationSlider
        animationIndex={animationIndex}
        setAnimationIndex={setAnimationIndex}
        max={max}
        disabled={showFullTrack}
      />
    </div>
  );
};

export default PlaybackControls;
