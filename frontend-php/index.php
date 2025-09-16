<?php include "base_start.php"; include "env.php"; ?>
<div class="d-flex align-items-center justify-content-between mb-3">
  <h3 class="m-0">Dashboard</h3>
  <button class="btn btn-sm btn-outline-dark d-lg-none" id="toggleSidebar">
    <i class="bi bi-list"></i> Menu
  </button>
</div>

<div class="row">
  <?php include "sidebar.php"; ?>

  <section class="col-lg-9">
    <!-- KPI cards -->
    <div class="row g-3 mb-4">
      <div class="col-md-3">
        <div class="card p-3">
          <div class="d-flex justify-content-between align-items-center">
            <div><div class="text-muted">Customers</div><div class="fs-3 fw-bold" id="kpi-customers">—</div></div>
            <i class="bi bi-people fs-1"></i>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card p-3">
          <div class="d-flex justify-content-between align-items-center">
            <div><div class="text-muted">Products</div><div class="fs-3 fw-bold" id="kpi-products">—</div></div>
            <i class="bi bi-box-seam fs-1"></i>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card p-3">
          <div class="d-flex justify-content-between align-items-center">
            <div><div class="text-muted">Orders</div><div class="fs-3 fw-bold" id="kpi-orders">—</div></div>
            <i class="bi bi-receipt fs-1"></i>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card p-3">
          <div class="d-flex justify-content-between align-items-center">
            <div>
              <div class="text-muted">Revenue (inv.)</div>
              <div class="fs-3 fw-bold"><span id="kpi-revenue">—</span> <span class="text-muted" id="kpi-cur"></span></div>
            </div>
            <i class="bi bi-cash-coin fs-1"></i>
          </div>
        </div>
      </div>
    </div>

    <div class="row g-3">
      <!-- Recent Products -->
      <div class="col-lg-6">
        <div class="card p-3 h-100">
          <div class="d-flex justify-content-between align-items-center mb-2">
            <h5 class="m-0">Recent Products</h5>
            <a class="btn btn-sm btn-outline-dark" href="products.php">View all</a>
          </div>
          <div class="table-responsive">
            <table class="table table-striped m-0">
              <thead><tr><th>SKU</th><th>Name</th><th class="text-end">Price</th><th class="text-end">Stock</th></tr></thead>
              <tbody id="recent-products"></tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Recent Orders -->
      <div class="col-lg-6">
        <div class="card p-3 h-100">
          <div class="d-flex justify-content-between align-items-center mb-2">
            <h5 class="m-0">Recent Orders</h5>
            <a class="btn btn-sm btn-outline-dark" href="orders.php">View all</a>
          </div>
          <div class="table-responsive">
            <table class="table table-striped m-0">
              <thead><tr><th>No</th><th>Customer</th><th>Date</th><th class="text-end">Total</th></tr></thead>
              <tbody id="recent-orders"></tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Low Stock -->
      <div class="col-12">
        <div class="card p-3">
          <div class="d-flex justify-content-between align-items-center mb-2">
            <h5 class="m-0">Low Stock</h5>
            <a class="btn btn-sm btn-outline-dark" href="products.php">Manage</a>
          </div>
          <div class="table-responsive">
            <table class="table table-striped m-0">
              <thead><tr><th>SKU</th><th>Product</th><th class="text-end">On Hand</th><th class="text-end">Min</th><th>Warehouse</th></tr></thead>
              <tbody id="low-stock"></tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </section>
</div>

<script>
// Mobile toggle për sidebar
document.getElementById('toggleSidebar')?.addEventListener('click', ()=>{
  document.getElementById('sidebarNav')?.classList.toggle('d-none');
});

// Helper: fetch JSON me fallback bosh
async function j(url){
  try{ const r = await fetch(url); if(!r.ok) throw new Error(r.status); return await r.json(); }
  catch(e){ return []; }
}

(async function load(){
  const API = "<?php echo $API_BASE; ?>";

  const products = await j(`${API}/products`);
  const customers = await j(`${API}/customers`);
  let orders = await j(`${API}/sales/orders`); if(!Array.isArray(orders)||!orders.length){ orders = await j(`${API}/orders`); }
  let inv = await j(`${API}/sales/arinv`);
  const currency = (inv[0]?.currency) || 'EUR';

  // KPIs
  document.getElementById('kpi-products').textContent = Array.isArray(products)? products.length : '0';
  document.getElementById('kpi-customers').textContent = Array.isArray(customers)? customers.length : '0';
  document.getElementById('kpi-orders').textContent = Array.isArray(orders)? orders.length : '0';
  const revenue = (Array.isArray(inv)? inv : []).reduce((a,i)=>{
    const tot = (i.lines||[]).reduce((s,l)=> s + (l.quantity??l.qty||0) * (l.unitPrice??l.price||0), 0);
    return a + tot;
  },0);
  document.getElementById('kpi-revenue').textContent = revenue.toFixed(2);
  document.getElementById('kpi-cur').textContent = currency;

  // Recent Products
  const rp = (products||[]).slice(-6).reverse();
  document.getElementById('recent-products').innerHTML = rp.map(p=>`
    <tr>
      <td>${p.sku||''}</td>
      <td>${p.name||''}</td>
      <td class="text-end">${((p.unitPrice??0)*1).toFixed(2)}</td>
      <td class="text-end">${p.stockQty??0}</td>
    </tr>`).join('');

  // Recent Orders
  const ro = (orders||[]).slice(-6).reverse();
  document.getElementById('recent-orders').innerHTML = ro.map(o=>{
    const total = (o.lines||[]).reduce((s,l)=> s + (l.quantity??l.qty||0) * (l.unitPrice??l.price||0), 0);
    const no = o.soNo || o.orderNo || ('#'+(o.id||'')); const cust = o.customer?.name || '';
    const date = (o.date || o.orderDate || '').toString().substring(0,10);
    const cur = o.currency || currency || '';
    return `<tr><td>${no}</td><td>${cust}</td><td>${date}</td><td class="text-end">${total.toFixed(2)} ${cur}</td></tr>`;
  }).join('');

  // Low Stock
  let levels = await j(`${API}/stock/levels`);
  if(Array.isArray(levels) && levels.length){
    document.getElementById('low-stock').innerHTML = levels
      .filter(r => (r.onHand ?? 0) <= (r.product?.minStock ?? 0))
      .slice(0,10)
      .map(r=>`<tr>
          <td>${r.product?.sku||''}</td>
          <td>${r.product?.name||''}</td>
          <td class="text-end">${r.onHand??0}</td>
          <td class="text-end">${r.product?.minStock??0}</td>
          <td>${r.warehouse?.code||''}</td>
        </tr>`).join('');
  } else {
    const low = (products||[]).filter(p => (p.stockQty??0) <= (p.minStock??0)).slice(0,10);
    document.getElementById('low-stock').innerHTML = low.map(p=>`
      <tr>
        <td>${p.sku||''}</td><td>${p.name||''}</td>
        <td class="text-end">${p.stockQty??0}</td>
        <td class="text-end">${p.minStock??0}</td>
        <td>—</td>
      </tr>`).join('');
  }
})();
</script>

<?php include "base_end.php"; ?>