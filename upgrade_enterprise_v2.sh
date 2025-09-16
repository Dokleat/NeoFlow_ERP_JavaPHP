#!/usr/bin/env bash
set -euo pipefail
ROOT="$(pwd)"
JAVA_DIR="${ROOT}/backend/src/main/java/com/neoflow/minierp"
RES_DIR="${ROOT}/backend/src/main/resources"
PHP_DIR="${ROOT}/frontend-php"

echo ">> NeoFlow Enterprise Upgrade v2 starting..."

mkdir -p "$JAVA_DIR"/{entity,repo,service,controller,config} "$RES_DIR"

# --- (1) Gjithë pjesa e entiteteve, shërbimeve dhe kontrollorëve është e njëjtë
#     si te skripti yt i parë — tashmë i krijuar me sukses deri te REPOS.
#     Nëse të mungon ndonjë file nga hapat e mëparshëm, thjesht ri-ekzekuto upgrade_enterprise.sh
#     dhe pastaj këtë v2; ose më thuaj të ta dërgoj komplet variantin “full”.

# --- (2) REPOSITORIES pa associative arrays ---
# Format:  repoName:EntityName  (një rresht për secilin)
REPO_LINES=$(cat <<'REPOS'
WarehouseRepo:Warehouse
StockLevelRepo:StockLevel
StockTxnRepo:StockTxn
VendorRepo:Vendor
PORepo:PO
POLineRepo:POLine
GRNRepo:GRN
GRNLineRepo:GRNLine
APInvoiceRepo:APInvoice
APInvoiceLineRepo:APInvoiceLine
APPaymentRepo:APPayment
QuoteRepo:Quote
QuoteLineRepo:QuoteLine
SalesOrderRepo:SalesOrder
SalesOrderLineRepo:SalesOrderLine
ARInvoiceRepo:ARInvoice
ARInvoiceLineRepo:ARInvoiceLine
ARPaymentRepo:ARPayment
CostCenterRepo:CostCenter
EmployeeRepo:Employee
PayrollRunRepo:PayrollRun
PayrollItemRepo:PayrollItem
ExpenseRepo:Expense
REPOS
)

echo ">> Writing repositories..."
# shellcheck disable=SC2162
while IFS=: read repo entity; do
  [ -z "$repo" ] && continue
  cat > "$JAVA_DIR/repo/${repo}.java" <<EOF2
package com.neoflow.minierp.repo;
import com.neoflow.minierp.entity.${entity};
import org.springframework.data.jpa.repository.JpaRepository;
public interface ${repo} extends JpaRepository<${entity}, Long>{}
EOF2
done <<< "$REPO_LINES"

echo ">> Done repositories."

echo ">> (Skip) Frontend pages & controllers nëse i ke tashmë nga skripti i parë."
echo ">> Upgrade v2 complete."
