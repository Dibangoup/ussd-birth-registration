const navItems = [
  { icon: "⊞", label: "Tableau de bord", active: true },
  { icon: "👤", label: "Déclarations enregistrée(s)", active: false },
  { icon: "👥", label: "Parents / Déclarants", active: false },
  { icon: "📊", label: "Statistiques", active: false },
  { icon: "📍", label: "Lieu de naissance", active: false },
  { icon: "📋", label: "Demandes", active: false },
];

const NavMenu = () => {
  return (
    <nav>
      {navItems.map((item, i) => (
        <div key={i} className={`nav-item ${item.active ? "active" : ""}`}>
          <span className="nav-icon">{item.icon}</span>
          <span className="nav-label">{item.label}</span>
        </div>
      ))}
    </nav>
  );
};

export default NavMenu;