// Prüft alle Lerninhalte gegen das Schema aus Models/ContentModels.swift.
// Aufruf: node tools/validate-content.js
const fs = require("fs");
const path = require("path");

const appDir = path.join(__dirname, "..", "NetztechnikLernApp");
const contentDir = path.join(appDir, "Resources", "Content");
const errors = [];
const warnings = [];
const err = (where, msg) => errors.push(`${where}: ${msg}`);

const labs = new Set(fs.readFileSync(path.join(appDir, "Viz", "InteractiveLabs.swift"), "utf8")
  .match(/case "([a-z0-9]+)":/g).map((s) => s.match(/"(.+)"/)[1]));
const calcIDs = new Set((fs.readFileSync(path.join(appDir, "Calc", "CalcEngine.swift"), "utf8")
  .match(/id: "calc\.[a-z0-9]+"/g) || []).map((s) => s.match(/"(.+)"/)[1]));
const colors = new Set(["blue", "green", "red", "orange", "violet", "teal", "yellow", "gray"]);
const pageCount = { 1: 121, 2: 118 };

function checkRef(where, ref) {
  const m = /^T([12]) S\.(\d+)(?:-(\d+))?$/.exec(ref);
  if (!m) return err(where, `ungültige Referenz "${ref}"`);
  const part = Number(m[1]);
  for (const p of [m[2], m[3]]) {
    if (p && (Number(p) < 1 || Number(p) > pageCount[part])) err(where, `Seite außerhalb des Skripts: ${ref}`);
  }
}

function checkPairList(where, list, ids) {
  for (const pair of list || []) {
    if (!Array.isArray(pair) || pair.length !== 2) err(where, "Kante muss ein Paar sein");
    else for (const id of pair) if (!ids.has(id)) err(where, `unbekannter Knoten "${id}"`);
  }
}

function checkBlock(where, b) {
  if (typeof b.t !== "string") return err(where, "Block ohne t");
  switch (b.t) {
    case "p": case "k": case "f":
      if (!b.x) err(where, `${b.t}-Block ohne x`);
      break;
    case "b":
      if (!Array.isArray(b.i) || !b.i.length) err(where, "b-Block ohne i");
      break;
    case "tb":
      if (!Array.isArray(b.head) || !Array.isArray(b.rows)) return err(where, "tb ohne head/rows");
      b.rows.forEach((r, i) => { if (r.length !== b.head.length) err(where, `Tabellenzeile ${i} hat ${r.length} statt ${b.head.length} Spalten`); });
      break;
    case "sl":
      if (![1, 2].includes(b.part) || !(b.page >= 1 && b.page <= pageCount[b.part])) err(where, `ungültige Folie ${b.part}/${b.page}`);
      break;
    case "seq": {
      const n = (b.lifelines || []).length;
      if (n < 1 || !Array.isArray(b.msgs) || !b.msgs.length) return err(where, "seq unvollständig");
      b.msgs.forEach((m, i) => {
        if (!(m.f >= 0 && m.f < n && m.to >= 0 && m.to < n)) err(where, `Nachricht ${i} außerhalb der Lebenslinien`);
        if (!m.l) err(where, `Nachricht ${i} ohne Text`);
        if (m.c && !colors.has(m.c)) err(where, `Farbe "${m.c}"`);
      });
      break;
    }
    case "net": {
      const ids = new Set();
      for (const node of b.nodes || []) {
        if (ids.has(node.id)) err(where, `Knoten doppelt: ${node.id}`);
        ids.add(node.id);
        if (typeof node.l !== "string" || !(node.x >= 0 && node.x <= 1 && node.y >= 0 && node.y <= 1)) err(where, `Knoten ${node.id} ungültig`);
      }
      if (!ids.size) err(where, "net ohne Knoten");
      for (const e of b.edges || []) {
        if (!ids.has(e.a) || !ids.has(e.b)) err(where, `Kante ${e.a}-${e.b} verweist auf unbekannten Knoten`);
      }
      (b.steps || []).forEach((s, i) => {
        const w = `${where} Schritt ${i}`;
        if (!s.x) err(w, "ohne Text");
        for (const list of [s.hn, s.dn]) for (const id of list || []) if (!ids.has(id)) err(w, `unbekannter Knoten "${id}"`);
        checkPairList(w, s.he, ids);
        checkPairList(w, s.de, ids);
        for (const p of s.p || []) {
          if (!ids.has(p.a) || !ids.has(p.b)) err(w, `Paket ${p.a}->${p.b} unbekannt`);
          if (p.c && !colors.has(p.c)) err(w, `Farbe "${p.c}"`);
        }
        if (s.tb) {
          s.tb.rows.forEach((r, ri) => { if (r.length !== s.tb.head.length) err(w, `Tabelle Zeile ${ri}`); });
        }
      });
      break;
    }
    case "frame":
      if (!Array.isArray(b.frames) || !b.frames.length) return err(where, "frame ohne frames");
      b.frames.forEach((row) => row.segs.forEach((seg) => {
        if (typeof seg.t !== "string" || !(seg.w > 0)) err(where, `Segment ${seg.t} ungültig`);
        if (seg.c && !colors.has(seg.c)) err(where, `Farbe "${seg.c}"`);
      }));
      break;
    case "bars":
      if (!Array.isArray(b.bars) || !b.bars.length) return err(where, "bars leer");
      b.bars.forEach((bar) => {
        if (typeof bar.l !== "string" || typeof bar.v !== "number") err(where, "Balken ungültig");
        if (bar.c && !colors.has(bar.c)) err(where, `Farbe "${bar.c}"`);
      });
      break;
    case "x":
      if (!labs.has(b.viz)) err(where, `Labor "${b.viz}" existiert nicht`);
      break;
    default:
      err(where, `unbekannter Blocktyp "${b.t}"`);
  }
}

function checkQuestion(where, q) {
  for (const key of ["id", "k", "lvl", "pts", "q"]) if (q[key] === undefined) err(where, `fehlt ${key}`);
  if (!(q.lvl >= 1 && q.lvl <= 3)) err(where, "lvl muss 1-3 sein");
  if (q.ref) checkRef(where, q.ref); else warnings.push(`${where}: keine Skript-Referenz`);
  if (q.fig) checkBlock(`${where} fig`, q.fig);
  switch (q.k) {
    case "mc":
      if (!q.o || !q.a || q.a.length !== 1) err(where, "mc braucht o und genau eine Lösung");
      break;
    case "ms":
      if (!q.o || !q.a || !q.a.length) err(where, "ms braucht o und a");
      break;
    case "tf":
      if (!q.st || !q.st.length || q.st.some((s) => typeof s.v !== "boolean" || !s.s)) err(where, "tf ungültig");
      break;
    case "num":
      if (typeof q.num !== "number") err(where, "num ohne Wert");
      if (typeof q.tol !== "number") err(where, "num ohne Toleranz");
      if (!q.steps || !q.steps.length) err(where, "num ohne Rechenweg");
      break;
    case "ord":
      if (!q.seq || q.seq.length < 2) err(where, "ord braucht seq");
      else if (new Set(q.seq).size !== q.seq.length) err(where, "ord: Einträge müssen eindeutig sein");
      break;
    case "match":
      if (!q.pairs || q.pairs.some((p) => p.length !== 2)) err(where, "match braucht Paare");
      else if (new Set(q.pairs.map((p) => p[1])).size !== q.pairs.length) err(where, "match: rechte Seiten müssen eindeutig sein");
      break;
    case "open":
      if (!q.model || !q.model.length) err(where, "open braucht model");
      break;
    default:
      err(where, `unbekannter Fragetyp "${q.k}"`);
  }
  if ((q.k === "mc" || q.k === "ms") && q.o) {
    for (const i of q.a || []) if (!(i >= 0 && i < q.o.length)) err(where, `Lösungsindex ${i} außerhalb`);
    if (new Set(q.o).size !== q.o.length) err(where, "doppelte Antwortoption");
  }
}

const files = fs.readdirSync(contentDir).filter((f) => f.startsWith("module_") && f.endsWith(".json")).sort();
const seenIDs = new Set();
const counts = {};
let questions = 0;
let sections = 0;
let vizCount = 0;
const usedCalcs = new Set();
const usedLabs = new Set();

for (const file of files) {
  let m;
  const text = fs.readFileSync(path.join(contentDir, file), "utf8");
  try {
    m = JSON.parse(text);
  } catch (e) {
    err(file, `kein gültiges JSON: ${e.message}`);
    continue;
  }
  for (const key of ["id", "part", "order", "title", "pages", "icon", "goal", "sections", "questions"]) {
    if (m[key] === undefined) err(file, `fehlt ${key}`);
  }
  for (const s of m.sections || []) {
    sections++;
    if (seenIDs.has(s.id)) err(file, `ID doppelt: ${s.id}`);
    seenIDs.add(s.id);
    if (!s.id.startsWith(m.id)) err(file, `Abschnitt ${s.id} passt nicht zu ${m.id}`);
    for (const b of s.blocks) {
      checkBlock(`${file} ${s.id}`, b);
      if (["seq", "net", "frame", "bars", "x", "sl"].includes(b.t)) vizCount++;
      if (b.t === "x") usedLabs.add(b.viz);
    }
  }
  for (const q of m.questions || []) {
    questions++;
    counts[q.k] = (counts[q.k] || 0) + 1;
    if (seenIDs.has(q.id)) err(file, `ID doppelt: ${q.id}`);
    seenIDs.add(q.id);
    if (!q.id.startsWith(m.id)) err(file, `Frage ${q.id} passt nicht zu ${m.id}`);
    checkQuestion(`${file} ${q.id}`, q);
  }
  for (const id of m.calcs || []) {
    if (!calcIDs.has(id)) err(file, `Rechenaufgabe "${id}" existiert nicht`);
    usedCalcs.add(id);
  }
}

for (const id of calcIDs) if (!usedCalcs.has(id)) warnings.push(`Rechentyp ${id} ist keinem Modul zugeordnet`);
for (const lab of labs) if (lab && !usedLabs.has(lab)) warnings.push(`Labor ${lab} wird nicht verwendet`);

console.log(`Module: ${files.length}, Abschnitte: ${sections}, Fragen: ${questions}, Visualisierungen: ${vizCount}, Rechentypen: ${calcIDs.size}, Labore: ${labs.size}`);
console.log("Fragetypen:", JSON.stringify(counts));
warnings.forEach((w) => console.log("Hinweis:", w));
errors.forEach((e) => console.log("FEHLER:", e));
console.log(errors.length ? `${errors.length} Fehler gefunden.` : "Keine Fehler gefunden.");
process.exit(errors.length ? 1 : 0);
