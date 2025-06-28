import { useState } from 'react';

type TimestampDisplayProps =
  | { timestamp: string | undefined; range?: undefined }
  | { timestamp?: undefined; range: { start: string | undefined; end: string | undefined}; };

const TimestampDisplay = ({ timestamp, range }: TimestampDisplayProps) => {
  const [isUTC, setIsUTC] = useState(false);
  const label = isUTC ? "UTC" : "JST";

  const format = (timestamp: string | undefined) => {
    if (!timestamp) return `N/A ${label}`;

    const date = new Date(timestamp);
    const pad = (n: number) => String(n).padStart(2, "0");
    const getFormatted = (d: Date) =>
      `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;

    return isUTC
      ? date.toISOString().replace("T", " ").slice(0, 19) + " UTC"
      : `${getFormatted(new Date(date.toLocaleString("ja-JP", { timeZone: "Asia/Tokyo" })))} JST`;
  };

  let displayText = "";
  if (range) {
    const { start, end } = range;
    if (!start && !end) {
      displayText = `N/A ${label}`;
    } else {
      displayText = `${format(start)} ~ ${format(end)}`;
    }
  } else {
    displayText = format(timestamp);
  }

  return (
    <div className="flex items-center gap-4 p-4 font-mono text-green-400 bg-black text-sm">
      <button
        onClick={() => setIsUTC((prev) => !prev)}
        className="px-2 py-1 text-center border rounded bg-black border-green-500 text-green-400 hover:bg-green-500 hover:text-black hover:border-green-300 focus:outline-none"
      >
        Switch to {isUTC ? "JST" : "UTC"}
      </button>
      {range ? (
        <>
          <span className="block md:hidden text-center">
            {format(range.start)}<br />~<br />{format(range.end)}
          </span>
          <span className="hidden md:inline">
            <span>{displayText}</span>
          </span>
        </>
      ) : (
        <span>{displayText}</span>
      )}
    </div>
  );
};

export default TimestampDisplay;
