import logo from '../assets/flight-viz-logo.svg'

const Header = () => {
  return (
    <header className="bg-black border-b border-green-500 text-green-400 font-mono flex justify-between items-center shadow-md tracking-wider">
      <img src={logo} alt="Flight-Viz" width="300px"/>
    </header>
  );
};

export default Header;
