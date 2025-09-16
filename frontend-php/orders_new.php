<?php require_once "base_start.php"; require_once "env.php";
$alert='';
if($_SERVER['REQUEST_METHOD']==='POST'){
  $payload=[
    "customerId" => (int)($_POST['customerId'] ?? 1),
    "currency"   => $_POST['currency'] ?? "EUR",
    "lines"      => [[
      "productId" => (int)($_POST['productId'] ?? 1),
      "qty"       => max(1,(int)($_POST['qty'] ?? 1)),
      "unitPrice" => (float)($_POST['unitPrice'] ?? 0),
      "taxRate"   => (float)($_POST['taxRate'] ?? 0),
      "discount"  => (float)($_POST['discount'] ?? 0)
    ]]
  ];
  $ctx = stream_context_create(['http'=>[
    'method'=>'POST', 'header'=>"Content-Type: application/json\r\n",
    'content'=>json_encode($payload)
  ]]);
  $res = @file_get_contents($API_ORDERS,false,$ctx);
  if($res!==false){ header("Location: orders.php?msg=Created"); exit; }
  $alert="S’u krijua order. Kontrollo backend-in.";
}
?>
<div class="d-flex justify-content-between align-items-center mb-3">
  <h3 class="m-0">New Order</h3>
  <a href="orders.php" class="btn btn-outline-dark">Back</a>
</div>
<?php if($alert): ?><div class="alert alert-danger"><?=$alert?></div><?php endif; ?>
<form method="post" class="card p-3">
  <div class="row g-3">
    <div class="col-md-3"><label class="form-label">Customer ID</label>
      <input type="number" class="form-control" name="customerId" value="1" min="1" required></div>
    <div class="col-md-3"><label class="form-label">Currency</label>
      <input class="form-control" name="currency" value="EUR"></div>
    <div class="col-md-3"><label class="form-label">Product ID</label>
      <input type="number" class="form-control" name="productId" value="1" min="1" required></div>
    <div class="col-md-3"><label class="form-label">Qty</label>
      <input type="number" class="form-control" name="qty" value="1" min="1" required></div>
    <div class="col-md-3"><label class="form-label">Unit Price</label>
      <input type="number" step="0.01" class="form-control" name="unitPrice" value="99.90" min="0"></div>
    <div class="col-md-3"><label class="form-label">Tax %</label>
      <input type="number" step="0.01" class="form-control" name="taxRate" value="19"></div>
    <div class="col-md-3"><label class="form-label">Discount</label>
      <input type="number" step="0.01" class="form-control" name="discount" value="0"></div>
  </div>
  <div class="mt-3"><button class="btn btn-dark" type="submit"><i class="bi bi-check2-circle"></i> Create</button></div>
</form>
<?php include "base_end.php"; ?>
