import { useState, useEffect } from "react";

/* ═══════ SVG ICON COMPONENTS ═══════ */
const Icon = ({ children, size = 24, color = "currentColor", ...props }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>{children}</svg>
);

const Icons = {
  play: (p) => <Icon {...p}><polygon points="5 3 19 12 5 21 5 3" fill={p.color || "currentColor"} stroke="none" /></Icon>,
  levels: (p) => <Icon {...p}><rect x="3" y="3" width="7" height="7" rx="1.5" /><rect x="14" y="3" width="7" height="7" rx="1.5" /><rect x="3" y="14" width="7" height="7" rx="1.5" /><rect x="14" y="14" width="7" height="7" rx="1.5" /></Icon>,
  trophy: (p) => <Icon {...p}><path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6" /><path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18" /><path d="M4 22h16" /><path d="M10 22V14a2 2 0 0 1 2-2v0a2 2 0 0 1 2 2v8" /><path d="M6 2h12v7a6 6 0 0 1-12 0V2z" /></Icon>,
  settings: (p) => <Icon {...p}><circle cx="12" cy="12" r="3" /><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" /></Icon>,
  help: (p) => <Icon {...p}><circle cx="12" cy="12" r="10" /><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" /><line x1="12" y1="17" x2="12.01" y2="17" /></Icon>,
  hint: (p) => <Icon {...p}><path d="M9 18h6" /><path d="M10 22h4" /><path d="M12 2a7 7 0 0 0-4 12.7V17h8v-2.3A7 7 0 0 0 12 2z" /></Icon>,
  undo: (p) => <Icon {...p}><polyline points="1 4 1 10 7 10" /><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10" /></Icon>,
  eraser: (p) => <Icon {...p}><path d="M20 20H7L3 16l8-8 9 9-4 4" /><path d="M18 13l-1.5-1.5" /><line x1="2" y1="20" x2="22" y2="20" /></Icon>,
  pause: (p) => <Icon {...p}><rect x="6" y="4" width="4" height="16" rx="1" /><rect x="14" y="4" width="4" height="16" rx="1" /></Icon>,
  back: (p) => <Icon {...p}><polyline points="15 18 9 12 15 6" /></Icon>,
  lock: (p) => <Icon {...p}><rect x="3" y="11" width="18" height="11" rx="2" ry="2" /><path d="M7 11V7a5 5 0 0 1 10 0v4" /></Icon>,
  check: (p) => <Icon {...p}><polyline points="20 6 9 17 4 12" /></Icon>,
  star: (p) => <Icon {...p}><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" fill={p.filled ? (p.color || "#F1C40F") : "none"} stroke={p.color || "#F1C40F"} /></Icon>,
  arrowRight: (p) => <Icon {...p}><line x1="5" y1="12" x2="19" y2="12" /><polyline points="12 5 19 12 12 19" /></Icon>,
  home: (p) => <Icon {...p}><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" /><polyline points="9 22 9 12 15 12 15 22" /></Icon>,
  medal: (p) => <Icon {...p}><circle cx="12" cy="8" r="6" /><path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11" /></Icon>,
  sparkles: (p) => <Icon {...p}><path d="M12 3l1.5 4.5L18 9l-4.5 1.5L12 15l-1.5-4.5L6 9l4.5-1.5L12 3z" /><path d="M19 13l.75 2.25L22 16l-2.25.75L19 19l-.75-2.25L16 16l2.25-.75L19 13z" /></Icon>,
  palette: (p) => <Icon {...p}><circle cx="13.5" cy="6.5" r="2" /><circle cx="17.5" cy="10.5" r="2" /><circle cx="8.5" cy="7.5" r="2" /><circle cx="6.5" cy="12.5" r="2" /><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.926 0 1.648-.746 1.648-1.688 0-.437-.18-.835-.437-1.125-.29-.289-.438-.652-.438-1.125a1.64 1.64 0 0 1 1.668-1.668h1.996c3.051 0 5.555-2.503 5.555-5.554C21.965 6.012 17.461 2 12 2z" /></Icon>,
  upDown: (p) => <Icon {...p}><polyline points="12 3 12 21" /><polyline points="8 7 12 3 16 7" /><polyline points="8 17 12 21 16 17" /></Icon>,
  leftRight: (p) => <Icon {...p}><polyline points="3 12 21 12" /><polyline points="7 8 3 12 7 16" /><polyline points="17 8 21 12 17 16" /></Icon>,
  grid: (p) => <Icon {...p}><rect x="3" y="3" width="18" height="18" rx="2" /><line x1="3" y1="9" x2="21" y2="9" /><line x1="3" y1="15" x2="21" y2="15" /><line x1="9" y1="3" x2="9" y2="21" /><line x1="15" y1="3" x2="15" y2="21" /></Icon>,
  puzzle: (p) => <Icon {...p}><path d="M19.439 7.85c-.049.322.059.648.289.878l1.568 1.568c.47.47.706 1.087.706 1.704s-.235 1.233-.706 1.704l-1.611 1.611a.98.98 0 0 1-.837.276c-.47-.07-.802-.48-.968-.925a2.501 2.501 0 1 0-3.214 3.214c.446.166.855.497.925.968a.979.979 0 0 1-.276.837l-1.61 1.61a2.404 2.404 0 0 1-1.705.707 2.402 2.402 0 0 1-1.704-.706l-1.568-1.568a1.026 1.026 0 0 0-.877-.29c-.493.074-.84.504-1.02.968a2.5 2.5 0 1 1-3.237-3.237c.464-.18.894-.527.967-1.02a1.026 1.026 0 0 0-.289-.877l-1.568-1.568A2.402 2.402 0 0 1 1.998 12c0-.617.236-1.234.706-1.704L4.315 8.685a.98.98 0 0 1 .837-.276c.47.07.802.48.968.925a2.501 2.501 0 1 0 3.214-3.214c-.446-.166-.855-.497-.925-.968a.979.979 0 0 1 .276-.837l1.61-1.61a2.404 2.404 0 0 1 1.705-.707c.617 0 1.234.236 1.704.706l1.568 1.568c.23.23.556.338.877.29.493-.074.84-.504 1.02-.968a2.5 2.5 0 1 1 3.237 3.237c-.464.18-.894.527-.967 1.02z" /></Icon>,
  timer: (p) => <Icon {...p}><circle cx="12" cy="13" r="8" /><path d="M12 9v4l2 2" /><path d="M5 3L2 6" /><path d="M22 6l-3-3" /><line x1="12" y1="1" x2="12" y2="3" /><line x1="10" y1="1" x2="14" y2="1" /></Icon>,
  zap: (p) => <Icon {...p}><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" /></Icon>,
  rainbow: (p) => <Icon {...p}><path d="M22 17a10 10 0 0 0-20 0" /><path d="M6 17a6 6 0 0 1 12 0" /><path d="M10 17a2 2 0 0 1 4 0" /></Icon>,
  brain: (p) => <Icon {...p}><path d="M9.5 2A4.5 4.5 0 0 0 5 6.5C5 8.48 6.02 10.18 7.56 11.17L8 22h3V11.29A4.5 4.5 0 0 0 9.5 2z" /><path d="M14.5 2A4.5 4.5 0 0 1 19 6.5c0 1.98-1.02 3.68-2.56 4.67L16 22h-3V11.29A4.5 4.5 0 0 1 14.5 2z" /></Icon>,
  flame: (p) => <Icon {...p}><path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z" /></Icon>,
  crown: (p) => <Icon {...p}><path d="M2 17l2-9 4 4 4-8 4 8 4-4 2 9H2z" /><path d="M2 17h20v2a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2v-2z" /></Icon>,
  confetti: (p) => <Icon {...p}><path d="M5.8 11.3L2 22l10.7-3.79" /><path d="M4 3h.01" /><path d="M22 8h.01" /><path d="M15 2h.01" /><path d="M22 20h.01" /><path d="M22 2l-2.24.75a2.9 2.9 0 0 0-1.96 3.12c.1.86-.57 1.63-1.45 1.63h-.38c-.86 0-1.6.6-1.76 1.44L14 10" /><path d="M22 13l-1.34-.45" /><path d="M6 12l-1.34-.45" /></Icon>,
};

// Gradient icon wrapper for branded elements
const BrandIcon = ({ icon: IconComp, size = 24, gradient = ["#4A90D9", "#6B5CE7"] }) => (
  <div style={{ width: size, height: size, display: "flex", alignItems: "center", justifyContent: "center" }}>
    <IconComp size={size} color={gradient[0]} />
  </div>
);

/* ═══════ APP LOGO SVG ═══════ */
const AppLogo = ({ size = 100, darkMode = false }) => (
  <div style={{ width: size, height: size, borderRadius: size * 0.28, background: "linear-gradient(135deg, #FF6B6B 0%, #4A90D9 33%, #27AE60 66%, #F1C40F 100%)", boxShadow: "0 12px 32px rgba(74,144,217,0.4)", display: "flex", alignItems: "center", justifyContent: "center", position: "relative" }}>
    <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: size * 0.035, padding: size * 0.04 }}>
      {["#FF6B6B","#4A90D9","#27AE60","#F1C40F","#FFFFFF","#9B59B6","#E67E22","#FF9FF3","#00CEC9"].map((c, i) => (
        <div key={i} style={{ width: size * 0.22, height: size * 0.22, borderRadius: size * 0.06, background: i === 4 ? "rgba(255,255,255,0.9)" : `linear-gradient(145deg, ${c}ee, ${c})`, boxShadow: "0 2px 4px rgba(0,0,0,0.2)" }} />
      ))}
    </div>
  </div>
);

/* ═══════ DATA ═══════ */
const LIGHT_COLORS = [
  { name: "Red", hex: "#FF6B6B", pattern: "●" }, { name: "Blue", hex: "#4A90D9", pattern: "■" },
  { name: "Green", hex: "#27AE60", pattern: "▲" }, { name: "Yellow", hex: "#F1C40F", pattern: "◆" },
  { name: "Purple", hex: "#9B59B6", pattern: "★" }, { name: "Orange", hex: "#E67E22", pattern: "◎" },
  { name: "Pink", hex: "#FF9FF3", pattern: "♥" }, { name: "Cyan", hex: "#00CEC9", pattern: "⬡" },
  { name: "Lime", hex: "#BADC58", pattern: "✦" },
];
const DARK_COLORS = [
  { name: "Cherry", hex: "#E74C3C", pattern: "●" }, { name: "Sky", hex: "#3498DB", pattern: "■" },
  { name: "Emerald", hex: "#2ECC71", pattern: "▲" }, { name: "Gold", hex: "#F39C12", pattern: "◆" },
  { name: "Amethyst", hex: "#8E44AD", pattern: "★" }, { name: "Sunset", hex: "#D35400", pattern: "◎" },
  { name: "Rose", hex: "#FD79A8", pattern: "♥" }, { name: "Teal", hex: "#00B894", pattern: "⬡" },
  { name: "Olive", hex: "#6AB04C", pattern: "✦" },
];

const SAMPLE_4x4 = [[1,0,0,4],[0,3,1,0],[0,1,4,0],[4,0,0,2]];
const SAMPLE_6x6 = [[0,3,0,0,5,0],[5,0,1,3,0,0],[0,0,5,0,0,3],[3,0,0,5,0,0],[0,0,3,0,0,5],[0,5,0,0,3,0]];
const SAMPLE_9x9 = [[5,3,0,0,7,0,0,0,0],[6,0,0,1,9,5,0,0,0],[0,9,8,0,0,0,0,6,0],[8,0,0,0,6,0,0,0,3],[4,0,0,8,0,3,0,0,1],[7,0,0,0,2,0,0,0,6],[0,6,0,0,0,0,2,8,0],[0,0,0,4,1,9,0,0,5],[0,0,0,0,8,0,0,7,9]];
const TUTORIAL_MINI = [[1,0],[0,2]];

const screens = ["スプラッシュ","チュートリアル","ホーム","レベル選択","ゲーム (4×4)","ゲーム (6×6)","ゲーム (9×9)","クリア","実績","設定"];

export default function IroPreMockup() {
  const [currentScreen, setCurrentScreen] = useState(0);
  const [darkMode, setDarkMode] = useState(false);
  const [selectedCell, setSelectedCell] = useState(null);
  const [selectedColor, setSelectedColor] = useState(null);
  const [accessMode, setAccessMode] = useState("color");
  const [tutorialStep, setTutorialStep] = useState(0);
  const [splashPulse, setSplashPulse] = useState(true);

  useEffect(() => { const t = setInterval(() => setSplashPulse(p => !p), 1200); return () => clearInterval(t); }, []);

  const colors = darkMode ? DARK_COLORS : LIGHT_COLORS;
  const bg = darkMode ? "#0F0F1A" : "#F8F9FF";
  const cardBg = darkMode ? "#1A1A2E" : "#FFFFFF";
  const textPrimary = darkMode ? "#FFFFFF" : "#1A1A2E";
  const textSecondary = darkMode ? "#8888AA" : "#6B7280";
  const borderColor = darkMode ? "#2A2A4E" : "#E5E7EB";
  const iconColor = darkMode ? "#CCCCDD" : "#555566";

  const cellStyle3D = (color, isFixed, isSelected) => ({
    width: "100%", aspectRatio: "1", borderRadius: 10,
    display: "flex", alignItems: "center", justifyContent: "center",
    cursor: isFixed ? "default" : "pointer",
    background: color ? `linear-gradient(145deg, ${color}ee, ${color})` : darkMode ? "linear-gradient(145deg, #22223A, #1A1A2E)" : "linear-gradient(145deg, #FFFFFF, #F0F0F7)",
    boxShadow: isSelected ? `0 0 0 3px ${colors[0].hex}, 0 4px 12px rgba(0,0,0,0.3)` : color ? `0 4px 8px ${color}40, inset 0 1px 1px rgba(255,255,255,0.3)` : `0 2px 4px rgba(0,0,0,0.1), inset 0 1px 1px rgba(255,255,255,0.5)`,
    transition: "all 0.2s ease", fontSize: accessMode === "symbol" ? 14 : 11, fontWeight: 700,
    color: color ? "#FFF" : textSecondary, textShadow: color ? "0 1px 2px rgba(0,0,0,0.3)" : "none",
    border: isSelected ? "none" : `1px solid ${borderColor}22`,
  });

  const renderCell = (v, r, c) => {
    const color = v ? colors[v-1]?.hex : null;
    const key = `${r}-${c}`;
    const content = (accessMode==="symbol"||accessMode==="pattern") && v ? colors[v-1]?.pattern : "";
    return <div key={key} style={cellStyle3D(color, v!==0, selectedCell===key)} onClick={() => v===0 && setSelectedCell(key)}>{content}</div>;
  };

  const renderGrid = (puzzle, gs) => {
    const bW = gs===6?3:gs===9?3:2, bH = gs===6?2:gs===9?3:2, gap=3, bGap=6;
    return (
      <div style={{ display:"grid", gridTemplateColumns:`repeat(${gs}, 1fr)`, gap, padding:8, background:darkMode?"linear-gradient(145deg, #16162B, #0F0F1A)":"linear-gradient(145deg, #E8EBF5, #DDE0F0)", borderRadius:16, boxShadow:"0 8px 32px rgba(0,0,0,0.15), inset 0 1px 1px rgba(255,255,255,0.2)" }}>
        {puzzle.map((row,r) => row.map((v,c) => {
          const rB=(c+1)%bW===0&&c<gs-1, bB=(r+1)%bH===0&&r<gs-1;
          return <div key={`${r}-${c}`} style={{paddingRight:rB?bGap-gap:0, paddingBottom:bB?bGap-gap:0}}>{renderCell(v,r,c)}</div>;
        }))}
      </div>
    );
  };

  const Palette = ({ count }) => (
    <div style={{ display:"flex", gap:8, justifyContent:"center", flexWrap:"wrap" }}>
      {colors.slice(0,count).map((c,i) => (
        <div key={i} onClick={() => setSelectedColor(i)} style={{
          width:40, height:40, borderRadius:12,
          background:`linear-gradient(145deg, ${c.hex}ee, ${c.hex})`,
          boxShadow: selectedColor===i ? `0 0 0 3px ${cardBg}, 0 0 0 5px ${c.hex}, 0 4px 12px ${c.hex}60` : `0 3px 8px ${c.hex}40, inset 0 1px 1px rgba(255,255,255,0.3)`,
          cursor:"pointer", transition:"all 0.2s ease", transform:selectedColor===i?"scale(1.1)":"scale(1)",
          display:"flex", alignItems:"center", justifyContent:"center", fontSize:14, color:"#FFF", fontWeight:700,
        }}>{accessMode!=="color" ? c.pattern : ""}</div>
      ))}
    </div>
  );

  const ToolButton = ({ icon: IconComp, label }) => (
    <div style={{ display:"flex", flexDirection:"column", alignItems:"center", gap:4, cursor:"pointer" }}>
      <div style={{ width:44, height:44, borderRadius:14, background:darkMode?"linear-gradient(145deg, #22223A, #1A1A2E)":"linear-gradient(145deg, #FFF, #F0F0F7)", boxShadow:"0 3px 8px rgba(0,0,0,0.1), inset 0 1px 1px rgba(255,255,255,0.5)", display:"flex", alignItems:"center", justifyContent:"center" }}>
        <IconComp size={20} color={iconColor} />
      </div>
      <span style={{ fontSize:10, color:textSecondary }}>{label}</span>
    </div>
  );

  const PhoneFrame = ({ children }) => (
    <div style={{ width:320, minHeight:580, background:bg, borderRadius:36, padding:"12px 0", boxShadow:"0 20px 60px rgba(0,0,0,0.25), 0 0 0 1px rgba(0,0,0,0.08)", position:"relative", overflow:"hidden", flexShrink:0 }}>
      <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", padding:"4px 24px 8px", fontSize:12, fontWeight:600, color:textPrimary }}>
        <span>9:41</span>
        <div style={{ width:80, height:24, background:textPrimary, borderRadius:12 }} />
        <div style={{ display:"flex", gap:4, alignItems:"center" }}>
          <svg width="16" height="12" viewBox="0 0 16 12"><path d="M1 8h2v4H1zM5 5h2v7H5zM9 2h2v10H9zM13 0h2v12h-2z" fill={textPrimary} opacity="0.6" /></svg>
          <svg width="22" height="12" viewBox="0 0 22 12"><rect x="0" y="1" width="18" height="10" rx="2" stroke={textPrimary} strokeWidth="1.2" fill="none" opacity="0.6" /><rect x="2" y="3" width="12" height="6" rx="1" fill={textPrimary} opacity="0.6" /><path d="M19 4.5v3a1.5 1.5 0 0 0 0-3z" fill={textPrimary} opacity="0.6" /></svg>
        </div>
      </div>
      <div style={{ padding:"0 16px", flex:1 }}>{children}</div>
    </div>
  );

  /* ═══════ SPLASH ═══════ */
  const renderSplash = () => (
    <PhoneFrame>
      <div style={{ display:"flex", flexDirection:"column", alignItems:"center", justifyContent:"center", height:520, position:"relative" }}>
        {[{c:"#FF6B6B",s:80,t:40,l:20},{c:"#4A90D9",s:60,t:100,r:30},{c:"#27AE60",s:50,b:120,l:40},{c:"#F1C40F",s:70,b:80,r:20},{c:"#9B59B6",s:40,t:200,l:10},{c:"#E67E22",s:45,t:60,r:60}].map((o,i) => (
          <div key={i} style={{ position:"absolute", width:o.s, height:o.s, borderRadius:"50%", background:`radial-gradient(circle at 30% 30%, ${o.c}44, ${o.c}11)`, filter:"blur(8px)", top:o.t, left:o.l, right:o.r, bottom:o.b, opacity:splashPulse?0.8:0.4, transition:"opacity 1.2s ease-in-out" }} />
        ))}
        <div style={{ marginBottom:24, position:"relative", zIndex:2, boxShadow:`0 16px 48px rgba(74,144,217,0.5), 0 0 ${splashPulse?40:20}px rgba(74,144,217,${splashPulse?0.4:0.2})`, borderRadius:34, transition:"box-shadow 1.2s ease-in-out" }}>
          <AppLogo size={120} darkMode={darkMode} />
        </div>
        <h1 style={{ fontSize:36, fontWeight:800, margin:"0 0 8px", letterSpacing:-1, position:"relative", zIndex:2 }}>
          <span style={{ background:"linear-gradient(135deg, #FF6B6B, #4A90D9, #27AE60)", WebkitBackgroundClip:"text", WebkitTextFillColor:"transparent" }}>Iro</span>
          <span style={{ color:textPrimary }}>Pre</span>
        </h1>
        <p style={{ fontSize:14, color:textSecondary, margin:"0 0 48px", position:"relative", zIndex:2 }}>色で解く、新しい数独体験</p>
        <div style={{ display:"flex", gap:8, position:"relative", zIndex:2 }}>
          {[0,1,2].map(i => (<div key={i} style={{ width:8, height:8, borderRadius:"50%", background:i===(splashPulse?1:0)?colors[i].hex:`${colors[i].hex}44`, transition:"all 0.6s ease" }} />))}
        </div>
      </div>
    </PhoneFrame>
  );

  /* ═══════ TUTORIAL ═══════ */
  const tutorialSteps = [
    { title:"IroPreへようこそ！", subtitle:"色で数独を解こう", icon:<Icons.palette size={44} color="#4A90D9" />,
      content: (
        <div style={{ textAlign:"center" }}>
          <div style={{ margin:"0 auto 20px" }}><AppLogo size={90} darkMode={darkMode} /></div>
          <p style={{ fontSize:14, color:textSecondary, lineHeight:1.7, margin:0 }}>数字の代わりに<span style={{ color:colors[0].hex, fontWeight:700 }}>色</span>を使った<br/>新しい数独パズルです。<br/>誰でもかんたんに楽しめます！</p>
        </div>
      )
    },
    { title:"ルールはかんたん！", subtitle:"3つだけ覚えよう", icon:<Icons.grid size={44} color="#27AE60" />,
      content: (
        <div>
          {[{rule:"たて一列に同じ色は置けない", IconC:Icons.upDown, c:colors[0].hex}, {rule:"よこ一列に同じ色は置けない", IconC:Icons.leftRight, c:colors[1].hex}, {rule:"ブロック内に同じ色は置けない", IconC:Icons.grid, c:colors[2].hex}].map((item,i) => (
            <div key={i} style={{ display:"flex", alignItems:"center", gap:12, padding:"12px 14px", marginBottom:10, borderRadius:14, background:darkMode?"linear-gradient(145deg, #22223A, #1A1A2E)":"linear-gradient(145deg, #FFF, #F8F9FF)", boxShadow:"0 3px 8px rgba(0,0,0,0.06)" }}>
              <div style={{ width:40, height:40, borderRadius:12, background:`${item.c}18`, display:"flex", alignItems:"center", justifyContent:"center", flexShrink:0 }}>
                <item.IconC size={20} color={item.c} />
              </div>
              <span style={{ fontSize:14, fontWeight:600, color:textPrimary }}>{item.rule}</span>
            </div>
          ))}
        </div>
      )
    },
    { title:"やってみよう！", subtitle:"マスをタップして色を置こう", icon:<Icons.puzzle size={44} color="#9B59B6" />,
      content: (
        <div style={{ textAlign:"center" }}>
          <p style={{ fontSize:13, color:textSecondary, marginBottom:16 }}>空いたマスをタップ → 下のパレットから色を選ぶ</p>
          <div style={{ display:"grid", gridTemplateColumns:"repeat(2, 1fr)", gap:6, maxWidth:140, margin:"0 auto 20px", padding:10, background:darkMode?"linear-gradient(145deg, #16162B, #0F0F1A)":"linear-gradient(145deg, #E8EBF5, #DDE0F0)", borderRadius:16, boxShadow:"0 8px 24px rgba(0,0,0,0.12)" }}>
            {TUTORIAL_MINI.map((row,r) => row.map((v,c) => {
              const color = v ? colors[v-1]?.hex : null;
              return <div key={`${r}-${c}`} style={{ width:"100%", aspectRatio:"1", borderRadius:12, background:color?`linear-gradient(145deg, ${color}ee, ${color})`:darkMode?"linear-gradient(145deg, #22223A, #1A1A2E)":"linear-gradient(145deg, #FFF, #F0F0F7)", boxShadow:color?`0 4px 8px ${color}40, inset 0 1px 1px rgba(255,255,255,0.3)`:"0 2px 4px rgba(0,0,0,0.08)", display:"flex", alignItems:"center", justifyContent:"center" }}>{!color && <span style={{ color:textSecondary, fontSize:14 }}>?</span>}</div>;
            }))}
          </div>
          <div style={{ display:"flex", gap:10, justifyContent:"center" }}>
            {colors.slice(0,2).map((c,i) => (<div key={i} style={{ width:44, height:44, borderRadius:14, background:`linear-gradient(145deg, ${c.hex}ee, ${c.hex})`, boxShadow:`0 3px 8px ${c.hex}40`, cursor:"pointer" }} />))}
          </div>
        </div>
      )
    },
    { title:"困ったらヒント！", subtitle:"いつでも助けてもらえます", icon:<Icons.hint size={44} color="#F1C40F" />,
      content: (
        <div style={{ textAlign:"center" }}>
          <div style={{ display:"flex", justifyContent:"center", gap:16, marginBottom:24 }}>
            {[{IconC:Icons.hint, label:"ヒント", desc:"正解の色を表示"}, {IconC:Icons.undo, label:"戻す", desc:"操作を元に戻す"}, {IconC:Icons.eraser, label:"消す", desc:"色を消去"}].map((tool,i) => (
              <div key={i} style={{ display:"flex", flexDirection:"column", alignItems:"center", gap:6 }}>
                <div style={{ width:52, height:52, borderRadius:16, background:darkMode?"linear-gradient(145deg, #22223A, #1A1A2E)":"linear-gradient(145deg, #FFF, #F0F0F7)", boxShadow:"0 4px 12px rgba(0,0,0,0.1)", display:"flex", alignItems:"center", justifyContent:"center" }}>
                  <tool.IconC size={24} color={iconColor} />
                </div>
                <span style={{ fontSize:12, fontWeight:600, color:textPrimary }}>{tool.label}</span>
                <span style={{ fontSize:10, color:textSecondary }}>{tool.desc}</span>
              </div>
            ))}
          </div>
          <div style={{ background:`${colors[2].hex}15`, border:`1px solid ${colors[2].hex}30`, borderRadius:14, padding:"14px 16px", display:"flex", alignItems:"center", justifyContent:"center", gap:8 }}>
            <Icons.sparkles size={18} color={colors[2].hex} />
            <p style={{ fontSize:13, color:textPrimary, margin:0, fontWeight:500 }}>準備OK！さっそく始めましょう</p>
          </div>
        </div>
      )
    },
  ];

  const renderTutorial = () => {
    const step = tutorialSteps[tutorialStep];
    return (
      <PhoneFrame>
        <div style={{ paddingTop:8 }}>
          <div style={{ display:"flex", justifyContent:"center", gap:8, marginBottom:20 }}>
            {tutorialSteps.map((_,i) => (<div key={i} onClick={() => setTutorialStep(i)} style={{ width:tutorialStep===i?24:8, height:8, borderRadius:4, background:tutorialStep===i?"linear-gradient(135deg, #4A90D9, #6B5CE7)":darkMode?"#333":"#DDD", cursor:"pointer", transition:"all 0.3s ease" }} />))}
          </div>
          <div style={{ textAlign:"center", marginBottom:12 }}>{step.icon}</div>
          <h2 style={{ fontSize:22, fontWeight:800, color:textPrimary, textAlign:"center", margin:"0 0 4px" }}>{step.title}</h2>
          <p style={{ fontSize:13, color:textSecondary, textAlign:"center", margin:"0 0 24px" }}>{step.subtitle}</p>
          <div style={{ marginBottom:24 }}>{step.content}</div>
          <div style={{ display:"flex", gap:10 }}>
            {tutorialStep>0 && <div onClick={() => setTutorialStep(s => s-1)} style={{ flex:1, padding:"14px 0", textAlign:"center", borderRadius:14, background:darkMode?"#22223A":"#F0F0F7", color:textSecondary, fontSize:14, fontWeight:600, cursor:"pointer" }}>もどる</div>}
            <div onClick={() => setTutorialStep(s => Math.min(s+1, tutorialSteps.length-1))} style={{ flex:tutorialStep>0?2:1, padding:"14px 0", textAlign:"center", borderRadius:14, background:"linear-gradient(135deg, #4A90D9, #6B5CE7)", color:"#FFF", fontSize:14, fontWeight:700, cursor:"pointer", boxShadow:"0 4px 16px rgba(74,144,217,0.4)", display:"flex", alignItems:"center", justifyContent:"center", gap:6 }}>
              {tutorialStep===tutorialSteps.length-1 ? <>はじめる！ <Icons.arrowRight size={16} color="#FFF" /></> : <>つぎへ <Icons.arrowRight size={16} color="#FFF" /></>}
            </div>
          </div>
          <p style={{ textAlign:"center", fontSize:12, color:textSecondary, marginTop:12, cursor:"pointer" }}>スキップ</p>
        </div>
      </PhoneFrame>
    );
  };

  /* ═══════ HOME ═══════ */
  const renderHome = () => (
    <PhoneFrame>
      <div style={{ textAlign:"center", paddingTop:40 }}>
        <div style={{ margin:"0 auto 16px" }}><AppLogo size={100} darkMode={darkMode} /></div>
        <h1 style={{ fontSize:28, fontWeight:800, color:textPrimary, margin:"0 0 4px", letterSpacing:-0.5 }}>IroPre</h1>
        <p style={{ fontSize:13, color:textSecondary, margin:"0 0 36px" }}>色で解く、新しい数独体験</p>
        {[{label:"ゲームスタート", gradient:"linear-gradient(135deg, #4A90D9, #6B5CE7)", IconC:Icons.play}, {label:"レベルを選ぶ", gradient:"linear-gradient(135deg, #27AE60, #2ECC71)", IconC:Icons.levels}, {label:"実績", gradient:"linear-gradient(135deg, #F1C40F, #F39C12)", IconC:Icons.trophy}].map((btn,i) => (
          <div key={i} style={{ background:btn.gradient, borderRadius:16, padding:"16px 24px", marginBottom:12, display:"flex", alignItems:"center", gap:12, cursor:"pointer", boxShadow:"0 4px 16px rgba(0,0,0,0.15), inset 0 1px 1px rgba(255,255,255,0.2)" }}>
            <btn.IconC size={22} color="#FFF" />
            <span style={{ color:"#FFF", fontSize:16, fontWeight:700, textShadow:"0 1px 2px rgba(0,0,0,0.2)" }}>{btn.label}</span>
          </div>
        ))}
        <div style={{ marginTop:16, display:"flex", justifyContent:"center", gap:24 }}>
          {[{IconC:Icons.settings, label:"設定"}, {IconC:Icons.help, label:"遊び方"}].map((item,i) => (
            <div key={i} style={{ textAlign:"center", cursor:"pointer" }}>
              <div style={{ width:48, height:48, borderRadius:16, background:darkMode?"linear-gradient(145deg, #22223A, #1A1A2E)":"linear-gradient(145deg, #FFF, #F0F0F7)", boxShadow:"0 3px 8px rgba(0,0,0,0.1)", display:"flex", alignItems:"center", justifyContent:"center", margin:"0 auto 4px" }}>
                <item.IconC size={22} color={iconColor} />
              </div>
              <span style={{ fontSize:11, color:textSecondary }}>{item.label}</span>
            </div>
          ))}
        </div>
      </div>
    </PhoneFrame>
  );

  /* ═══════ LEVEL SELECT ═══════ */
  const renderLevelSelect = () => {
    const levels = Array.from({length:20}, (_,i) => ({ num:i+1, cleared:i<7, stars:i<7?(i<3?3:i<5?2:1):0, locked:i>9 }));
    return (
      <PhoneFrame>
        <div style={{ paddingTop:8 }}>
          <div style={{ display:"flex", alignItems:"center", marginBottom:16 }}>
            <div style={{ cursor:"pointer" }}><Icons.back size={22} color={textPrimary} /></div>
            <h2 style={{ flex:1, textAlign:"center", fontSize:18, fontWeight:700, color:textPrimary, margin:0 }}>レベル選択</h2>
            <span style={{ width:22 }} />
          </div>
          <div style={{ display:"flex", gap:6, marginBottom:16, background:darkMode?"#1A1A2E":"#F0F0F7", borderRadius:12, padding:4 }}>
            {["4×4","6×6","9×9"].map((s,i) => (
              <div key={i} style={{ flex:1, padding:"8px 0", textAlign:"center", borderRadius:10, fontSize:13, fontWeight:600, cursor:"pointer", background:i===0?"linear-gradient(135deg, #4A90D9, #6B5CE7)":"transparent", color:i===0?"#FFF":textSecondary, boxShadow:i===0?"0 2px 8px rgba(74,144,217,0.4)":"none" }}>{s}</div>
            ))}
          </div>
          <div style={{ display:"grid", gridTemplateColumns:"repeat(4, 1fr)", gap:10 }}>
            {levels.map(lv => (
              <div key={lv.num} style={{ aspectRatio:"1", borderRadius:14, display:"flex", flexDirection:"column", alignItems:"center", justifyContent:"center", cursor:lv.locked?"default":"pointer", opacity:lv.locked?0.4:1, background:lv.cleared?`linear-gradient(145deg, ${colors[(lv.num-1)%9].hex}dd, ${colors[(lv.num-1)%9].hex})`:darkMode?"linear-gradient(145deg, #22223A, #1A1A2E)":"linear-gradient(145deg, #FFF, #F0F0F7)", boxShadow:lv.cleared?`0 4px 12px ${colors[(lv.num-1)%9].hex}40`:"0 2px 6px rgba(0,0,0,0.08)" }}>
                {lv.locked ? <Icons.lock size={18} color={textSecondary} /> : <span style={{ fontSize:18, fontWeight:800, color:lv.cleared?"#FFF":textPrimary, textShadow:lv.cleared?"0 1px 2px rgba(0,0,0,0.3)":"none" }}>{lv.num}</span>}
                {lv.cleared && <div style={{ display:"flex", gap:1, marginTop:2 }}>
                  {[0,1,2].map(s => <Icons.star key={s} size={10} filled={s<lv.stars} color={s<lv.stars?"#FFF":"rgba(255,255,255,0.4)"} />)}
                </div>}
              </div>
            ))}
          </div>
        </div>
      </PhoneFrame>
    );
  };

  /* ═══════ GAME SCREEN ═══════ */
  const renderGameScreen = (puzzle, gs, lvText, sizeText, time) => (
    <PhoneFrame>
      <div style={{ paddingTop:8 }}>
        <div style={{ display:"flex", alignItems:"center", justifyContent:"space-between", marginBottom:gs===9?6:12 }}>
          <div style={{ cursor:"pointer" }}><Icons.back size={22} color={textPrimary} /></div>
          <div style={{ textAlign:"center" }}>
            <div style={{ fontSize:12, color:textSecondary }}>{lvText}</div>
            <div style={{ fontSize:16, fontWeight:700, color:textPrimary }}>{sizeText}</div>
          </div>
          <div style={{ cursor:"pointer" }}><Icons.pause size={20} color={textPrimary} /></div>
        </div>
        <div style={{ textAlign:"center", marginBottom:gs===9?8:16, display:"flex", alignItems:"center", justifyContent:"center", gap:6 }}>
          <Icons.timer size={16} color={textSecondary} />
          <span style={{ fontSize:gs===9?22:28, fontWeight:300, color:textPrimary, letterSpacing:2, fontVariantNumeric:"tabular-nums" }}>{time}</span>
        </div>
        <div style={{ maxWidth:gs===9?290:gs===6?270:260, margin:`0 auto ${gs===9?10:20}px` }}>{renderGrid(puzzle, gs)}</div>
        <div style={{ marginBottom:gs===9?10:20 }}><Palette count={gs} /></div>
        <div style={{ display:"flex", justifyContent:"center", gap:20 }}>
          <ToolButton icon={Icons.hint} label="ヒント" />
          <ToolButton icon={Icons.undo} label="戻す" />
          <ToolButton icon={Icons.eraser} label="消す" />
        </div>
        <div style={{ textAlign:"center", marginTop:8, fontSize:11, color:textSecondary, display:"flex", alignItems:"center", justifyContent:"center", gap:4 }}>
          <Icons.hint size={12} color={textSecondary} /> ヒント残り: 3/3 回
        </div>
      </div>
    </PhoneFrame>
  );

  /* ═══════ CLEAR ═══════ */
  const renderClear = () => (
    <PhoneFrame>
      <div style={{ textAlign:"center", paddingTop:48 }}>
        <div style={{ position:"relative", height:120, marginBottom:8 }}>
          {[...Array(12)].map((_,i) => (<div key={i} style={{ position:"absolute", width:8+((i*7)%12), height:8+((i*5)%12), borderRadius:i%2===0?"50%":2, background:colors[i%9].hex, left:`${10+((i*37)%80)}%`, top:`${(i*23)%100}%`, opacity:0.7+((i*3)%3)*0.1, transform:`rotate(${i*30}deg)` }} />))}
          <div style={{ position:"absolute", top:"50%", left:"50%", transform:"translate(-50%, -50%)" }}>
            <Icons.sparkles size={64} color="#F1C40F" />
          </div>
        </div>
        <h2 style={{ fontSize:28, fontWeight:800, color:textPrimary, margin:"0 0 4px" }}>クリア！</h2>
        <p style={{ fontSize:14, color:textSecondary, margin:"0 0 24px" }}>Level 3 を完了しました</p>
        <div style={{ display:"flex", gap:12, justifyContent:"center", marginBottom:24 }}>
          {[{label:"タイム", value:"01:23", IconC:Icons.timer}, {label:"ヒント", value:"1回", IconC:Icons.hint}, {label:"評価", value:"", IconC:null}].map((stat,i) => (
            <div key={i} style={{ flex:1, padding:"12px 8px", borderRadius:14, background:darkMode?"linear-gradient(145deg, #22223A, #1A1A2E)":"linear-gradient(145deg, #FFF, #F0F0F7)", boxShadow:"0 3px 8px rgba(0,0,0,0.08)" }}>
              <div style={{ marginBottom:4, display:"flex", justifyContent:"center" }}>
                {stat.IconC ? <stat.IconC size={20} color={colors[1].hex} /> : <div style={{ display:"flex", gap:2 }}>{[0,1,2].map(s => <Icons.star key={s} size={16} filled color="#F1C40F" />)}</div>}
              </div>
              <div style={{ fontSize:16, fontWeight:700, color:textPrimary }}>{stat.value}</div>
              <div style={{ fontSize:10, color:textSecondary }}>{stat.label}</div>
            </div>
          ))}
        </div>
        <div style={{ background:`linear-gradient(135deg, ${colors[3].hex}22, ${colors[5].hex}22)`, border:`1px solid ${colors[3].hex}44`, borderRadius:14, padding:"12px 16px", marginBottom:24, display:"flex", alignItems:"center", gap:12 }}>
          <div style={{ width:40, height:40, borderRadius:12, background:`linear-gradient(135deg, ${colors[3].hex}33, ${colors[3].hex}11)`, display:"flex", alignItems:"center", justifyContent:"center" }}>
            <Icons.medal size={24} color={colors[3].hex} />
          </div>
          <div style={{ textAlign:"left" }}>
            <div style={{ fontSize:12, fontWeight:700, color:colors[3].hex }}>実績解除！</div>
            <div style={{ fontSize:13, color:textPrimary, fontWeight:600 }}>はじめの一歩</div>
          </div>
        </div>
        <div style={{ background:"linear-gradient(135deg, #4A90D9, #6B5CE7)", borderRadius:14, padding:"14px 24px", marginBottom:10, cursor:"pointer", boxShadow:"0 4px 16px rgba(74,144,217,0.4)", display:"flex", alignItems:"center", justifyContent:"center", gap:8 }}>
          <span style={{ color:"#FFF", fontSize:15, fontWeight:700 }}>次のレベルへ</span>
          <Icons.arrowRight size={18} color="#FFF" />
        </div>
        <div style={{ background:darkMode?"#22223A":"#F0F0F7", borderRadius:14, padding:"14px 24px", cursor:"pointer", display:"flex", alignItems:"center", justifyContent:"center", gap:6 }}>
          <Icons.home size={16} color={textSecondary} />
          <span style={{ color:textSecondary, fontSize:14, fontWeight:600 }}>ホームに戻る</span>
        </div>
      </div>
    </PhoneFrame>
  );

  /* ═══════ ACHIEVEMENTS ═══════ */
  const renderAchievements = () => {
    const achs = [
      { name:"はじめの一歩", desc:"初めてパズルをクリア", IconC:Icons.medal, unlocked:true },
      { name:"カラーマスター", desc:"Lv.30を60秒以内クリア", IconC:Icons.zap, unlocked:true },
      { name:"レインボーコンプリート", desc:"全盤面サイズでクリア", IconC:Icons.rainbow, unlocked:true },
      { name:"ノーヒントマスター", desc:"ヒント未使用でLv.50クリア", IconC:Icons.brain, unlocked:false },
      { name:"7日連続プレイ", desc:"7日連続でプレイ", IconC:Icons.flame, unlocked:false },
      { name:"パーフェクト100", desc:"全100レベルをクリア", IconC:Icons.crown, unlocked:false },
    ];
    return (
      <PhoneFrame>
        <div style={{ paddingTop:8 }}>
          <div style={{ display:"flex", alignItems:"center", marginBottom:16 }}>
            <div style={{ cursor:"pointer" }}><Icons.back size={22} color={textPrimary} /></div>
            <h2 style={{ flex:1, textAlign:"center", fontSize:18, fontWeight:700, color:textPrimary, margin:0 }}>実績</h2>
            <span style={{ width:22 }} />
          </div>
          <div style={{ textAlign:"center", marginBottom:20 }}>
            <span style={{ fontSize:36, fontWeight:800, color:colors[0].hex }}>3</span>
            <span style={{ fontSize:14, color:textSecondary }}> / 6 解除</span>
          </div>
          <div style={{ display:"flex", flexDirection:"column", gap:10 }}>
            {achs.map((a,i) => (
              <div key={i} style={{ display:"flex", alignItems:"center", gap:12, padding:"12px 14px", borderRadius:14, opacity:a.unlocked?1:0.5, background:a.unlocked?(darkMode?"linear-gradient(145deg, #22223A, #1A1A2E)":"linear-gradient(145deg, #FFF, #F8F9FF)"):(darkMode?"#16162B":"#F0F0F7"), boxShadow:a.unlocked?"0 3px 8px rgba(0,0,0,0.08)":"none" }}>
                <div style={{ width:44, height:44, borderRadius:14, display:"flex", alignItems:"center", justifyContent:"center", background:a.unlocked?`linear-gradient(135deg, ${colors[i%9].hex}22, ${colors[i%9].hex}11)`:"transparent" }}>
                  {a.unlocked ? <a.IconC size={24} color={colors[i%9].hex} /> : <Icons.lock size={20} color={textSecondary} />}
                </div>
                <div style={{ flex:1 }}>
                  <div style={{ fontSize:14, fontWeight:700, color:textPrimary }}>{a.name}</div>
                  <div style={{ fontSize:11, color:textSecondary }}>{a.desc}</div>
                </div>
                {a.unlocked && <Icons.check size={18} color="#27AE60" />}
              </div>
            ))}
          </div>
        </div>
      </PhoneFrame>
    );
  };

  /* ═══════ SETTINGS ═══════ */
  const renderSettings = () => (
    <PhoneFrame>
      <div style={{ paddingTop:8 }}>
        <div style={{ display:"flex", alignItems:"center", marginBottom:20 }}>
          <div style={{ cursor:"pointer" }}><Icons.back size={22} color={textPrimary} /></div>
          <h2 style={{ flex:1, textAlign:"center", fontSize:18, fontWeight:700, color:textPrimary, margin:0 }}>設定</h2>
          <span style={{ width:22 }} />
        </div>
        {[{title:"表示", items:[{label:"ダークモード",type:"toggle",value:darkMode,onChange:()=>setDarkMode(!darkMode)},{label:"アクセシビリティ",type:"select"}]}, {title:"サウンド & 触覚", items:[{label:"効果音",type:"toggle",value:true},{label:"ハプティクス",type:"toggle",value:true}]}, {title:"ゲーム", items:[{label:"エラーチェック",type:"toggle",value:true},{label:"タイマー表示",type:"toggle",value:true}]}].map((g,gi) => (
          <div key={gi} style={{ marginBottom:20 }}>
            <div style={{ fontSize:12, fontWeight:600, color:textSecondary, marginBottom:8, textTransform:"uppercase", letterSpacing:0.5 }}>{g.title}</div>
            <div style={{ borderRadius:14, overflow:"hidden", background:cardBg, boxShadow:"0 2px 8px rgba(0,0,0,0.06)" }}>
              {g.items.map((item,ii) => (
                <div key={ii} style={{ display:"flex", alignItems:"center", justifyContent:"space-between", padding:"13px 16px", borderBottom:ii<g.items.length-1?`1px solid ${borderColor}`:"none" }}>
                  <span style={{ fontSize:14, color:textPrimary }}>{item.label}</span>
                  {item.type==="toggle" ? (
                    <div onClick={item.onChange} style={{ width:44, height:26, borderRadius:13, background:item.value?"#4A90D9":darkMode?"#333":"#DDD", cursor:"pointer", position:"relative", transition:"background 0.2s" }}>
                      <div style={{ width:22, height:22, borderRadius:"50%", background:"#FFF", position:"absolute", top:2, left:item.value?20:2, transition:"left 0.2s", boxShadow:"0 1px 3px rgba(0,0,0,0.2)" }} />
                    </div>
                  ) : <span style={{ fontSize:13, color:colors[1].hex, fontWeight:600, display:"flex", alignItems:"center", gap:4 }}>パターン付き <Icons.arrowRight size={14} color={colors[1].hex} /></span>}
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </PhoneFrame>
  );

  /* ═══════ RENDER ═══════ */
  const screenRenderers = [
    renderSplash, renderTutorial, renderHome, renderLevelSelect,
    () => renderGameScreen(SAMPLE_4x4, 4, "Level 3", "4×4 ビギナー", "01:23"),
    () => renderGameScreen(SAMPLE_6x6, 6, "Level 28", "6×6 ミドル", "03:15"),
    () => renderGameScreen(SAMPLE_9x9, 9, "Level 55", "9×9 上級", "05:47"),
    renderClear, renderAchievements, renderSettings,
  ];

  return (
    <div style={{ minHeight:"100vh", background:"linear-gradient(135deg, #0F0F1A 0%, #1A1A3E 50%, #0F0F1A 100%)", padding:"24px 16px", fontFamily:'-apple-system, BlinkMacSystemFont, "SF Pro Display", sans-serif' }}>
      <div style={{ textAlign:"center", marginBottom:24 }}>
        <h1 style={{ fontSize:26, fontWeight:800, background:"linear-gradient(135deg, #FF6B6B, #4A90D9, #27AE60, #F1C40F)", WebkitBackgroundClip:"text", WebkitTextFillColor:"transparent", margin:"0 0 6px" }}>IroPre — UI Design v1.2</h1>
        <p style={{ color:"#8888AA", fontSize:13, margin:0 }}>3Dポップ × カラフル | iOS 18+ SwiftUI | 全10画面 | SVGアイコン</p>
      </div>
      <div style={{ display:"flex", gap:6, justifyContent:"center", flexWrap:"wrap", marginBottom:8 }}>
        {screens.map((name,i) => (
          <button key={i} onClick={() => setCurrentScreen(i)} style={{ padding:"8px 12px", borderRadius:10, border:"none", cursor:"pointer", fontSize:11, fontWeight:600, background:currentScreen===i?"linear-gradient(135deg, #4A90D9, #6B5CE7)":"rgba(255,255,255,0.08)", color:currentScreen===i?"#FFF":"#8888AA", transition:"all 0.2s" }}>{name}</button>
        ))}
      </div>
      <div style={{ display:"flex", gap:8, justifyContent:"center", marginBottom:24 }}>
        <button onClick={() => setDarkMode(!darkMode)} style={{ padding:"6px 12px", borderRadius:8, border:"1px solid rgba(255,255,255,0.15)", background:"transparent", color:"#8888AA", fontSize:11, cursor:"pointer" }}>{darkMode ? "☀️ ライト" : "🌙 ダーク"}</button>
        {["color","pattern","symbol"].map(mode => (
          <button key={mode} onClick={() => setAccessMode(mode)} style={{ padding:"6px 12px", borderRadius:8, border:accessMode===mode?"1px solid #4A90D9":"1px solid rgba(255,255,255,0.15)", background:accessMode===mode?"rgba(74,144,217,0.2)":"transparent", color:accessMode===mode?"#4A90D9":"#8888AA", fontSize:11, cursor:"pointer" }}>
            {mode==="color" ? "カラー" : mode==="pattern" ? "パターン" : "シンボル"}
          </button>
        ))}
      </div>
      <div style={{ display:"flex", justifyContent:"center" }}>{screenRenderers[currentScreen]()}</div>
    </div>
  );
}
