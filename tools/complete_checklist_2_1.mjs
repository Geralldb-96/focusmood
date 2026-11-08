import fs from "node:fs/promises";
import { createRequire } from "node:module";
import { pathToFileURL } from "node:url";

const runtimeRequire = createRequire("C:/Users/Geral/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/loader.mjs");
const artifactTool = await import(pathToFileURL(runtimeRequire.resolve("@oai/artifact-tool")).href);
const { FileBlob, SpreadsheetFile } = artifactTool;

const workbookPath = "C:/Desarollo/Focus 2.0/outputs/focusmood-checklist/Checklist_completo_FocusMood.xlsx";
const input = await FileBlob.load(workbookPath);
const workbook = await SpreadsheetFile.importXlsx(input);
const checklist = workbook.worksheets.getItem("Checklist");

const before = await workbook.inspect({
  kind: "table",
  range: "Checklist!C19:H19",
  include: "values,formulas",
  tableMaxRows: 2,
  tableMaxCols: 6,
  maxChars: 3000,
});
console.log(before.ndjson);

checklist.getRange("E19").values = [["Completada"]];
checklist.getRange("G19").values = [["Proyecto Flutter movido a mobile/ y validado con analyze, 9 pruebas y compilación APK."]];
checklist.getRange("H19").values = [[new Date("2026-11-08T12:00:00-05:00")]];
checklist.getRange("H19").setNumberFormat("dd/mm/yyyy");

workbook.recalculate();

const after = await workbook.inspect({
  kind: "table",
  range: "Resumen!A5:H7",
  include: "values,formulas",
  tableMaxRows: 4,
  tableMaxCols: 8,
  maxChars: 5000,
});
console.log(after.ndjson);

const errors = await workbook.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!",
  options: { useRegex: true, maxResults: 300 },
  summary: "final formula error scan",
});
console.log(errors.ndjson);

const verifyDir = "C:/Desarollo/Focus 2.0/outputs/focusmood-checklist/.verification";
await fs.mkdir(verifyDir, { recursive: true });
for (const [sheetName, range, fileName] of [
  ["Checklist", "C17:H21", "checklist_2_1.png"],
  ["Resumen", "A5:H8", "resumen_2_1.png"],
]) {
  const preview = await workbook.render({ sheetName, range, scale: 1, format: "png" });
  await fs.writeFile(`${verifyDir}/${fileName}`, new Uint8Array(await preview.arrayBuffer()));
}

const output = await SpreadsheetFile.exportXlsx(workbook);
await output.save(workbookPath);
console.log(JSON.stringify({ workbookPath, updated: "Checklist!E19,G19,H19" }));
