#!/usr/bin/env node
/**
 * Smoke tests contra una URL desplegada.
 * Uso: BASE_URL=https://staging.example.com node scripts/smoke.js
 */
const base = (process.env.BASE_URL || "").replace(/\/$/, "");
if (!base) {
  console.error("BASE_URL is required");
  process.exit(1);
}

async function check(path, expectStatus = 200) {
  const url = `${base}${path}`;
  const res = await fetch(url);
  const text = await res.text();
  if (res.status !== expectStatus) {
    throw new Error(`${url} -> ${res.status} (expected ${expectStatus}): ${text.slice(0, 200)}`);
  }
  console.log(`PASS ${path} (${res.status})`);
  return text;
}

(async () => {
  console.log(`Smoke tests -> ${base}`);
  const health = await check("/health");
  const healthJson = JSON.parse(health);
  if (healthJson.status !== "ok") {
    throw new Error(`/health status field is not ok: ${health}`);
  }
  await check("/");
  await check("/api");
  console.log("All smoke tests passed");
})().catch((err) => {
  console.error("FAIL", err.message || err);
  process.exit(1);
});
