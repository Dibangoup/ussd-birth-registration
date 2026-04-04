import { useState, useEffect } from "react";
import axios from "axios";
import "./Calendar.css";

const Calendar = ({ period }) => {
  const [data, setData] = useState({ validation_rate: 0, total: 0 });

  useEffect(() => {
    axios.get(`http://localhost:8000/api/dashboard/calendar?period=${period}`)
      .then((res) => setData(res.data))
      .catch((err) => console.error("Erreur API calendar:", err));
  }, [period]);

  // Dates dynamiques centrées sur aujourd'hui
  const daysMap = ["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"];
  const today = new Date();
  const dates = [];
  const dayNames = [];
  
  for (let i = -2; i <= 2; i++) {
    const d = new Date();
    d.setDate(today.getDate() + i);
    dates.push(d.getDate());
    dayNames.push(daysMap[d.getDay()]);
  }

  const currentMonthName = today.toLocaleDateString("fr-FR", { month: "long", year: "numeric" });
  
  // Variables pour le graphique donut
  const strokeDasharray = `${data.validation_rate} ${100 - data.validation_rate}`;

  return (
    <div className="calendar-card">
      <div className="calendar-header">
        <button className="cal-nav">‹</button>
        <span className="cal-month" style={{textTransform: 'capitalize'}}>{currentMonthName}</span>
        <button className="cal-nav">›</button>
      </div>

      <div className="calendar-grid">
        {dayNames.map((d, i) => (
          <div key={i} className="cal-col">
            <span className="cal-day-name">{d}</span>
            <span className={`cal-date ${i === 2 ? "cal-date--today" : ""}`}>
              {dates[i]}
            </span>
          </div>
        ))}
      </div>

      <div className="calendar-stat">
        <div>
          <p className="cal-stat-label">Taux de validation</p>
          <p className="cal-stat-trend">Sur {data.total} déclaration(s)</p>
        </div>
        <div className="cal-donut">
          <svg viewBox="0 0 40 40" width="48" height="48">
            <circle cx="20" cy="20" r="16" fill="none" stroke="#f0f0f0" strokeWidth="4"/>
            <circle cx="20" cy="20" r="16" fill="none" stroke="#E84435" strokeWidth="4"
              strokeDasharray={strokeDasharray} strokeLinecap="round"
              transform="rotate(-90 20 20)"/>
            <text x="20" y="20" textAnchor="middle" dominantBaseline="central"
              fontSize="8" fontWeight="700" fill="#1a1a1a">{data.validation_rate}%</text>
          </svg>
        </div>
      </div>
    </div>
  );
};

export default Calendar;