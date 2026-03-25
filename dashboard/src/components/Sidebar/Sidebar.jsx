import { useLocation, useNavigate } from "react-router-dom";
import {
  MdDashboard, MdAssignment, MdPeople,
  MdBarChart, MdLocationOn, MdInbox,
  MdSettings, MdHelp, MdLogout
} from "react-icons/md";
import "./Sidebar.css";

const navItems = [
  { icon: <MdDashboard />, label: "Tableau de bord", path: "/" },
  { icon: <MdAssignment />, label: "Déclarations enregistrée(s)", path: "/declarations" },
  { icon: <MdPeople />, label: "Parents / Déclarants", path: "/parents" },
  { icon: <MdBarChart />, label: "Statistiques", path: "/statistiques" },
  { icon: <MdLocationOn />, label: "Lieu de naissance", path: "/lieux" },
  { icon: <MdInbox />, label: "Demandes", path: "/demandes" },
];

const bottomItems = [
  { icon: <MdSettings />, label: "Paramètres" },
  { icon: <MdHelp />, label: "Aide" },
  { icon: <MdLogout />, label: "Déconnexion" },
];

const Sidebar = () => {
  const location = useLocation();
  const navigate = useNavigate();

  return (
    <aside className="sidebar">
      <div className="sidebar-logo" onClick={() => navigate("/")} style={{cursor: "pointer"}}>
        <div className="logo-icon">N+</div>
        <span className="logo-text">Naissance+</span>
      </div>

      <nav className="sidebar-nav">
        {navItems.map((item, i) => (
          <div
            key={i}
            className={`nav-item ${location.pathname === item.path ? "active" : ""}`}
            onClick={() => navigate(item.path)}
            style={{cursor: "pointer"}}
          >
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
          <div key={i} className="nav-item" style={{cursor: "pointer"}}>
            <span className="nav-icon">{item.icon}</span>
            <span className="nav-label">{item.label}</span>
          </div>
        ))}
      </nav>
    </aside>
  );
};

export default Sidebar;