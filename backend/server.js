const jsonServer = require('json-server');
const server = jsonServer.create();
const router = jsonServer.router('db.json');
const middlewares = jsonServer.defaults();

const port = process.env.PORT || 3000;

// Set default middlewares (logger, static, cors and no-cache)
server.use(middlewares);

// Add custom routes before JSON Server router if needed

// GET /api/v1/menu?table_id={id} - Get menu for a table
server.get('/api/v1/menu', (req, res) => {
  const db = router.db;
  const table_id = req.query.table_id;
  
  // Here we can use table_id if we want to add specific validation,
  // For now we just return the full menu structure.
  const restaurant = db.get('restaurant').value();
  const categories = db.get('categories').value();
  const items = db.get('items').value();

  res.json({
    restaurant,
    categories,
    items
  });
});

// GET /api/v1/categories - List menu categories
server.get('/api/v1/categories', (req, res) => {
  const categories = router.db.get('categories').value();
  res.json(categories);
});

// POST /api/v1/orders - Create new order
// GET /api/v1/orders/{id} - Get order status
// We use json-server's rewriter to easily map these later, or handle them via routing directly.
server.post('/api/v1/orders', (req, res, next) => {
  req.url = '/orders';
  next();
});

server.get('/api/v1/orders/:id', (req, res, next) => {
  req.url = `/orders/${req.params.id}`;
  next();
});

// GET /api/v1/tables/{id}/status - Get table status
server.get('/api/v1/tables/:id/status', (req, res) => {
  const table = router.db.get('tables').find({ id: req.params.id }).value();
  if (table) {
    res.json({
      id: table.id,
      status: table.status
    });
  } else {
    res.status(404).json({ error: "Table not found" });
  }
});

server.get('/echo', (req, res) => {
  res.jsonp(req.query);
});

// To handle POST, PUT and PATCH you need to use a body-parser
// You can use the one used by JSON Server
server.use(jsonServer.bodyParser);
server.use((req, res, next) => {
  if (req.method === 'POST') {
    req.body.createdAt = Date.now();
    // Otomatis tambahkan status 'pending' untuk order baru
    if (req.url === '/orders') {
      req.body.status = 'pending';
    }
  }
  // Continue to JSON Server router
  next();
});

// Use default router
server.use(router);
server.listen(port, () => {
  console.log(`JSON Server is running on port ${port}`);
});
