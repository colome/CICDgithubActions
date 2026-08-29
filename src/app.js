const express = require("express");

function createApp() {
  const app = express();
  app.use(express.json());

  app.get("/", (_req, res) => {
    res.json({
      name: "mi-cd-pipeline",
      message: "API lista",
      version: process.env.APP_VERSION || "1.0.0",
      environment: process.env.NODE_ENV || "development",
    });
  });

  app.get("/health", (_req, res) => {
    res.status(200).json({
      status: "ok",
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || "development",
    });
  });

  app.get("/api", (_req, res) => {
    res.json({
      endpoints: ["/", "/health", "/api"],
      docs: "Reto GitHub Actions CD Pipeline",
    });
  });

  app.use((_req, res) => {
    res.status(404).json({ error: "not found" });
  });

  return app;
}

module.exports = { createApp };
