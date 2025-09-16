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
