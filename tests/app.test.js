const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const request = require("supertest");
const { createApp } = require("../src/app");

describe("API", () => {
  const app = createApp();

  it("GET / returns app info", async () => {
    const res = await request(app).get("/");
    assert.equal(res.status, 200);
    assert.equal(res.body.name, "mi-cd-pipeline");
  });

  it("GET /health returns ok", async () => {
    const res = await request(app).get("/health");
    assert.equal(res.status, 200);
    assert.equal(res.body.status, "ok");
  });

  it("GET /api lists endpoints", async () => {
    const res = await request(app).get("/api");
    assert.equal(res.status, 200);
    assert.ok(Array.isArray(res.body.endpoints));
  });
});
