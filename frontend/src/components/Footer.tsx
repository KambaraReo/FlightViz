const Footer = () => {
  return (
  <footer className="bg-black text-green-400 text-center text-xs py-3 border-t border-green-700 font-mono tracking-wide">
    © {new Date().getFullYear()} Flight-Viz. Created by Reo Kambara. All rights reserved.
  </footer>
  );
};

export default Footer;
