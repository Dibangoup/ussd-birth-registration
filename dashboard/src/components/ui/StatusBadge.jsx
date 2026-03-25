import "./StatusBadge.css";

const StatusBadge = ({ status }) => {
  const map = {
    "Enregistrée": "green",
    "Rejetée":     "red",
    "En attente":  "gray",
  };
  const color = map[status] || "gray";

  return (
    <span className={`badge badge--${color}`}>{status}</span>
  );
};

export default StatusBadge;