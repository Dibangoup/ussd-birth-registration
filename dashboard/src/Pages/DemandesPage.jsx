import { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar/Sidebar";
import StatusBadge from "../components/ui/StatusBadge";
import "./PageStyles.css";

const DemandesPage = () => {
  const [demandes, setDemandes] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    axios.get("http://localhost:8000/api/demandes")
      .then((res) => { setDemandes(res.data); setLoading(false); })
      .catch((err) => { console.error(err); setLoading(false); });
  }, []);

  const updateStatut = (id, newStatut) => {
    axios.patch(`http://localhost:8000/api/demandes/${id}`, { statut: newStatut })
      .then(() => {
        setDemandes(prev => prev.map(d => d.id === id ? { ...d, statut: newStatut === "valide" ? "Enregistrée" : "Rejetée" } : d));
      })
      .catch((err) => console.error("Erreur:", err));
  };

  return (
    <div className="layout">
      <Sidebar />
      <main className="main-content">
        <div className="page-header">
          <h1 className="page-title">Demandes</h1>
          <span className="page-subtitle">Validez ou rejetez les déclarations en attente</span>
        </div>

        <div className="page-table-card">
          {loading ? (
            <p className="empty-msg">Chargement...</p>
          ) : demandes.length === 0 ? (
            <p className="empty-msg">Aucune demande en attente.</p>
          ) : (
            <table className="page-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Enfant</th>
                  <th>Sexe</th>
                  <th>Date</th>
                  <th>Déclarant (Tél.)</th>
                  <th>Statut</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {demandes.map((d, i) => (
                  <tr key={d.id || i}>
                    <td>{i + 1}</td>
                    <td className="cell-bold">{d.enfant}</td>
                    <td>{d.sexe}</td>
                    <td>{d.date}</td>
                    <td>{d.telephone}</td>
                    <td><StatusBadge status={d.statut} /></td>
                    <td className="action-btns">
                      {d.statut === "En attente" && (
                        <>
                          <button className="btn-validate" onClick={() => updateStatut(d.id, "valide")}>✓ Valider</button>
                          <button className="btn-reject" onClick={() => updateStatut(d.id, "rejete")}>✗ Rejeter</button>
                        </>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </main>
    </div>
  );
};

export default DemandesPage;
