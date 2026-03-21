import {
  LineChart, Line, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, LabelList
} from "recharts";
import "./BirthChart.css";

const data = [
  { jour: "Mon", naissances: 200, label: "18\n6" },
  { jour: "Mar", naissances: 310, label: "30\n5" },
  { jour: "Mer", naissances: 240, label: "25\n9" },
  { jour: "Jeu", naissances: 150, label: "3" },
  { jour: "Ven", naissances: 220, label: "20\n9" },
  { jour: "Sam", naissances: 300, label: "21\n4" },
  { jour: "Dim", naissances: 260, label: "180" },
];

const CustomLabel = ({ x, y, value }) => (
  <text x={x} y={y - 10} fill="#999" fontSize={10} textAnchor="middle">
    {value}
  </text>
);

const BirthChart = () => {
  return (
    <div className="birth-chart-card">
      <h3 className="birth-chart-title">Traffic des naissances</h3>
      <ResponsiveContainer width="100%" height={200}>
        <LineChart data={data} margin={{ top: 20, right: 20, left: 0, bottom: 0 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
          <XAxis dataKey="jour" tick={{ fontSize: 11, fill: "#999" }} axisLine={false} tickLine={false} />
          <YAxis tick={{ fontSize: 11, fill: "#999" }} axisLine={false} tickLine={false} />
          <Tooltip contentStyle={{ borderRadius: 8, border: "1px solid #eee", fontSize: 12 }} />
          <Line
            type="monotone"
            dataKey="naissances"
            stroke="#7b68ee"
            strokeWidth={2}
            dot={{ r: 4, fill: "#7b68ee" }}
            strokeDasharray="5 5"
          >
            <LabelList dataKey="label" content={<CustomLabel />} />
          </Line>
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
};

export default BirthChart;