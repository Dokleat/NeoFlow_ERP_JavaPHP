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
