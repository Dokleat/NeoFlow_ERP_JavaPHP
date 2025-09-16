<?php include "base_start.php"; include "env.php"; ?>
<div class="row">
  <?php include "sidebar.php"; ?>

  <section class="col-lg-9">
    <div class="d-flex align-items-center justify-content-between mb-3">
      <h3 class="m-0">Products</h3>
      <div>
        <button class="btn btn-sm btn-outline-dark me-2" id="btnRefresh"><i class="bi bi-arrow-clockwise"></i> Refresh</button>
        <button class="btn btn-sm btn-primary" id="btnNew"
        data-bs-toggle="modal" data-bs-target="#prodModal">
  <i class="bi bi-plus-circle"></i> New Product
</button>
      </div>
    </div>

    <!-- Alerts -->
    <div id="alertArea"></div>

    <div class="card p-3">
      <div class="table-responsive">
        <table class="table table-striped align-middle" id="tbl">
          <thead>
            <tr>
              <th style="min-width:100px">SKU</th>
              <th>Name</th>
              <th class="text-end" style="min-width:120px">Unit Price</th>
              <th class="text-end" style="min-width:120px">Min Stock</th>
              <th class="text-end" style="min-width:120px">On Hand</th>
              <th style="min-width:140px"></th>
            </tr>
          </thead>
          <tbody id="rows"></tbody>
        </table>
      </div>
    </div>
  </section>
</div>

<!-- Modal: Create/Edit -->
<div class="modal fade" id="prodModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-scrollable">
    <form class="modal-content" id="prodForm">
      <div class="modal-header">
        <h5 class="modal-title" id="prodTitle">New Product</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="prodId">
        <div class="mb-3">
          <label class="form-label">SKU</label>
          <input class="form-control" id="sku" required maxlength="64" placeholder="e.g. P-1001">
        </div>
        <div class="mb-3">
          <label class="form-label">Name</label>
          <input class="form-control" id="name" required maxlength="160" placeholder="Product name">
        </div>
        <div class="row g-2">
          <div class="col-md-4">
            <label class="form-label">Unit Price</label>
            <input type="number" step="0.01" min="0" class="form-control" id="unitPrice" required>
          </div>
          <div class="col-md-4">
            <label class="form-label">Min Stock</label>
            <input type="number" step="1" min="0" class="form-control" id="minStock" value="0">
          </div>
          <div class="col-md-4">
            <label class="form-label">Tax % (optional)</label>
            <input type="number" step="0.01" min="0" class="form-control" id="taxRate" placeholder="e.g. 19">
          </div>
        </div>
        <div class="form-text mt-2">On Hand llogaritet nga lëvizjet e stokut; nuk vendoset këtu.</div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-outline-dark" type="button" data-bs-dismiss="modal">Cancel</button>
        <button class="btn btn-primary" type="submit" id="btnSave"><i class="bi bi-check2-circle"></i> Save</button>
      </div>
    </form>
  </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', () => {
  const API = "<?php echo $API_BASE; ?>";
  const rowsEl = document.getElementById('rows');
  const alertArea = document.getElementById('alertArea');
  const prodModalEl = document.getElementById('prodModal');
  if (!prodModalEl) { console.error('prodModal nuk u gjet'); return; }
  const prodModal = new bootstrap.Modal(prodModalEl);

  function money(v){ const n = Number(v||0); return n.toLocaleString(undefined,{minimumFractionDigits:2, maximumFractionDigits:2}); }
  function intf(v){ return Number(v||0).toLocaleString(); }
  function showAlert(type, msg){
    alertArea.innerHTML = `<div class="alert alert-${type} alert-dismissible fade show" role="alert">
      ${msg}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>`;
  }
  async function j(url, opts={}){
    const r = await fetch(url, opts);
    if(!r.ok){ let t=''; try{t = await r.text();}catch(_){}; throw new Error(`${r.status} ${r.statusText} ${t}`); }
    const ct = r.headers.get('content-type')||''; return ct.includes('application/json')? r.json(): r.text();
  }

  async function loadProducts(){
    rowsEl.innerHTML = `<tr><td colspan="6" class="text-center py-4">Loading…</td></tr>`;
    try{
      const data = await j(`${API}/products`);
      if(!Array.isArray(data) || data.length===0){
        rowsEl.innerHTML = `<tr><td colspan="6" class="text-center py-4">No products yet</td></tr>`; return;
      }
      rowsEl.innerHTML = data.map(p=>`
        <tr>
          <td>${p.sku||''}</td>
          <td>${p.name||''}</td>
          <td class="text-end">${money(p.unitPrice)}</td>
          <td class="text-end">${intf(p.minStock)}</td>
          <td class="text-end">${intf(p.stockQty)}</td>
          <td class="text-end">
            <button class="btn btn-sm btn-outline-dark me-2" onclick='openEdit(${JSON.stringify(p).replaceAll("'","&apos;")})'>
              <i class="bi bi-pencil-square"></i>
            </button>
            <button class="btn btn-sm btn-outline-dark" onclick="deleteProduct(${p.id})"><i class="bi bi-trash3"></i></button>
          </td>
        </tr>
      `).join('');
    }catch(e){
      rowsEl.innerHTML = `<tr><td colspan="6" class="text-danger py-4">${e.message}</td></tr>`;
    }
  }

  // Kur hapet modali nga butoni “New Product”, reseto fushat automatikisht
  prodModalEl.addEventListener('show.bs.modal', (ev) => {
    // nëse klikohet “Edit”, ne e mbushim manualisht; për “New” e pastrojmë
    if (document.getElementById('prodTitle').textContent === 'New Product') {
      document.getElementById('prodId').value = '';
      document.getElementById('sku').value = '';
      document.getElementById('name').value = '';
      document.getElementById('unitPrice').value = '';
      document.getElementById('minStock').value = '0';
      document.getElementById('taxRate').value = '';
    }
  });

  // Butoni Refresh
  document.getElementById('btnRefresh').addEventListener('click', loadProducts);

  // Nëse dëshiron programatikisht “New”, vendos edhe këtë (opsionale)
  document.getElementById('btnNew').addEventListener('click', () => {
    document.getElementById('prodTitle').textContent = 'New Product';
    // Bootstrap do ta hapë modalin sepse kemi data-bs-toggle/data-bs-target
  });

  // Submit i formas (Create/Update)
  document.getElementById('prodForm').addEventListener('submit', async (ev)=>{
    ev.preventDefault();
    const id = document.getElementById('prodId').value.trim();
    const body = {
      sku: document.getElementById('sku').value.trim(),
      name: document.getElementById('name').value.trim(),
      unitPrice: parseFloat(document.getElementById('unitPrice').value||0),
      minStock: parseInt(document.getElementById('minStock').value||0),
      taxRate: document.getElementById('taxRate').value===''? null : parseFloat(document.getElementById('taxRate').value)
    };
    if(!body.sku || !body.name){ showAlert('warning','SKU dhe Name janë të detyrueshme.'); return; }

    try{
      if(id){
        await j(`${API}/products/${id}`, { method:'PUT', headers:{'Content-Type':'application/json'}, body: JSON.stringify(body) });
        showAlert('success', `Product <strong>${body.sku}</strong> u përditësua.`);
      }else{
        await j(`${API}/products`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(body) });
        showAlert('success', `Product <strong>${body.sku}</strong> u krijua.`);
      }
      bootstrap.Modal.getInstance(prodModalEl).hide();
      loadProducts();
    }catch(e){
      showAlert('danger', `Gabim: ${e.message}`);
    }
  });
function openEdit(p){
  // vendos titullin "Edit"
  document.getElementById('prodTitle').textContent = 'Edit Product';

  // mbush fushat
  document.getElementById('prodId').value = p.id || '';
  document.getElementById('sku').value = p.sku || '';
  document.getElementById('name').value = p.name || '';
  document.getElementById('unitPrice').value = p.unitPrice ?? 0;
  document.getElementById('minStock').value = p.minStock ?? 0;
  document.getElementById('taxRate').value = (p.taxRate != null ? p.taxRate : '');

  // hape modalin
  const m = bootstrap.Modal.getOrCreateInstance(document.getElementById('prodModal'));
  m.show();
}
// >>> kjo është kritike që onclick në buton ta gjejë funksionin:
window.openEdit = openEdit;
  // Delete
  async function deleteProduct(id){
    if(!id) return;
    if(!confirm('A je i sigurt që do ta fshish këtë produkt?')) return;
    try{ await j(`${API}/products/${id}`, { method:'DELETE' }); showAlert('success','U fshi me sukses.'); loadProducts(); }
    catch(e){ showAlert('danger', `S’u fshi: ${e.message}`); }
  }
  window.deleteProduct = deleteProduct;

  // Start
  loadProducts();
});
</script>

<?php include "base_end.php"; ?>