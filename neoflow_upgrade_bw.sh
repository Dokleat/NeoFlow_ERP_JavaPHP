#!/usr/bin/env bash
set -euo pipefail
ROOT="${PWD}"
BACK="${ROOT}/backend/src/main/java/com/neoflow/minierp"
RES="${ROOT}/backend/src/main/resources"
PHP="${ROOT}/frontend-php"

echo ">> Upgrading backend..."

# --- InventoryController (new) ---
cat > "${BACK}/controller/InventoryController.java" <<'EOF'
package com.neoflow.minierp.controller;
import com.neoflow.minierp.entity.Product;
import com.neoflow.minierp.entity.InventoryMovement;
import com.neoflow.minierp.repo.ProductRepo;
import com.neoflow.minierp.repo.InventoryRepo;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/inventory")
public class InventoryController {
  private final ProductRepo pRepo; private final InventoryRepo iRepo;
  public InventoryController(ProductRepo pRepo, InventoryRepo iRepo){ this.pRepo=pRepo; this.iRepo=iRepo; }

  @PostMapping("/move")
  public Product move(@RequestParam Long productId,
                      @RequestParam String type, // IN, OUT, ADJUST
                      @RequestParam int qty,
                      @RequestParam(required=false, defaultValue="") String ref){
    Product p = pRepo.findById(productId).orElseThrow();
    int delta = switch (type) { case "IN" -> qty; case "OUT" -> -qty; default -> qty; };
    p.setStockQty(p.getStockQty() + delta);
    InventoryMovement m = new InventoryMovement();
    m.setProduct(p); m.setMovementType(type); m.setQuantity(qty); m.setReference(ref);
    iRepo.save(m);
    return pRepo.save(p);
  }
}
EOF

# --- extend OrderController with GET /{id} ---
cat > "${BACK}/controller/OrderController.java" <<'EOF'
package com.neoflow.minierp.controller;
import com.neoflow.minierp.entity.*; import com.neoflow.minierp.repo.*;
import org.springframework.web.bind.annotation.*; import java.util.*;
@RestController @RequestMapping("/api/orders")
public class OrderController {
  private final OrderRepo oRepo; private final OrderLineRepo olRepo; private final CustomerRepo cRepo; private final ProductRepo pRepo;
  public OrderController(OrderRepo oRepo, OrderLineRepo olRepo, CustomerRepo cRepo, ProductRepo pRepo){
    this.oRepo=oRepo; this.olRepo=olRepo; this.cRepo=cRepo; this.pRepo=pRepo;
  }
  @GetMapping public List<Order> all(){return oRepo.findAll();}
  @GetMapping("/{id}") public Order one(@PathVariable Long id){ return oRepo.findById(id).orElseThrow(); }
  @PostMapping public Order create(@RequestParam Long customerId){
    Order last=oRepo.findTopByOrderByIdDesc(); long next= last==null?1:last.getId()+1;
    Order o=new Order(); o.setCustomer(cRepo.findById(customerId).orElseThrow());
    o.setOrderNo(String.format("SO-%05d", next)); return oRepo.save(o);
  }
  @PostMapping("/{orderId}/line")
  public Order addLine(@PathVariable Long orderId,@RequestParam Long productId,@RequestParam int qty,@RequestParam double price){
    Order o=oRepo.findById(orderId).orElseThrow(); Product p=pRepo.findById(productId).orElseThrow();
    OrderLine l=new OrderLine(); l.setOrder(o); l.setProduct(p); l.setQuantity(qty); l.setUnitPrice(price);
    p.setStockQty(p.getStockQty()-qty); pRepo.save(p); olRepo.save(l); return oRepo.findById(orderId).orElseThrow();
  }
  @PostMapping("/{orderId}/status")
  public Order setStatus(@PathVariable Long orderId,@RequestParam String status){
    Order o=oRepo.findById(orderId).orElseThrow(); o.setStatus(status); return oRepo.save(o);
  }
}
EOF

echo ">> Upgrading frontend (PHP UI, monochrome + features)..."

# --- base_start.php (monochrome theme + toggle) ---
cat > "${PHP}/base_start.php" <<'EOF'
<?php include "env.php"; ?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>NeoFlow MiniERP</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
  <link href="https://cdn.datatables.net/1.13.8/css/dataTables.bootstrap5.min.css" rel="stylesheet">
  <style>
    :root{
      --bg:#ffffff; --fg:#111111; --card:#f6f6f6; --muted:#6b7280; --accent:#111111;
    }
    .dark{
      --bg:#0d0d0d; --fg:#f3f3f3; --card:#161616; --muted:#9ca3af; --accent:#ffffff;
    }
    body{background:var(--bg); color:var(--fg);}
    .navbar, .card{ background:var(--card); border:1px solid #e5e7eb; }
    .btn-primary{ background:var(--fg); border-color:var(--fg); color:var(--bg); }
    a, .nav-link{ color:var(--fg); }
    table{ color:var(--fg); }
    .form-control,.form-select{ background:var(--bg); color:var(--fg); border-color:#d1d5db; }
    .form-control:focus,.form-select:focus{ box-shadow:none; border-color:#111; }
    .badge{ background:#e5e7eb; color:#111; }
    .low{ background:#fff1f2 !important; }
  </style>
  <script>
    // theme toggle persisted
    (function(){
      const theme = localStorage.getItem('nf_theme') || 'light';
      if(theme==='dark') document.documentElement.classList.add('dark');
      window.toggleTheme = function(){
        document.documentElement.classList.toggle('dark');
        localStorage.setItem('nf_theme', document.documentElement.classList.contains('dark')?'dark':'light');
      }
    })();
  </script>
</head>
<body>
<nav class="navbar navbar-expand-lg mb-4">
  <div class="container-fluid">
    <a class="navbar-brand" href="index.php"><strong>NeoFlow</strong> MiniERP</a>
    <div class="d-flex gap-2 ms-auto">
      <button class="btn btn-sm btn-outline-dark" onclick="toggleTheme()">
        <i class="bi bi-circle-half"></i> Theme
      </button>
    </div>
  </div>
</nav>
<main class="container">
EOF

# --- customers.php (add Edit/Delete) ---
cat > "${PHP}/customers.php" <<'EOF'
<?php include "base_start.php"; include "env.php"; ?>
<div class="d-flex justify-content-between align-items-center mb-3">
  <h3 class="m-0">Customers</h3>
  <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalNew"><i class="bi bi-plus-lg"></i> New</button>
</div>
<div class="card p-3">
  <table id="tbl" class="table table-striped" style="width:100%">
    <thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Phone</th><th class="text-end">Actions</th></tr></thead>
    <tbody></tbody>
  </table>
</div>

<!-- New -->
<div class="modal fade" id="modalNew" tabindex="-1"><div class="modal-dialog"><div class="modal-content">
  <div class="modal-header"><h5 class="modal-title">New Customer</h5></div>
  <div class="modal-body"><form id="formNew">
    <div class="mb-2"><label>Name</label><input class="form-control" name="name" required></div>
    <div class="mb-2"><label>Email</label><input class="form-control" name="email"></div>
    <div class="mb-2"><label>Phone</label><input class="form-control" name="phone"></div>
    <div class="mb-2"><label>Billing Address</label><textarea class="form-control" name="billingAddress"></textarea></div>
    <div class="mb-2"><label>Shipping Address</label><textarea class="form-control" name="shippingAddress"></textarea></div>
  </form></div>
  <div class="modal-footer">
    <button class="btn btn-outline-dark" data-bs-dismiss="modal">Cancel</button>
    <button class="btn btn-primary" onclick="createCustomer()">Save</button>
  </div>
</div></div></div>

<!-- Edit -->
<div class="modal fade" id="modalEdit" tabindex="-1"><div class="modal-dialog"><div class="modal-content">
  <div class="modal-header"><h5 class="modal-title">Edit Customer</h5></div>
  <div class="modal-body"><form id="formEdit">
    <input type="hidden" name="id">
    <div class="mb-2"><label>Name</label><input class="form-control" name="name" required></div>
    <div class="mb-2"><label>Email</label><input class="form-control" name="email"></div>
    <div class="mb-2"><label>Phone</label><input class="form-control" name="phone"></div>
    <div class="mb-2"><label>Billing Address</label><textarea class="form-control" name="billingAddress"></textarea></div>
    <div class="mb-2"><label>Shipping Address</label><textarea class="form-control" name="shippingAddress"></textarea></div>
  </form></div>
  <div class="modal-footer">
    <button class="btn btn-outline-dark" data-bs-dismiss="modal">Cancel</button>
    <button class="btn btn-primary" onclick="saveEdit()">Save</button>
  </div>
</div></div></div>

<script>
let rows=[];
function load(){
  fetch("<?php echo $API_BASE; ?>/customers").then(r=>r.json()).then(data=>{
    rows=data;
    const tbody=document.querySelector("#tbl tbody");
    tbody.innerHTML=data.map(r=>`<tr>
      <td>${r.id}</td><td>${r.name}</td><td>${r.email||''}</td><td>${r.phone||''}</td>
      <td class="text-end">
        <button class="btn btn-sm btn-outline-dark me-1" onclick='openEdit(${JSON.stringify(r).replace(/'/g,"&#39;")})'><i class="bi bi-pencil-square"></i></button>
        <button class="btn btn-sm btn-outline-dark" onclick="del(${r.id})"><i class="bi bi-trash"></i></button>
      </td>
    </tr>`).join("");
    new DataTable('#tbl');
  });
}
function createCustomer(){
  const data=Object.fromEntries(new FormData(document.getElementById('formNew')).entries());
  if(!data.name) return alert("Name required");
  fetch("<?php echo $API_BASE; ?>/customers",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify(data)})
    .then(()=>location.reload());
}
function openEdit(r){
  const f=document.getElementById('formEdit');
  f.id.value=r.id; f.name.value=r.name||''; f.email.value=r.email||''; f.phone.value=r.phone||'';
  f.billingAddress.value=r.billingAddress||''; f.shippingAddress.value=r.shippingAddress||'';
  new bootstrap.Modal(document.getElementById('modalEdit')).show();
}
function saveEdit(){
  const f=document.getElementById('formEdit');
  const id=f.id.value;
  const data=Object.fromEntries(new FormData(f).entries()); delete data.id;
  fetch("<?php echo $API_BASE; ?>/customers/"+id,{method:"PUT",headers:{"Content-Type":"application/json"},body:JSON.stringify(data)})
    .then(()=>location.reload());
}
function del(id){
  if(!confirm("Delete customer?")) return;
  fetch("<?php echo $API_BASE; ?>/customers/"+id,{method:"DELETE"}).then(()=>location.reload());
}
load();
</script>
<?php include "base_end.php"; ?>
EOF

# --- products.php (edit/delete + low-stock + stock move) ---
cat > "${PHP}/products.php" <<'EOF'
<?php include "base_start.php"; include "env.php"; ?>
<div class="d-flex justify-content-between align-items-center mb-3">
  <h3 class="m-0">Products</h3>
  <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalNew"><i class="bi bi-plus-lg"></i> New</button>
</div>
<div class="card p-3">
  <table id="tbl" class="table table-striped" style="width:100%">
    <thead><tr><th>ID</th><th>SKU</th><th>Name</th><th>Price</th><th>Stock</th><th>Min</th><th class="text-end">Actions</th></tr></thead>
    <tbody></tbody>
  </table>
</div>

<!-- New -->
<div class="modal fade" id="modalNew" tabindex="-1"><div class="modal-dialog"><div class="modal-content">
  <div class="modal-header"><h5 class="modal-title">New Product</h5></div>
  <div class="modal-body"><form id="formNew">
    <div class="mb-2"><label>SKU</label><input class="form-control" name="sku" required></div>
    <div class="mb-2"><label>Name</label><input class="form-control" name="name" required></div>
    <div class="mb-2"><label>Unit Price</label><input class="form-control" name="unitPrice" value="0"></div>
    <div class="mb-2"><label>Stock Qty</label><input class="form-control" name="stockQty" value="0"></div>
    <div class="mb-2"><label>Min Stock</label><input class="form-control" name="minStock" value="0"></div>
  </form></div>
  <div class="modal-footer">
    <button class="btn btn-outline-dark" data-bs-dismiss="modal">Cancel</button>
    <button class="btn btn-primary" onclick="createP()">Save</button>
  </div>
</div></div></div>

<!-- Edit / Stock Move -->
<div class="modal fade" id="modalEdit" tabindex="-1"><div class="modal-dialog"><div class="modal-content">
  <div class="modal-header"><h5 class="modal-title">Edit Product</h5></div>
  <div class="modal-body"><form id="formEdit">
    <input type="hidden" name="id">
    <div class="mb-2"><label>SKU</label><input class="form-control" name="sku" required></div>
    <div class="mb-2"><label>Name</label><input class="form-control" name="name" required></div>
    <div class="mb-2"><label>Unit Price</label><input class="form-control" name="unitPrice" value="0"></div>
    <div class="mb-2"><label>Stock Qty</label><input class="form-control" name="stockQty" value="0"></div>
    <div class="mb-2"><label>Min Stock</label><input class="form-control" name="minStock" value="0"></div>
  </form>
  <hr>
  <div>
    <h6>Inventory Move</h6>
    <div class="d-flex gap-2">
      <input class="form-control" style="max-width:120px" id="mvQty" placeholder="Qty">
      <input class="form-control" style="max-width:200px" id="mvRef" placeholder="Ref">
      <button class="btn btn-outline-dark" onclick="moveStock('IN')">IN</button>
      <button class="btn btn-outline-dark" onclick="moveStock('OUT')">OUT</button>
    </div>
  </div>
  </div>
  <div class="modal-footer">
    <button class="btn btn-outline-dark" data-bs-dismiss="modal">Close</button>
    <button class="btn btn-primary" onclick="saveEdit()">Save</button>
  </div>
</div></div></div>

<script>
let rows=[], current=null;
function load(){
  fetch("<?php echo $API_BASE; ?>/products").then(r=>r.json()).then(data=>{
    rows=data;
    const tbody=document.querySelector("#tbl tbody");
    tbody.innerHTML=data.map(r=>`<tr class="${r.stockQty<=r.minStock?'low':''}">
      <td>${r.id}</td><td>${r.sku}</td><td>${r.name}</td>
      <td>${(r.unitPrice||0).toFixed(2)}</td><td>${r.stockQty}</td><td>${r.minStock}</td>
      <td class="text-end">
        <button class="btn btn-sm btn-outline-dark me-1" onclick='openEdit(${JSON.stringify(r).replace(/'/g,"&#39;")})'><i class="bi bi-pencil-square"></i></button>
        <button class="btn btn-sm btn-outline-dark" onclick="del(${r.id})"><i class="bi bi-trash"></i></button>
      </td>
    </tr>`).join("");
    new DataTable('#tbl');
  });
}
function createP(){
  const d=Object.fromEntries(new FormData(document.getElementById('formNew')).entries());
  d.unitPrice=parseFloat(d.unitPrice||0); d.stockQty=parseInt(d.stockQty||0); d.minStock=parseInt(d.minStock||0);
  fetch("<?php echo $API_BASE; ?>/products",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify(d)}).then(()=>location.reload());
}
function openEdit(r){
  current=r;
  const f=document.getElementById('formEdit');
  f.id.value=r.id; f.sku.value=r.sku; f.name.value=r.name;
  f.unitPrice.value=r.unitPrice; f.stockQty.value=r.stockQty; f.minStock.value=r.minStock;
  new bootstrap.Modal(document.getElementById('modalEdit')).show();
}
function saveEdit(){
  const f=document.getElementById('formEdit'); const id=f.id.value;
  const d=Object.fromEntries(new FormData(f).entries()); delete d.id;
  d.unitPrice=parseFloat(d.unitPrice||0); d.stockQty=parseInt(d.stockQty||0); d.minStock=parseInt(d.minStock||0);
  fetch("<?php echo $API_BASE; ?>/products/"+id,{method:"PUT",headers:{"Content-Type":"application/json"},body:JSON.stringify(d)}).then(()=>location.reload());
}
function del(id){
  if(!confirm("Delete product?")) return;
  fetch("<?php echo $API_BASE; ?>/products/"+id,{method:"DELETE"}).then(()=>location.reload());
}
function moveStock(type){
  const qty=parseInt(document.getElementById('mvQty').value||0); const ref=document.getElementById('mvRef').value||'';
  if(!qty || !current) return alert("Select product and qty");
  fetch(`<?php echo $API_BASE; ?>/inventory/move?productId=${current.id}&type=${type}&qty=${qty}&ref=${encodeURIComponent(ref)}`,{method:"POST"})
    .then(()=>location.reload());
}
load();
</script>
<?php include "base_end.php"; ?>
EOF

# --- orders.php (link to detail) ---
cat > "${PHP}/orders.php" <<'EOF'
<?php include "base_start.php"; include "env.php"; ?>
<div class="d-flex justify-content-between align-items-center mb-3">
  <h3 class="m-0">Orders</h3>
  <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalNew"><i class="bi bi-plus-lg"></i> New</button>
</div>
<div class="card p-3">
  <table id="tbl" class="table table-striped" style="width:100%">
    <thead><tr><th>No</th><th>Customer</th><th>Date</th><th>Status</th><th>Total</th><th class="text-end">Open</th></tr></thead>
    <tbody></tbody>
  </table>
</div>

<div class="modal fade" id="modalNew" tabindex="-1"><div class="modal-dialog"><div class="modal-content">
  <div class="modal-header"><h5 class="modal-title">New Order</h5></div>
  <div class="modal-body"><form id="formNew">
    <div class="mb-2"><label>Customer</label><select class="form-select" name="customerId" id="cust"></select></div>
  </form></div>
  <div class="modal-footer">
    <button class="btn btn-outline-dark" data-bs-dismiss="modal">Cancel</button>
    <button class="btn btn-primary" onclick="createOrder()">Create</button>
  </div>
</div></div></div>

<script>
function load(){
  fetch("<?php echo $API_BASE; ?>/orders").then(r=>r.json()).then(rows=>{
    const tbody=document.querySelector("#tbl tbody");
    tbody.innerHTML=rows.map(o=>`<tr>
      <td>${o.orderNo}</td><td>${o.customer?o.customer.name:''}</td>
      <td>${o.orderDate?o.orderDate.substring(0,10):''}</td>
      <td>${o.status}</td>
      <td>${(o.lines||[]).reduce((a,l)=>a+l.quantity*l.unitPrice,0).toFixed(2)} ${o.currency}</td>
      <td class="text-end">
        <a class="btn btn-sm btn-outline-dark" href="order_view.php?id=${o.id}"><i class="bi bi-box-arrow-in-right"></i></a>
      </td>
    </tr>`).join("");
    new DataTable('#tbl');
  });
  fetch("<?php echo $API_BASE; ?>/customers").then(r=>r.json()).then(cs=>{
    const sel=document.getElementById('cust'); sel.innerHTML=cs.map(c=>`<option value="${c.id}">${c.name}</option>`).join("");
  });
}
function createOrder(){
  const id=document.getElementById('cust').value;
  fetch("<?php echo $API_BASE; ?>/orders?customerId="+id,{method:"POST"}).then(()=>location.reload());
}
load();
</script>
<?php include "base_end.php"; ?>
EOF

# --- order_view.php (detail: add lines + change status) ---
cat > "${PHP}/order_view.php" <<'EOF'
<?php include "base_start.php"; include "env.php";
$id = intval($_GET['id'] ?? 0);
?>
<div class="d-flex justify-content-between align-items-center mb-3">
  <h3 class="m-0" id="title">Order</h3>
  <a class="btn btn-outline-dark" href="orders.php"><i class="bi bi-arrow-left"></i> Back</a>
</div>

<div class="card p-3 mb-3">
  <div class="row">
    <div class="col-md-4"><strong>Customer:</strong> <span id="cust"></span></div>
    <div class="col-md-4"><strong>Date:</strong> <span id="date"></span></div>
    <div class="col-md-4"><strong>Status:</strong>
      <select id="status" class="form-select form-select-sm d-inline w-auto" onchange="setStatus()">
        <option>OPEN</option><option>PAID</option><option>SHIPPED</option><option>CANCELLED</option>
      </select>
    </div>
  </div>
</div>

<div class="card p-3 mb-3">
  <h5>Add Line</h5>
  <div class="row g-2">
    <div class="col-md-6"><select class="form-select" id="prod"></select></div>
    <div class="col-md-2"><input class="form-control" id="qty" placeholder="Qty" value="1"></div>
    <div class="col-md-2"><input class="form-control" id="price" placeholder="Price" value="0"></div>
    <div class="col-md-2"><button class="btn btn-primary w-100" onclick="addLine()">Add</button></div>
  </div>
</div>

<div class="card p-3">
  <h5>Lines</h5>
  <table class="table table-striped">
    <thead><tr><th>SKU</th><th>Product</th><th>Qty</th><th>Price</th><th>Subtotal</th></tr></thead>
    <tbody id="lines"></tbody>
  </table>
  <div class="text-end"><h4>Total: <span id="total">0.00</span> <span id="cur"></span></h4></div>
</div>

<script>
const API = "<?php echo $API_BASE; ?>";
const ID = <?php echo $id; ?>;
function load(){
  fetch(`${API}/orders/${ID}`).then(r=>r.json()).then(o=>{
    document.getElementById('title').textContent = `Order — ${o.orderNo}`;
    document.getElementById('cust').textContent = o.customer?o.customer.name:'';
    document.getElementById('date').textContent = (o.orderDate||'').substring(0,10);
    document.getElementById('status').value = o.status;
    document.getElementById('cur').textContent = o.currency;
    const tbody = document.getElementById('lines');
    tbody.innerHTML = (o.lines||[]).map(l=>`<tr>
      <td>${l.product?.sku||''}</td>
      <td>${l.product?.name||''}</td>
      <td>${l.quantity}</td>
      <td>${l.unitPrice.toFixed(2)}</td>
      <td>${(l.quantity*l.unitPrice).toFixed(2)}</td>
    </tr>`).join("");
    const total = (o.lines||[]).reduce((a,l)=>a+l.quantity*l.unitPrice,0);
    document.getElementById('total').textContent = total.toFixed(2);
  });
  fetch(`${API}/products`).then(r=>r.json()).then(ps=>{
    const sel=document.getElementById('prod'); sel.innerHTML=ps.map(p=>`<option value="${p.id}">${p.sku} — ${p.name}</option>`).join("");
  });
}
function addLine(){
  const p=document.getElementById('prod').value;
  const q=parseInt(document.getElementById('qty').value||0);
  const pr=parseFloat(document.getElementById('price').value||0);
  if(!p||!q) return alert("Product & qty required");
  fetch(`${API}/orders/${ID}/line?productId=${p}&qty=${q}&price=${pr}`,{method:"POST"}).then(load);
}
function setStatus(){
  const st=document.getElementById('status').value;
  fetch(`${API}/orders/${ID}/status?status=${st}`,{method:"POST"}).then(load);
}
load();
</script>
<?php include "base_end.php"; ?>
EOF

echo ">> Upgrade complete."