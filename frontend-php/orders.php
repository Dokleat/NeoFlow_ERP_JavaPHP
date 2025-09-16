<?php include "base_start.php"; include "env.php"; ?>
<?php
function getOrders($api){
  try {
    $j = @file_get_contents($api);
    if($j!==false){ return json_decode($j,true) ?: []; }
  } catch(Throwable $e){}
  return [];
}
$orders = getOrders($API_ORDERS);

function badge($status){
  $map = [
    'DRAFT'     => 'secondary',
    'CONFIRMED' => 'dark',
    'FULFILLED' => 'primary',
    'INVOICED'  => 'warning',
    'CLOSED'    => 'success',
  ];
  $c = $map[$status] ?? 'secondary';
  return "<span class='badge text-bg-$c'>$status</span>";
}
?>
<div class="d-flex justify-content-between align-items-center mb-3">
  <h3 class="m-0">Orders</h3>
  <a class="btn btn-dark" href="orders_new.php"><i class="bi bi-plus-circle"></i> New Order</a>
</div>

<div class="card p-0">
  <div class="table-responsive">
    <table class="table table-striped align-middle mb-0">
      <thead>
        <tr>
          <th style="width:80px">ID</th>
          <th style="width:160px">Order No</th>
          <th>Customer</th>
          <th style="width:120px">Currency</th>
          <th style="width:140px">Status</th>
          <th style="width:120px" class="text-end">Lines</th>
          <th style="width:280px" class="text-end">Actions</th>
        </tr>
      </thead>
      <tbody>
      <?php if(empty($orders)): ?>
        <tr><td colspan="7" class="p-4"><div class="alert alert-warning m-0">No orders found.</div></td></tr>
      <?php else: foreach($orders as $o): 
        $id   = htmlspecialchars($o['id']);
        $no   = htmlspecialchars($o['orderNo'] ?? '-');
        $cust = htmlspecialchars($o['customerId'] ?? '-');
        $cur  = htmlspecialchars($o['currency'] ?? 'EUR');
        $st   = htmlspecialchars($o['status'] ?? 'DRAFT');
        $ln   = count($o['lines'] ?? []);
      ?>
        <tr>
          <td><?= $id ?></td>
          <td><?= $no ?></td>
          <td><?= $cust ?></td>
          <td><?= $cur ?></td>
          <td><?= badge($st) ?></td>
          <td class="text-end"><?= $ln ?></td>
          <td class="text-end">
            <div class="btn-group btn-group-sm" role="group">
              <?php if($st==='DRAFT'): ?>
                <form method="post" action="order_action.php" class="d-inline">
                  <input type="hidden" name="id" value="<?=$id?>">
                  <input type="hidden" name="action" value="confirm">
                  <button class="btn btn-outline-dark">Confirm</button>
                </form>
                <form method="post" action="order_action.php" class="d-inline" onsubmit="return confirm('Delete order #<?=$id?>?')">
                  <input type="hidden" name="id" value="<?=$id?>">
                  <input type="hidden" name="action" value="delete">
                  <button class="btn btn-outline-danger">Delete</button>
                </form>
              <?php elseif($st==='CONFIRMED'): ?>
                <form method="post" action="order_action.php" class="d-inline">
                  <input type="hidden" name="id" value="<?=$id?>">
                  <input type="hidden" name="action" value="fulfill">
                  <button class="btn btn-outline-dark">Fulfill</button>
                </form>
              <?php elseif($st==='FULFILLED'): ?>
                <form method="post" action="order_action.php" class="d-inline">
                  <input type="hidden" name="id" value="<?=$id?>">
                  <input type="hidden" name="action" value="invoice">
                  <button class="btn btn-outline-dark">Invoice</button>
                </form>
              <?php elseif($st==='INVOICED'): ?>
                <form method="post" action="order_action.php" class="d-inline">
                  <input type="hidden" name="id" value="<?=$id?>">
                  <input type="hidden" name="action" value="close">
                  <button class="btn btn-outline-dark">Close</button>
                </form>
              <?php else: ?>
                <button class="btn btn-outline-secondary" disabled>Closed</button>
              <?php endif; ?>
            </div>
          </td>
        </tr>
      <?php endforeach; endif; ?>
      </tbody>
    </table>
  </div>
</div>

<?php if(isset($_GET['msg'])): ?>
  <div class="alert alert-info mt-3"><?= htmlspecialchars($_GET['msg']) ?></div>
<?php endif; ?>

<?php include "base_end.php"; ?>
