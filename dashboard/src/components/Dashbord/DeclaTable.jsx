import { useState, useEffect } from "react";
import axios from "axios";
import StatusBadge from "../ui/StatusBadge";
import "./DeclaTable.css";

const POLL_INTERVAL = 10000;

const DeclaTable = ({ period, search = "" }) => {
  const [declarations, setDeclarations] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchDeclarations = () => {
    axios.get(`http://localhost:8000/api/dashboard/declarations?period=${period}`)
      .then((res) => {
        setDeclarations(res.data);
        setLoading(false);
      })
      .catch((err) => {
        console.error("Erreur API:", err);
        setLoading(false);
      });
  };

  useEffect(() => {
    fetchDeclarations();
    const interval = setInterval(fetchDeclarations, POLL_INTERVAL);
    return () => clearInterval(interval);
  }, [period]);

  // Filtrage client-side par recherche
  const filtered = search.trim() === "" 
    ? declarations 
    : declarations.filter(d => 
        (d.enfant || "").toLowerCase().includes(search.toLowerCase()) ||
        (d.pere || "").toLowerCase().includes(search.toLowerCase()) ||
        (d.mere || "").toLowerCase().includes(search.toLowerCase()) ||
        (d.localite || "").toLowerCase().includes(search.toLowerCase())
      );

  return (
    <div className="decla-table-card">
      <div className="decla-table-header">
        <h3 className="decla-table-title">Déclarations récentes ({filtered.length})</h3>
        <div className="decla-table-actions">
          <button className="icon-btn" onClick={fetchDeclarations} title="Rafraîchir">↻</button>
          <button className="icon-btn">↗</button>
        </div>
      </div>

      <div className="table-wrapper">
        <table className="decla-table">
          <thead>
            <tr>
              <th>Localité</th>
              <th>Nom du père</th>
              <th>Nom de la mère</th>
              <th>Heure</th>
              <th>Date de naissance</th>
              <th>Nom de l'enfant</th>
              <th>Sexe de l'enfant</th>
              <th>Statut de la demande</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan="8" style={{textAlign: "center", padding: "20px"}}>Chargement des données...</td></tr>
            ) : filtered.length === 0 ? (
              <tr><td colSpan="8" style={{textAlign: "center", padding: "20px"}}>Aucune déclaration trouvée dans la base de données.</td></tr>
            ) : (
              filtered.map((d) => (
                <tr key={d.id}>
                  <td>
                    <span className="row-num">{d.id}</span>
                    {d.localite}
                  </td>
                  <td>{d.pere}</td>
                  <td>{d.mere}</td>
                  <td>{d.heure}</td>
                  <td>{d.date}</td>
                  <td>{d.enfant}</td>
                  <td>{d.sexe}</td>
                  <td><StatusBadge status={d.statut} /></td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default DeclaTable;