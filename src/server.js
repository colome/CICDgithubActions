const { createApp } = require("./app");

const PORT = Number(process.env.PORT || 3000);
const app = createApp();

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server listening on :${PORT}`);
  console.log(`NODE_ENV=${process.env.NODE_ENV || "development"}`);
});
