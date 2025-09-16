<?php
// sidebar.php — komponent i përbashkët i navigimit majtas (monokrom)
// Përdor bootstrap list-group. Vendos "active" tek linku aktual automatikisht.
$current = basename($_SERVER['PHP_SELF'] ?? '');
function active($files){ global $current; return in_array($current, $files, true) ? 'active' : ''; }
?>
<aside class="col-lg-3 mb-3">
  <div class="card p-0">
    <div class="list-group list-group-flush" id="sidebarNav">
      <div class="list-group-item fw-semibold">Sales</div>
      <a class="list-group-item list-group-item-action <?=active(['quotes.php'])?>" href="quotes.php"><i class="bi bi-file-earmark-text me-2"></i>Quotes</a>
      <a class="list-group-item list-group-item-action <?=active(['orders.php','order_view.php'])?>" href="orders.php"><i class="bi bi-bag-check me-2"></i>Sales Orders</a>
      <a class="list-group-item list-group-item-action <?=active(['ar_invoices.php'])?>" href="ar_invoices.php"><i class="bi bi-receipt me-2"></i>AR Invoices</a>

      <div class="list-group-item fw-semibold">Purchasing</div>
      <a class="list-group-item list-group-item-action <?=active(['vendors.php'])?>" href="vendors.php"><i class="bi bi-truck me-2"></i>Vendors</a>
      <a class="list-group-item list-group-item-action <?=active(['po.php'])?>" href="po.php"><i class="bi bi-bag-plus me-2"></i>PO</a>
      <a class="list-group-item list-group-item-action <?=active(['grn.php'])?>" href="grn.php"><i class="bi bi-box-arrow-in-down me-2"></i>GRN</a>
      <a class="list-group-item list-group-item-action <?=active(['ap_invoices.php'])?>" href="ap_invoices.php"><i class="bi bi-receipt-cutoff me-2"></i>AP Invoices</a>

      <div class="list-group-item fw-semibold">Inventory</div>
      <a class="list-group-item list-group-item-action <?=active(['products.php'])?>" href="products.php"><i class="bi bi-box-seam me-2"></i>Products</a>
      <a class="list-group-item list-group-item-action <?=active(['warehouses.php'])?>" href="warehouses.php"><i class="bi bi-building me-2"></i>Warehouses</a>
      <a class="list-group-item list-group-item-action <?=active(['stock_levels.php'])?>" href="stock_levels.php"><i class="bi bi-graph-up me-2"></i>Stock Levels</a>
      <a class="list-group-item list-group-item-action <?=active(['transfers.php'])?>" href="transfers.php"><i class="bi bi-arrow-left-right me-2"></i>Transfers</a>
      <a class="list-group-item list-group-item-action <?=active(['expired.php'])?>" href="expired.php"><i class="bi bi-exclamation-triangle me-2"></i>Expired</a>

      <div class="list-group-item fw-semibold">People & Finance</div>
      <a class="list-group-item list-group-item-action <?=active(['customers.php'])?>" href="customers.php"><i class="bi bi-person-badge me-2"></i>Customers</a>
      <a class="list-group-item list-group-item-action <?=active(['employees.php'])?>" href="employees.php"><i class="bi bi-people me-2"></i>Employees</a>
      <a class="list-group-item list-group-item-action <?=active(['payroll.php'])?>" href="payroll.php"><i class="bi bi-cash-coin me-2"></i>Payroll</a>
      <a class="list-group-item list-group-item-action <?=active(['expenses.php'])?>" href="expenses.php"><i class="bi bi-wallet2 me-2"></i>Expenses</a>

      <a class="list-group-item list-group-item-action <?=active(['index.php'])?>" href="index.php">
        <i class="bi bi-speedometer2 me-2"></i>Dashboard
      </a>
    </div>
  </div>
</aside>