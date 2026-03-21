import {
  MdDashboard, MdAssignment, MdPeople,
  MdBarChart, MdLocationOn, MdInbox,
  MdSettings, MdHelp, MdLogout
} from "react-icons/md";
import "./Sidebar.css";

const navItems = [
  { icon: <MdDashboard />, label: "Tableau de bord", active: true },
  { icon: <MdAssignment />, label: "Déclarations enregistrée(s)", active: false },
  { icon: <MdPeople />, label: "Parents / Déclarants", active: false },
  { icon: <MdBarChart />, label: "Statistiques", active: false },
  { icon: <MdLocationOn />, label: "Lieu de naissance", active: false },
  { icon: <MdInbox />, label: "Demandes", active: false },
];

const bottomItems = [
  { icon: <MdSettings />, label: "Paramètres" },
  { icon: <MdHelp />, label: "Aide" },
  { icon: <MdLogout />, label: "Déconnexion" },
];

const Sidebar = () => {
  return (
    <aside className="sidebar">
      <div className="sidebar-logo">
        <div className="logo-icon">N+</div>
        <span className="logo-text">Naissance+</span>
      </div>

      <nav className="sidebar-nav">
        {navItems.map((item, i) => (
          <div key={i} className={`nav-item ${item.active ? "active" : ""}`}>
            <span className="nav-icon">{item.icon}</span>
            <span className="nav-label">{item.label}</span>
          </div>
        ))}
      </nav>

      <div className="upgrade-card">
        <p className="upgrade-title">Passer à pro</p>
        <p className="upgrade-desc">
          Accédez à des fonctionnalités et à du contenu supplémentaires.
        </p>
        <button className="upgrade-btn">Améliorer</button>
      </div>

      <nav className="sidebar-bottom">
        {bottomItems.map((item, i) => (
          <div key={i} className="nav-item">
            <span className="nav-icon">{item.icon}</span>
            <span className="nav-label">{item.label}</span>
          </div>
        ))}
      </nav>
    </aside>
  );
};

export default Sidebar;