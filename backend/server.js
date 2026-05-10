const jsonServer = require("json-server");
const server = jsonServer.create();
const router = jsonServer.router("db.json");
const middlewares = jsonServer.defaults();

const port = 3000;

server.use(middlewares);

server.get("/api/v1/menu", (req, res) => {
  const db = router.db;

  const restaurant = db.get("restaurant").value();
  const categories = db.get("categories").value();
  const items = db.get("items").value();

  res.json({
    restaurant,
    categories,
    items,
  });
});

server.get("/api/v1/categories", (req, res) => {
  const categories = router.db.get("categories").value();
  res.json(categories);
});

server.post("/api/v1/orders", (req, res, next) => {
  req.url = "/orders";
  next();
});

server.get("/api/v1/orders/:id", (req, res, next) => {
  req.url = `/orders/${req.params.id}`;
  next();
});

server.get("/api/v1/tables/:id/status", (req, res) => {
  const table = router.db.get("tables").find({ id: req.params.id }).value();
  if (table) {
    res.json({
      id: table.id,
      status: table.status,
    });
  } else {
    res.status(404).json({ error: "Table not found" });
  }
});

server.get("/echo", (req, res) => {
  res.jsonp(req.query);
});

server.use(jsonServer.bodyParser);
server.use((req, res, next) => {
  if (req.method === "POST") {
    req.body.createdAt = Date.now();

    if (req.url === "/orders") {
      req.body.status = "pending";
    }
  }

  next();
});

server.use(router);
server.listen(port, () => {
  console.log(`JSON Server is running on port ${port}`);
});
