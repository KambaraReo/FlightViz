import AnimationSlider from "./AnimationSlider";

type PlaybackControlsProps = {
  isPlaying: boolean;
  setIsPlaying: (playing: boolean) => void;
  animationIndex: number;
  setAnimationIndex: (index: number) => void;
  speed: number;
  setSpeed: (speed: number) => void;
  max: number;
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
}: PlaybackControlsProps) => {
  return (
    <div className="flex flex-col gap-3 p-4 border-b bg-black text-green-400 font-mono border-t border-green-700 shadow-inner">
      <div className="flex items-center gap-4 bg-black text-green-400 font-mono border-green-700 shadow-inner">
        {isPlaying ? (
          <button
            onClick={() => setIsPlaying(false)}
            className="px-3 py-1 w-24 text-center bg-black border border-green-500 rounded hover:bg-green-500 hover:text-black hover:border-green-300 focus:outline-none transition"
          >
            ⏸ Pause
          </button>
        ) : (
          <button
            onClick={() => setIsPlaying(true)}
            className="px-3 py-1 w-24 text-center bg-black border border-green-500 rounded hover:bg-green-500 hover:text-black hover:border-green-300 focus:outline-none transition"
          >
            ▶ Play
          </button>
        )}
        <button
          onClick={() => {
            setIsPlaying(false);
            setAnimationIndex(0);
          }}
          className="px-3 py-1 w-24 text-center bg-black border border-green-500 rounded hover:bg-green-500 hover:text-black hover:border-green-300 focus:outline-none transition"
        >
          ⇄ Reset
        </button>

        <label className="flex items-center gap-2 ml-4">
          Speed:
          <select
            value={speed}
            onChange={(e) => setSpeed(Number(e.target.value))}
            className="bg-black border border-green-500 text-green-400 px-2 py-1 rounded focus:outline-none focus:ring-1 focus:ring-green-400"
          >
            {speedOptions.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </label>
      </div>

      <AnimationSlider
        animationIndex={animationIndex}
        setAnimationIndex={setAnimationIndex}
        max={max}
      />
    </div>
  );
};

export default PlaybackControls;
