import React from 'react';

type AnimationSliderProps = {
  animationIndex: number;
  setAnimationIndex: (index: number) => void;
  max: number;
  disabled: boolean;
};

const AnimationSlider: React.FC<AnimationSliderProps> = ({
  animationIndex,
  setAnimationIndex,
  max,
  disabled,
}) => {
  return (
    <input
      type="range"
      min={0}
      max={max}
      value={animationIndex}
      onChange={(e) => setAnimationIndex(Number(e.target.value))}
      disabled={disabled}
      className="w-full h-2 appearance-none bg-[#222] rounded outline-none
                disabled:bg-gray-600 disabled:cursor-not-allowed
                [&::-webkit-slider-thumb]:appearance-none
                [&::-webkit-slider-thumb]:w-3
                [&::-webkit-slider-thumb]:h-3
              [&::-webkit-slider-thumb]:bg-lime-300
                [&::-webkit-slider-thumb]:rounded-full
                [&::-webkit-slider-thumb]:shadow-md
              [&::-moz-range-thumb]:bg-lime-300
                [&::-moz-range-thumb]:border-none
                [&::-moz-range-thumb]:width-3
                [&::-moz-range-thumb]:height-3"
    />
  );
};

export default AnimationSlider;
