#!/usr/bin/env bash
set -euo pipefail
ROOT="$(pwd)"
JAVA_DIR="${ROOT}/backend/src/main/java/com/neoflow/minierp"
RES_DIR="${ROOT}/backend/src/main/resources"
PHP_DIR="${ROOT}/frontend-php"

echo ">> NeoFlow Enterprise Upgrade starting..."

# ───────────────────────────────── BACKEND ─────────────────────────────────

mkdir -p "$JAVA_DIR/{entity,repo,service,controller,config}"
mkdir -p "$RES_DIR"

# ====== ENTITIES ======
cat > "$JAVA_DIR/entity/Warehouse.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*;
@Entity
public class Warehouse {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @Column(unique=true) private String code;
  private String name; private String location;
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public String getCode(){return code;} public void setCode(String code){this.code=code;}
  public String getName(){return name;} public void setName(String name){this.name=name;}
  public String getLocation(){return location;} public void setLocation(String l){this.location=l;}
}
EOF

cat > "$JAVA_DIR/entity/StockLevel.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*;
@Entity
@Table(uniqueConstraints=@UniqueConstraint(columnNames={"product_id","warehouse_id"}))
public class StockLevel {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne(optional=false) private Product product;
  @ManyToOne(optional=false) private Warehouse warehouse;
  private int onHand; private int reserved;
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public Product getProduct(){return product;} public void setProduct(Product p){this.product=p;}
  public Warehouse getWarehouse(){return warehouse;} public void setWarehouse(Warehouse w){this.warehouse=w;}
  public int getOnHand(){return onHand;} public void setOnHand(int v){this.onHand=v;}
  public int getReserved(){return reserved;} public void setReserved(int v){this.reserved=v;}
}
EOF

cat > "$JAVA_DIR/entity/StockTxn.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate;
@Entity
public class StockTxn {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private Product product; @ManyToOne private Warehouse warehouse;
  private int qty; private String type; // IN, OUT, TRANSFER_IN, TRANSFER_OUT, ADJUST
  private String refDoc; private String lot; private LocalDate expiryDate; private LocalDate date=LocalDate.now();
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public Product getProduct(){return product;} public void setProduct(Product p){this.product=p;}
  public Warehouse getWarehouse(){return warehouse;} public void setWarehouse(Warehouse w){this.warehouse=w;}
  public int getQty(){return qty;} public void setQty(int q){this.qty=q;}
  public String getType(){return type;} public void setType(String t){this.type=t;}
  public String getRefDoc(){return refDoc;} public void setRefDoc(String r){this.refDoc=r;}
  public String getLot(){return lot;} public void setLot(String l){this.lot=l;}
  public LocalDate getExpiryDate(){return expiryDate;} public void setExpiryDate(LocalDate d){this.expiryDate=d;}
  public LocalDate getDate(){return date;} public void setDate(LocalDate d){this.date=d;}
}
EOF

cat > "$JAVA_DIR/entity/Vendor.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*;
@Entity
public class Vendor {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  private String name; private String email; private String phone;
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public String getName(){return name;} public void setName(String name){this.name=name;}
  public String getEmail(){return email;} public void setEmail(String email){this.email=email;}
  public String getPhone(){return phone;} public void setPhone(String phone){this.phone=phone;}
}
EOF

cat > "$JAVA_DIR/entity/PO.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate; import java.util.*;
@Entity
public class PO {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @Column(unique=true) private String poNo;
  @ManyToOne private Vendor vendor; private LocalDate date=LocalDate.now(); private String status="OPEN";
  @OneToMany(mappedBy="po", cascade=CascadeType.ALL, orphanRemoval=true) private List<POLine> lines=new ArrayList<>();
  public double getTotal(){ return lines.stream().mapToDouble(l->l.getQty()*l.getPrice()).sum(); }
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public String getPoNo(){return poNo;} public void setPoNo(String s){this.poNo=s;}
  public Vendor getVendor(){return vendor;} public void setVendor(Vendor v){this.vendor=v;}
  public LocalDate getDate(){return date;} public void setDate(LocalDate d){this.date=d;}
  public String getStatus(){return status;} public void setStatus(String s){this.status=s;}
  public List<POLine> getLines(){return lines;} public void setLines(List<POLine> ls){this.lines=ls;}
}
EOF

cat > "$JAVA_DIR/entity/POLine.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*;
@Entity
public class POLine {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private PO po; @ManyToOne private Product product;
  private int qty; private double price; private String lot; private java.time.LocalDate expiry;
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public PO getPo(){return po;} public void setPo(PO p){this.po=p;}
  public Product getProduct(){return product;} public void setProduct(Product p){this.product=p;}
  public int getQty(){return qty;} public void setQty(int q){this.qty=q;}
  public double getPrice(){return price;} public void setPrice(double p){this.price=p;}
  public String getLot(){return lot;} public void setLot(String l){this.lot=l;}
  public java.time.LocalDate getExpiry(){return expiry;} public void setExpiry(java.time.LocalDate e){this.expiry=e;}
}
EOF

cat > "$JAVA_DIR/entity/GRN.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate; import java.util.*;
@Entity
public class GRN {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private PO po; @ManyToOne private Vendor vendor;
  private LocalDate date=LocalDate.now(); private String status="OPEN"; @ManyToOne private Warehouse warehouse;
  @OneToMany(mappedBy="grn", cascade=CascadeType.ALL, orphanRemoval=true) private List<GRNLine> lines=new ArrayList<>();
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public PO getPo(){return po;} public void setPo(PO p){this.po=p;}
  public Vendor getVendor(){return vendor;} public void setVendor(Vendor v){this.vendor=v;}
  public Warehouse getWarehouse(){return warehouse;} public void setWarehouse(Warehouse w){this.warehouse=w;}
  public LocalDate getDate(){return date;} public void setDate(LocalDate d){this.date=d;}
  public String getStatus(){return status;} public void setStatus(String s){this.status=s;}
  public List<GRNLine> getLines(){return lines;} public void setLines(List<GRNLine> ls){this.lines=ls;}
}
EOF

cat > "$JAVA_DIR/entity/GRNLine.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*;
@Entity
public class GRNLine {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private GRN grn; @ManyToOne private Product product;
  private int qty; private double price; private String lot; private java.time.LocalDate expiry;
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public GRN getGrn(){return grn;} public void setGrn(GRN g){this.grn=g;}
  public Product getProduct(){return product;} public void setProduct(Product p){this.product=p;}
  public int getQty(){return qty;} public void setQty(int q){this.qty=q;}
  public double getPrice(){return price;} public void setPrice(double p){this.price=p;}
  public String getLot(){return lot;} public void setLot(String l){this.lot=l;}
  public java.time.LocalDate getExpiry(){return expiry;} public void setExpiry(java.time.LocalDate e){this.expiry=e;}
}
EOF

cat > "$JAVA_DIR/entity/APInvoice.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate; import java.util.*;
@Entity
public class APInvoice {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private Vendor vendor; private LocalDate date=LocalDate.now(); private String status="DRAFT"; private String currency="EUR";
  @OneToMany(mappedBy="invoice", cascade=CascadeType.ALL, orphanRemoval=true) private List<APInvoiceLine> lines=new ArrayList<>();
  public double getTotal(){ return lines.stream().mapToDouble(l->l.getQty()*l.getPrice()).sum(); }
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public Vendor getVendor(){return vendor;} public void setVendor(Vendor v){this.vendor=v;}
  public LocalDate getDate(){return date;} public void setDate(LocalDate d){this.date=d;}
  public String getStatus(){return status;} public void setStatus(String s){this.status=s;}
  public String getCurrency(){return currency;} public void setCurrency(String c){this.currency=c;}
  public List<APInvoiceLine> getLines(){return lines;} public void setLines(List<APInvoiceLine> ls){this.lines=ls;}
}
EOF

cat > "$JAVA_DIR/entity/APInvoiceLine.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*;
@Entity
public class APInvoiceLine {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private APInvoice invoice; @ManyToOne private Product product;
  private int qty; private double price;
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public APInvoice getInvoice(){return invoice;} public void setInvoice(APInvoice i){this.invoice=i;}
  public Product getProduct(){return product;} public void setProduct(Product p){this.product=p;}
  public int getQty(){return qty;} public void setQty(int q){this.qty=q;}
  public double getPrice(){return price;} public void setPrice(double p){this.price=p;}
}
EOF

cat > "$JAVA_DIR/entity/APPayment.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate;
@Entity
public class APPayment {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private APInvoice invoice; private double amount; private LocalDate date=LocalDate.now(); private String method="TRF";
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public APInvoice getInvoice(){return invoice;} public void setInvoice(APInvoice i){this.invoice=i;}
  public double getAmount(){return amount;} public void setAmount(double a){this.amount=a;}
  public LocalDate getDate(){return date;} public void setDate(LocalDate d){this.date=d;}
  public String getMethod(){return method;} public void setMethod(String m){this.method=m;}
}
EOF

cat > "$JAVA_DIR/entity/Quote.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate; import java.util.*;
@Entity
public class Quote {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private Customer customer; private LocalDate date=LocalDate.now(); private String status="DRAFT"; private String currency="EUR";
  @OneToMany(mappedBy="quote", cascade=CascadeType.ALL, orphanRemoval=true) private List<QuoteLine> lines=new ArrayList<>();
  public double getTotal(){ return lines.stream().mapToDouble(l->l.getQty()*l.getPrice()).sum(); }
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public Customer getCustomer(){return customer;} public void setCustomer(Customer c){this.customer=c;}
  public LocalDate getDate(){return date;} public void setDate(LocalDate d){this.date=d;}
  public String getStatus(){return status;} public void setStatus(String s){this.status=s;}
  public String getCurrency(){return currency;} public void setCurrency(String c){this.currency=c;}
  public List<QuoteLine> getLines(){return lines;} public void setLines(List<QuoteLine> ls){this.lines=ls;}
}
EOF

cat > "$JAVA_DIR/entity/QuoteLine.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*;
@Entity
public class QuoteLine {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private Quote quote; @ManyToOne private Product product;
  private int qty; private double price; private double discount; // %
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public Quote getQuote(){return quote;} public void setQuote(Quote q){this.quote=q;}
  public Product getProduct(){return product;} public void setProduct(Product p){this.product=p;}
  public int getQty(){return qty;} public void setQty(int q){this.qty=q;}
  public double getPrice(){return price;} public void setPrice(double p){this.price=p;}
  public double getDiscount(){return discount;} public void setDiscount(double d){this.discount=d;}
}
EOF

cat > "$JAVA_DIR/entity/SalesOrder.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate; import java.util.*;
@Entity @Table(name="sales_order")
public class SalesOrder {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @Column(unique=true) private String soNo;
  @ManyToOne private Customer customer; private LocalDate date=LocalDate.now(); private String status="OPEN"; private String currency="EUR";
  @OneToMany(mappedBy="order", cascade=CascadeType.ALL, orphanRemoval=true) private List<SalesOrderLine> lines=new ArrayList<>();
  public double getTotal(){ return lines.stream().mapToDouble(l->l.getQty()*l.getPrice()).sum(); }
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public String getSoNo(){return soNo;} public void setSoNo(String s){this.soNo=s;}
  public Customer getCustomer(){return customer;} public void setCustomer(Customer c){this.customer=c;}
  public LocalDate getDate(){return date;} public void setDate(LocalDate d){this.date=d;}
  public String getStatus(){return status;} public void setStatus(String s){this.status=s;}
  public String getCurrency(){return currency;} public void setCurrency(String c){this.currency=c;}
  public List<SalesOrderLine> getLines(){return lines;} public void setLines(List<SalesOrderLine> ls){this.lines=ls;}
}
EOF

cat > "$JAVA_DIR/entity/SalesOrderLine.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*;
@Entity
public class SalesOrderLine {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private SalesOrder order; @ManyToOne private Product product;
  private int qty; private double price; private double discount;
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public SalesOrder getOrder(){return order;} public void setOrder(SalesOrder o){this.order=o;}
  public Product getProduct(){return product;} public void setProduct(Product p){this.product=p;}
  public int getQty(){return qty;} public void setQty(int q){this.qty=q;}
  public double getPrice(){return price;} public void setPrice(double p){this.price=p;}
  public double getDiscount(){return discount;} public void setDiscount(double d){this.discount=d;}
}
EOF

cat > "$JAVA_DIR/entity/ARInvoice.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate; import java.util.*;
@Entity
public class ARInvoice {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private Customer customer; private LocalDate date=LocalDate.now(); private String status="DRAFT"; private String currency="EUR";
  @OneToMany(mappedBy="invoice", cascade=CascadeType.ALL, orphanRemoval=true) private List<ARInvoiceLine> lines=new ArrayList<>();
  public double getTotal(){ return lines.stream().mapToDouble(l->l.getQty()*l.getPrice()).sum(); }
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public Customer getCustomer(){return customer;} public void setCustomer(Customer c){this.customer=c;}
  public LocalDate getDate(){return date;} public void setDate(LocalDate d){this.date=d;}
  public String getStatus(){return status;} public void setStatus(String s){this.status=s;}
  public String getCurrency(){return currency;} public void setCurrency(String c){this.currency=c;}
  public List<ARInvoiceLine> getLines(){return lines;} public void setLines(List<ARInvoiceLine> ls){this.lines=ls;}
}
EOF

cat > "$JAVA_DIR/entity/ARInvoiceLine.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*;
@Entity
public class ARInvoiceLine {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private ARInvoice invoice; @ManyToOne private Product product;
  private int qty; private double price; private double discount;
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public ARInvoice getInvoice(){return invoice;} public void setInvoice(ARInvoice i){this.invoice=i;}
  public Product getProduct(){return product;} public void setProduct(Product p){this.product=p;}
  public int getQty(){return qty;} public void setQty(int q){this.qty=q;}
  public double getPrice(){return price;} public void setPrice(double p){this.price=p;}
  public double getDiscount(){return discount;} public void setDiscount(double d){this.discount=d;}
}
EOF

cat > "$JAVA_DIR/entity/ARPayment.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate;
@Entity
public class ARPayment {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private ARInvoice invoice; private double amount; private LocalDate date=LocalDate.now(); private String method="TRF";
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public ARInvoice getInvoice(){return invoice;} public void setInvoice(ARInvoice i){this.invoice=i;}
  public double getAmount(){return amount;} public void setAmount(double a){this.amount=a;}
  public LocalDate getDate(){return date;} public void setDate(LocalDate d){this.date=d;}
  public String getMethod(){return method;} public void setMethod(String m){this.method=m;}
}
EOF

cat > "$JAVA_DIR/entity/CostCenter.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*;
@Entity
public class CostCenter {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @Column(unique=true) private String code; private String name;
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public String getCode(){return code;} public void setCode(String code){this.code=code;}
  public String getName(){return name;} public void setName(String name){this.name=name;}
}
EOF

cat > "$JAVA_DIR/entity/Employee.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate;
@Entity
public class Employee {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  private String name; private String position; private LocalDate hireDate=LocalDate.now(); private String currency="EUR"; private double salaryBase;
  @ManyToOne private CostCenter costCenter; private boolean active=true;
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public String getName(){return name;} public void setName(String name){this.name=name;}
  public String getPosition(){return position;} public void setPosition(String p){this.position=p;}
  public LocalDate getHireDate(){return hireDate;} public void setHireDate(LocalDate d){this.hireDate=d;}
  public String getCurrency(){return currency;} public void setCurrency(String c){this.currency=c;}
  public double getSalaryBase(){return salaryBase;} public void setSalaryBase(double s){this.salaryBase=s;}
  public CostCenter getCostCenter(){return costCenter;} public void setCostCenter(CostCenter c){this.costCenter=c;}
  public boolean isActive(){return active;} public void setActive(boolean a){this.active=a;}
}
EOF

cat > "$JAVA_DIR/entity/PayrollRun.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate; import java.util.*;
@Entity
public class PayrollRun {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  private LocalDate periodStart; private LocalDate periodEnd; private boolean posted=false;
  @OneToMany(mappedBy="run", cascade=CascadeType.ALL, orphanRemoval=true) private List<PayrollItem> items=new ArrayList<>();
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public LocalDate getPeriodStart(){return periodStart;} public void setPeriodStart(LocalDate d){this.periodStart=d;}
  public LocalDate getPeriodEnd(){return periodEnd;} public void setPeriodEnd(LocalDate d){this.periodEnd=d;}
  public boolean isPosted(){return posted;} public void setPosted(boolean p){this.posted=p;}
  public List<PayrollItem> getItems(){return items;} public void setItems(List<PayrollItem> ls){this.items=ls;}
}
EOF

cat > "$JAVA_DIR/entity/PayrollItem.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*; 
@Entity
public class PayrollItem {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private PayrollRun run; @ManyToOne private Employee employee;
  private String type; // BASIC|OVERTIME|BONUS|DEDUCTION|TAX
  private double amount; private String note;
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public PayrollRun getRun(){return run;} public void setRun(PayrollRun r){this.run=r;}
  public Employee getEmployee(){return employee;} public void setEmployee(Employee e){this.employee=e;}
  public String getType(){return type;} public void setType(String t){this.type=t;}
  public double getAmount(){return amount;} public void setAmount(double a){this.amount=a;}
  public String getNote(){return note;} public void setNote(String n){this.note=n;}
}
EOF

cat > "$JAVA_DIR/entity/Expense.java" <<'EOF'
package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate;
@Entity
public class Expense {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  private LocalDate date=LocalDate.now(); private String category; private String currency="EUR";
  private double amount; private double tax; private String status="DRAFT"; private String vendorText;
  @ManyToOne private Employee employee; @ManyToOne private CostCenter costCenter;
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public LocalDate getDate(){return date;} public void setDate(LocalDate d){this.date=d;}
  public String getCategory(){return category;} public void setCategory(String c){this.category=c;}
  public String getCurrency(){return currency;} public void setCurrency(String c){this.currency=c;}
  public double getAmount(){return amount;} public void setAmount(double a){this.amount=a;}
  public double getTax(){return tax;} public void setTax(double t){this.tax=t;}
  public String getStatus(){return status;} public void setStatus(String s){this.status=s;}
  public String getVendorText(){return vendorText;} public void setVendorText(String v){this.vendorText=v;}
  public Employee getEmployee(){return employee;} public void setEmployee(Employee e){this.employee=e;}
  public CostCenter getCostCenter(){return costCenter;} public void setCostCenter(CostCenter c){this.costCenter=c;}
}
EOF

# ====== REPOSITORIES ======
declare -A REPOS=(
  [WarehouseRepo]="Warehouse"
  [StockLevelRepo]="StockLevel"
  [StockTxnRepo]="StockTxn"
  [VendorRepo]="Vendor"
  [PORepo]="PO"
  [POLineRepo]="POLine"
  [GRNRepo]="GRN"
  [GRNLineRepo]="GRNLine"
  [APInvoiceRepo]="APInvoice"
  [APInvoiceLineRepo]="APInvoiceLine"
  [APPaymentRepo]="APPayment"
  [QuoteRepo]="Quote"
  [QuoteLineRepo]="QuoteLine"
  [SalesOrderRepo]="SalesOrder"
  [SalesOrderLineRepo]="SalesOrderLine"
  [ARInvoiceRepo]="ARInvoice"
  [ARInvoiceLineRepo]="ARInvoiceLine"
  [ARPaymentRepo]="ARPayment"
  [CostCenterRepo]="CostCenter"
  [EmployeeRepo]="Employee"
  [PayrollRunRepo]="PayrollRun"
  [PayrollItemRepo]="PayrollItem"
  [ExpenseRepo]="Expense"
)
for repo in "${!REPOS[@]}"; do
cat > "$JAVA_DIR/repo/${repo}.java" <<EOF
package com.neoflow.minierp.repo;
import com.neoflow.minierp.entity.${REPOS[$repo]}; import org.springframework.data.jpa.repository.JpaRepository;
public interface ${repo} extends JpaRepository<${REPOS[$repo]}, Long>{}
EOF
done

# ====== SERVICES (StockService) ======
cat > "$JAVA_DIR/service/StockService.java" <<'EOF'
package com.neoflow.minierp.service;
import org.springframework.stereotype.Service; import org.springframework.transaction.annotation.Transactional;
import com.neoflow.minierp.repo.*; import com.neoflow.minierp.entity.*; import java.time.LocalDate;
@Service
public class StockService {
  private final ProductRepo productRepo; private final WarehouseRepo whRepo; private final StockLevelRepo levelRepo; private final StockTxnRepo txnRepo;
  public StockService(ProductRepo p, WarehouseRepo w, StockLevelRepo l, StockTxnRepo t){ this.productRepo=p; this.whRepo=w; this.levelRepo=l; this.txnRepo=t; }

  @Transactional
  public void apply(Long productId, Long whId, int delta, String type, String ref, String lot, LocalDate expiry){
    Product p = productRepo.findById(productId).orElseThrow();
    Warehouse w = whRepo.findById(whId).orElseThrow();
    StockLevel lvl = levelRepo.findAll().stream()
      .filter(s->s.getProduct().getId().equals(productId) && s.getWarehouse().getId().equals(whId))
      .findFirst().orElseGet(()->{ StockLevel s=new StockLevel(); s.setProduct(p); s.setWarehouse(w); s.setOnHand(0); s.setReserved(0); return levelRepo.save(s); });
    lvl.setOnHand(lvl.getOnHand()+delta); levelRepo.save(lvl);
    StockTxn tx = new StockTxn(); tx.setProduct(p); tx.setWarehouse(w); tx.setQty(Math.abs(delta)); tx.setType(type); tx.setRefDoc(ref); tx.setLot(lot); tx.setExpiryDate(expiry);
    txnRepo.save(tx);
  }

  @Transactional
  public void transfer(Long productId, Long fromWh, Long toWh, int qty, String ref){
    apply(productId, fromWh, -qty, "TRANSFER_OUT", ref, null, null);
    apply(productId, toWh,   qty, "TRANSFER_IN",  ref, null, null);
  }
}
EOF

# ====== CONTROLLERS ======
cat > "$JAVA_DIR/controller/WarehouseController.java" <<'EOF'
package com.neoflow.minierp.controller;
import com.neoflow.minierp.entity.*; import com.neoflow.minierp.repo.*;
import org.springframework.web.bind.annotation.*; import java.util.*; 
@RestController @RequestMapping("/api/warehouses")
public class WarehouseController {
  private final WarehouseRepo repo; public WarehouseController(WarehouseRepo r){this.repo=r;}
  @GetMapping public List<Warehouse> all(){return repo.findAll();}
  @PostMapping public Warehouse create(@RequestBody Warehouse w){return repo.save(w);}
  @PutMapping("/{id}") public Warehouse update(@PathVariable Long id,@RequestBody Warehouse w){w.setId(id); return repo.save(w);}
  @DeleteMapping("/{id}") public void delete(@PathVariable Long id){repo.deleteById(id);}
}
EOF

cat > "$JAVA_DIR/controller/StockController.java" <<'EOF'
package com.neoflow.minierp.controller;
import com.neoflow.minierp.entity.*; import com.neoflow.minierp.repo.*; import com.neoflow.minierp.service.StockService;
import org.springframework.web.bind.annotation.*; import java.time.LocalDate; import java.util.*; 
@RestController @RequestMapping("/api/stock")
public class StockController {
  private final StockLevelRepo levelRepo; private final StockTxnRepo txnRepo; private final StockService stockSvc;
  public StockController(StockLevelRepo l, StockTxnRepo t, StockService s){this.levelRepo=l; this.txnRepo=t; this.stockSvc=s;}
  @GetMapping("/levels") public List<StockLevel> levels(){return levelRepo.findAll();}
  @GetMapping("/txns") public List<StockTxn> txns(){return txnRepo.findAll();}
  @PostMapping("/move") public void move(@RequestParam Long productId,@RequestParam Long warehouseId,@RequestParam String type,@RequestParam int qty,
                                        @RequestParam(required=false) String ref,@RequestParam(required=false) String lot,
                                        @RequestParam(required=false) String expiry){
    int delta = ("IN".equals(type)||"TRANSFER_IN".equals(type))? qty : -qty;
    stockSvc.apply(productId, warehouseId, delta, type, ref, lot, expiry==null?null:LocalDate.parse(expiry));
  }
  @PostMapping("/transfer") public void transfer(@RequestParam Long productId,@RequestParam Long fromWh,@RequestParam Long toWh,@RequestParam int qty,@RequestParam String ref){
    stockSvc.transfer(productId, fromWh, toWh, qty, ref);
  }
  @GetMapping("/expired") public List<StockTxn> expired(@RequestParam String asOf){
    LocalDate d = LocalDate.parse(asOf);
    List<StockTxn> out=new ArrayList<>();
    for(StockTxn t: txnRepo.findAll()){ if(t.getExpiryDate()!=null && !t.getExpiryDate().isAfter(d)) out.add(t); }
    return out;
  }
}
EOF

cat > "$JAVA_DIR/controller/VendorPurchaseController.java" <<'EOF'
package com.neoflow.minierp.controller;
import com.neoflow.minierp.entity.*; import com.neoflow.minierp.repo.*; import com.neoflow.minierp.service.StockService;
import org.springframework.web.bind.annotation.*; import java.util.*; 
@RestController @RequestMapping("/api/purch")
public class VendorPurchaseController {
  private final VendorRepo vRepo; private final PORepo poRepo; private final POLineRepo polRepo; 
  private final GRNRepo grnRepo; private final GRNLineRepo grnLineRepo; private final APInvoiceRepo apiRepo; 
  private final APInvoiceLineRepo apilRepo; private final APPaymentRepo payRepo; private final ProductRepo pRepo; private final StockService stock;
  public VendorPurchaseController(VendorRepo v, PORepo po, POLineRepo pol, GRNRepo g, GRNLineRepo gl, APInvoiceRepo ai, APInvoiceLineRepo ail, APPaymentRepo pr, ProductRepo p, StockService s){
    this.vRepo=v; this.poRepo=po; this.polRepo=pol; this.grnRepo=g; this.grnLineRepo=gl; this.apiRepo=ai; this.apilRepo=ail; this.payRepo=pr; this.pRepo=p; this.stock=s;
  }
  // Vendors
  @GetMapping("/vendors") public List<Vendor> vendors(){return vRepo.findAll();}
  @PostMapping("/vendors") public Vendor createVendor(@RequestBody Vendor v){return vRepo.save(v);}
  // PO
  @GetMapping("/po") public List<PO> allPO(){return poRepo.findAll();}
  @PostMapping("/po") public PO createPO(@RequestParam Long vendorId){
    PO last = poRepo.findAll().stream().reduce((a,b)->b).orElse(null);
    long next = last==null?1:last.getId()+1;
    PO po=new PO(); po.setVendor(vRepo.findById(vendorId).orElseThrow()); po.setPoNo(String.format("PO-%05d",next)); return poRepo.save(po);
  }
  @PostMapping("/po/{id}/line") public PO addPOLine(@PathVariable Long id,@RequestParam Long productId,@RequestParam int qty,@RequestParam double price){
    PO po=poRepo.findById(id).orElseThrow(); Product p=pRepo.findById(productId).orElseThrow();
    POLine l=new POLine(); l.setPo(po); l.setProduct(p); l.setQty(qty); l.setPrice(price); polRepo.save(l); return poRepo.findById(id).orElseThrow();
  }
  // GRN
  @GetMapping("/grn") public List<GRN> allGRN(){return grnRepo.findAll();}
  @PostMapping("/grn") public GRN createGRN(@RequestParam Long vendorId,@RequestParam Long warehouseId,@RequestParam(required=false) Long poId){
    GRN g=new GRN(); g.setVendor(vRepo.findById(vendorId).orElseThrow()); g.setWarehouse(new Warehouse()); g.getWarehouse().setId(warehouseId); if(poId!=null){ g.setPo(poRepo.findById(poId).orElse(null)); } return grnRepo.save(g);
  }
  @PostMapping("/grn/{id}/line") public GRN addGRNLine(@PathVariable Long id,@RequestParam Long productId,@RequestParam int qty,@RequestParam double price,
                                                      @RequestParam(required=false) String lot,@RequestParam(required=false) String expiry){
    GRN g=grnRepo.findById(id).orElseThrow(); Product p=pRepo.findById(productId).orElseThrow();
    GRNLine l=new GRNLine(); l.setGrn(g); l.setProduct(p); l.setQty(qty); l.setPrice(price);
    if(lot!=null) l.setLot(lot); if(expiry!=null) l.setExpiry(java.time.LocalDate.parse(expiry)); grnLineRepo.save(l); return grnRepo.findById(id).orElseThrow();
  }
  @PostMapping("/grn/{id}/post") public GRN postGRN(@PathVariable Long id){
    GRN g=grnRepo.findById(id).orElseThrow();
    for(GRNLine l: g.getLines()){ stock.apply(l.getProduct().getId(), g.getWarehouse().getId(), l.getQty(), "IN", "GRN:"+g.getId(), l.getLot(), l.getExpiry()); }
    g.setStatus("POSTED"); return grnRepo.save(g);
  }
  // AP Invoice + payments
  @GetMapping("/apinv") public List<APInvoice> allAP(){return apiRepo.findAll();}
  @PostMapping("/apinv") public APInvoice createAP(@RequestParam Long vendorId){
    APInvoice i=new APInvoice(); i.setVendor(vRepo.findById(vendorId).orElseThrow()); return apiRepo.save(i);
  }
  @PostMapping("/apinv/{id}/line") public APInvoice addAPLine(@PathVariable Long id,@RequestParam Long productId,@RequestParam int qty,@RequestParam double price){
    APInvoice i=apiRepo.findById(id).orElseThrow(); APInvoiceLine l=new APInvoiceLine(); l.setInvoice(i); l.setProduct(pRepo.findById(productId).orElseThrow()); l.setQty(qty); l.setPrice(price); apilRepo.save(l); return apiRepo.findById(id).orElseThrow();
  }
  @PostMapping("/apinv/{id}/pay") public APPayment payAP(@PathVariable Long id,@RequestParam double amount,@RequestParam(required=false) String method){
    APPayment p=new APPayment(); p.setInvoice(apiRepo.findById(id).orElseThrow()); p.setAmount(amount); if(method!=null) p.setMethod(method); return payRepo.save(p);
  }
}
EOF

cat > "$JAVA_DIR/controller/SalesController.java" <<'EOF'
package com.neoflow.minierp.controller;
import com.neoflow.minierp.entity.*; import com.neoflow.minierp.repo.*; import com.neoflow.minierp.service.StockService;
import org.springframework.web.bind.annotation.*; import java.util.*; 
@RestController @RequestMapping("/api/sales")
public class SalesController {
  private final QuoteRepo qRepo; private final QuoteLineRepo qlRepo; private final SalesOrderRepo soRepo; private final SalesOrderLineRepo solRepo;
  private final ARInvoiceRepo arRepo; private final ARInvoiceLineRepo arlRepo; private final ARPaymentRepo payRepo;
  private final CustomerRepo cRepo; private final ProductRepo pRepo; private final StockService stock;
  public SalesController(QuoteRepo q, QuoteLineRepo ql, SalesOrderRepo so, SalesOrderLineRepo sol, ARInvoiceRepo ar, ARInvoiceLineRepo arl, ARPaymentRepo pr, CustomerRepo c, ProductRepo p, StockService s){
    this.qRepo=q; this.qlRepo=ql; this.soRepo=so; this.solRepo=sol; this.arRepo=ar; this.arlRepo=arl; this.payRepo=pr; this.cRepo=c; this.pRepo=p; this.stock=s;
  }
  // Quotes
  @GetMapping("/quotes") public List<Quote> quotes(){return qRepo.findAll();}
  @PostMapping("/quotes") public Quote createQuote(@RequestParam Long customerId){ Quote q=new Quote(); q.setCustomer(cRepo.findById(customerId).orElseThrow()); return qRepo.save(q); }
  @PostMapping("/quotes/{id}/line") public Quote addQuoteLine(@PathVariable Long id,@RequestParam Long productId,@RequestParam int qty,@RequestParam double price,@RequestParam(defaultValue="0") double discount){
    Quote q=qRepo.findById(id).orElseThrow(); QuoteLine l=new QuoteLine(); l.setQuote(q); l.setProduct(pRepo.findById(productId).orElseThrow()); l.setQty(qty); l.setPrice(price); l.setDiscount(discount); qlRepo.save(l); return qRepo.findById(id).orElseThrow();
  }
  @PostMapping("/quotes/{id}/status") public Quote setQuoteStatus(@PathVariable Long id,@RequestParam String status){ Quote q=qRepo.findById(id).orElseThrow(); q.setStatus(status); return qRepo.save(q); }

  // Sales Orders
  @GetMapping("/orders") public List<SalesOrder> orders(){return soRepo.findAll();}
  @PostMapping("/orders") public SalesOrder createSO(@RequestParam Long customerId){
    SalesOrder last = soRepo.findAll().stream().reduce((a,b)->b).orElse(null);
    long next = last==null?1:last.getId()+1;
    SalesOrder so=new SalesOrder(); so.setCustomer(cRepo.findById(customerId).orElseThrow()); so.setSoNo(String.format("SO-%05d", next)); return soRepo.save(so);
  }
  @PostMapping("/orders/{id}/line") public SalesOrder addSOLine(@PathVariable Long id,@RequestParam Long productId,@RequestParam int qty,@RequestParam double price){
    SalesOrder so=soRepo.findById(id).orElseThrow(); SalesOrderLine l=new SalesOrderLine(); l.setOrder(so); l.setProduct(pRepo.findById(productId).orElseThrow()); l.setQty(qty); l.setPrice(price); solRepo.save(l); return soRepo.findById(id).orElseThrow();
  }

  // AR Invoices
  @GetMapping("/arinv") public List<ARInvoice> arInvoices(){return arRepo.findAll();}
  @PostMapping("/arinv") public ARInvoice createAR(@RequestParam Long customerId){ ARInvoice i=new ARInvoice(); i.setCustomer(cRepo.findById(customerId).orElseThrow()); return arRepo.save(i); }
  @PostMapping("/arinv/{id}/line") public ARInvoice addARLine(@PathVariable Long id,@RequestParam Long productId,@RequestParam int qty,@RequestParam double price){
    ARInvoice i=arRepo.findById(id).orElseThrow(); ARInvoiceLine l=new ARInvoiceLine(); l.setInvoice(i); l.setProduct(pRepo.findById(productId).orElseThrow()); l.setQty(qty); l.setPrice(price); arlRepo.save(l); return arRepo.findById(id).orElseThrow();
  }
  @PostMapping("/arinv/{id}/post") public ARInvoice postAR(@PathVariable Long id,@RequestParam Long warehouseId){
    ARInvoice i=arRepo.findById(id).orElseThrow();
    for(ARInvoiceLine l : i.getLines()){ stock.apply(l.getProduct().getId(), warehouseId, -l.getQty(), "OUT", "ARINV:"+i.getId(), null, null); }
    i.setStatus("POSTED"); return arRepo.save(i);
  }
  @PostMapping("/arinv/{id}/pay") public ARPayment payAR(@PathVariable Long id,@RequestParam double amount,@RequestParam(required=false) String method){
    ARPayment p=new ARPayment(); p.setInvoice(arRepo.findById(id).orElseThrow()); p.setAmount(amount); if(method!=null) p.setMethod(method); return payRepo.save(p);
  }
}
EOF

cat > "$JAVA_DIR/controller/HRFinanceController.java" <<'EOF'
package com.neoflow.minierp.controller;
import com.neoflow.minierp.entity.*; import com.neoflow.minierp.repo.*;
import org.springframework.web.bind.annotation.*; import java.util.*; 
@RestController @RequestMapping("/api/core")
public class HRFinanceController {
  private final CostCenterRepo ccRepo; private final EmployeeRepo eRepo; private final PayrollRunRepo prRepo; private final PayrollItemRepo piRepo; private final ExpenseRepo exRepo;
  public HRFinanceController(CostCenterRepo c, EmployeeRepo e, PayrollRunRepo pr, PayrollItemRepo pi, ExpenseRepo ex){this.ccRepo=c; this.eRepo=e; this.prRepo=pr; this.piRepo=pi; this.exRepo=ex;}

  // Cost centers
  @GetMapping("/costcenters") public List<CostCenter> ccAll(){return ccRepo.findAll();}
  @PostMapping("/costcenters") public CostCenter ccCreate(@RequestBody CostCenter c){return ccRepo.save(c);}

  // Employees
  @GetMapping("/employees") public List<Employee> empAll(){return eRepo.findAll();}
  @PostMapping("/employees") public Employee empCreate(@RequestBody Employee e){return eRepo.save(e);}

  // Payroll
  @GetMapping("/payroll") public List<PayrollRun> prAll(){return prRepo.findAll();}
  @PostMapping("/payroll") public PayrollRun prCreate(@RequestParam String start,@RequestParam String end){
    PayrollRun r=new PayrollRun(); r.setPeriodStart(java.time.LocalDate.parse(start)); r.setPeriodEnd(java.time.LocalDate.parse(end)); return prRepo.save(r);
  }
  @PostMapping("/payroll/{id}/item") public PayrollRun prAddItem(@PathVariable Long id,@RequestParam Long employeeId,@RequestParam String type,@RequestParam double amount,@RequestParam(required=false) String note){
    PayrollRun r=prRepo.findById(id).orElseThrow(); PayrollItem it=new PayrollItem(); it.setRun(r); it.setEmployee(eRepo.findById(employeeId).orElseThrow()); it.setType(type); it.setAmount(amount); it.setNote(note); piRepo.save(it); return prRepo.findById(id).orElseThrow();
  }
  @PostMapping("/payroll/{id}/post") public PayrollRun prPost(@PathVariable Long id){ PayrollRun r=prRepo.findById(id).orElseThrow(); r.setPosted(true); return prRepo.save(r); }

  // Expenses
  @GetMapping("/expenses") public List<Expense> exAll(){return exRepo.findAll();}
  @PostMapping("/expenses") public Expense exCreate(@RequestBody Expense e){return exRepo.save(e);}
  @PostMapping("/expenses/{id}/status") public Expense exStatus(@PathVariable Long id,@RequestParam String status){ Expense e=exRepo.findById(id).orElseThrow(); e.setStatus(status); return exRepo.save(e); }
}
EOF

# ====== ensure CORS still enabled (WebConfig already exists) ======

# ───────────────────────────────── FRONTEND (PHP) ─────────────────────────────────

# Replace navbar with full menu (monochrome theme already in base_start.php from earlier step)
cat > "$PHP_DIR/base_start.php" <<'EOF'
<?php include "env.php"; ?>
<!doctype html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>NeoFlow MiniERP</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="https://cdn.datatables.net/1.13.8/css/dataTables.bootstrap5.min.css" rel="stylesheet">
<style>
:root{--bg:#fff;--fg:#111;--card:#f6f6f6} .dark{--bg:#0d0d0d;--fg:#f3f3f3;--card:#161616}
body{background:var(--bg);color:var(--fg)} .navbar,.card{background:var(--card);border:1px solid #e5e7eb}
.btn-primary{background:var(--fg);border-color:var(--fg);color:var(--bg)} a,.nav-link{color:var(--fg)} table{color:var(--fg)}
.form-control,.form-select{background:var(--bg);color:var(--fg);border-color:#d1d5db}
.form-control:focus,.form-select:focus{box-shadow:none;border-color:#111}
.low{background:#fff1f2!important}
</style>
<script>
(function(){const t=localStorage.getItem('nf_theme')||'light'; if(t==='dark') document.documentElement.classList.add('dark');
window.toggleTheme=()=>{document.documentElement.classList.toggle('dark'); localStorage.setItem('nf_theme',document.documentElement.classList.contains('dark')?'dark':'light');};})();
</script>
</head><body>
<nav class="navbar navbar-expand-lg mb-4"><div class="container-fluid">
  <a class="navbar-brand" href="index.php"><strong>NeoFlow</strong> MiniERP</a>
  <button class="navbar-toggler" data-bs-toggle="collapse" data-bs-target="#nav"><span class="navbar-toggler-icon"></span></button>
  <div id="nav" class="collapse navbar-collapse">
    <ul class="navbar-nav me-auto">
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" data-bs-toggle="dropdown">Sales</a>
        <ul class="dropdown-menu">
          <li><a class="dropdown-item" href="quotes.php">Quotes</a></li>
          <li><a class="dropdown-item" href="orders.php">Sales Orders</a></li>
          <li><a class="dropdown-item" href="ar_invoices.php">AR Invoices</a></li>
        </ul>
      </li>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" data-bs-toggle="dropdown">Purchasing</a>
        <ul class="dropdown-menu">
          <li><a class="dropdown-item" href="vendors.php">Vendors</a></li>
          <li><a class="dropdown-item" href="po.php">PO</a></li>
          <li><a class="dropdown-item" href="grn.php">GRN</a></li>
          <li><a class="dropdown-item" href="ap_invoices.php">AP Invoices</a></li>
        </ul>
      </li>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" data-bs-toggle="dropdown">Inventory</a>
        <ul class="dropdown-menu">
          <li><a class="dropdown-item" href="warehouses.php">Warehouses</a></li>
          <li><a class="dropdown-item" href="stock_levels.php">Stock Levels</a></li>
          <li><a class="dropdown-item" href="transfers.php">Transfers</a></li>
          <li><a class="dropdown-item" href="expired.php">Expired</a></li>
        </ul>
      </li>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" data-bs-toggle="dropdown">Finance</a>
        <ul class="dropdown-menu">
          <li><a class="dropdown-item" href="expenses.php">Expenses</a></li>
          <li><a class="dropdown-item" href="payroll.php">Payroll</a></li>
        </ul>
      </li>
      <li class="nav-item"><a class="nav-link" href="employees.php">Employees</a></li>
      <li class="nav-item"><a class="nav-link" href="products.php">Products</a></li>
      <li class="nav-item"><a class="nav-link" href="customers.php">Customers</a></li>
      <li class="nav-item"><a class="nav-link" href="orders.php">Orders</a></li>
    </ul>
    <button class="btn btn-sm btn-outline-dark" onclick="toggleTheme()"><i class="bi bi-circle-half"></i> Theme</button>
  </div>
</div></nav>
<main class="container">
EOF

# Small helper creator for PHP list pages
make_list_page () {
  local file="$1"; local title="$2"; local endpoint="$3"; local columns="$4"; local rowTpl="$5"
  cat > "$PHP_DIR/$file" <<EOF
<?php include "base_start.php"; include "env.php"; ?>
<div class="d-flex justify-content-between align-items-center mb-3">
  <h3 class="m-0">$title</h3>
</div>
<div class="card p-3">
  <table id="tbl" class="table table-striped" style="width:100%">
    <thead><tr>$columns</tr></thead><tbody></tbody>
  </table>
</div>
<script>
fetch("$endpoint").then(r=>r.json()).then(rows=>{
  const tbody=document.querySelector("#tbl tbody");
  tbody.innerHTML = rows.map(r=>$rowTpl).join("");
  new DataTable('#tbl');
});
</script>
<?php include "base_end.php"; ?>
EOF
}

# Inventory pages
make_list_page "warehouses.php" "Warehouses" "<?php echo \$API_BASE; ?>/warehouses" "<th>ID</th><th>Code</th><th>Name</th><th>Location</th>" "`<tr><td>\${r.id}</td><td>\${r.code||''}</td><td>\${r.name||''}</td><td>\${r.location||''}</td></tr>`"
make_list_page "stock_levels.php" "Stock Levels" "<?php echo \$API_BASE; ?>/stock/levels" "<th>Product</th><th>Warehouse</th><th>On Hand</th><th>Reserved</th>" "`<tr><td>\${r.product?.sku} — \${r.product?.name}</td><td>\${r.warehouse?.code}</td><td>\${r.onHand}</td><td>\${r.reserved}</td></tr>`"
cat > "$PHP_DIR/transfers.php" <<'EOF'
<?php include "base_start.php"; include "env.php"; ?>
<h3 class="mb-3">Stock Transfer</h3>
<div class="card p-3 mb-3">
  <div class="row g-2">
    <div class="col-md-3"><input id="prod" class="form-control" placeholder="Product ID"></div>
    <div class="col-md-3"><input id="from" class="form-control" placeholder="From WH ID"></div>
    <div class="col-md-3"><input id="to" class="form-control" placeholder="To WH ID"></div>
    <div class="col-md-2"><input id="qty" class="form-control" placeholder="Qty"></div>
    <div class="col-md-1"><button class="btn btn-primary w-100" onclick="go()">Go</button></div>
  </div>
</div>
<script>
function go(){
  const p=document.getElementById('prod').value, f=document.getElementById('from').value, t=document.getElementById('to').value, q=document.getElementById('qty').value;
  if(!p||!f||!t||!q) return alert('All fields required');
  fetch(`${"<?php echo $API_BASE; ?>"}/stock/transfer?productId=${p}&fromWh=${f}&toWh=${t}&qty=${q}&ref=UI`,{method:"POST"}).then(()=>alert('Transfer OK'));
}
</script>
<?php include "base_end.php"; ?>
EOF
cat > "$PHP_DIR/expired.php" <<'EOF'
<?php include "base_start.php"; include "env.php"; ?>
<h3 class="mb-3">Expired Items</h3>
<div class="card p-3">
  <div class="d-flex gap-2 mb-2">
    <input id="asof" class="form-control" style="max-width:200px" placeholder="YYYY-MM-DD">
    <button class="btn btn-primary" onclick="load()">Load</button>
  </div>
  <table id="tbl" class="table table-striped"><thead><tr><th>Date</th><th>Product</th><th>WH</th><th>Lot</th><th>Expiry</th><th>Qty</th></tr></thead><tbody></tbody></table>
</div>
<script>
function load(){
  const d=document.getElementById('asof').value; if(!d) return alert('Date required');
  fetch(`${"<?php echo $API_BASE; ?>"}/stock/expired?asOf=${d}`).then(r=>r.json()).then(rows=>{
    const tb=document.querySelector('#tbl tbody');
    tb.innerHTML = rows.map(r=>`<tr>
      <td>${r.date||''}</td><td>${r.product?.sku||''}</td><td>${r.warehouse?.code||''}</td><td>${r.lot||''}</td><td>${r.expiryDate||''}</td><td>${r.qty||0}</td>
    </tr>`).join("");
    new DataTable('#tbl');
  });
}
</script>
<?php include "base_end.php"; ?>
EOF

# Purchasing pages
make_list_page "vendors.php" "Vendors" "<?php echo \$API_BASE; ?>/purch/vendors" "<th>ID</th><th>Name</th><th>Email</th><th>Phone</th>" "`<tr><td>\${r.id}</td><td>\${r.name}</td><td>\${r.email||''}</td><td>\${r.phone||''}</td></tr>`"
make_list_page "po.php" "Purchase Orders" "<?php echo \$API_BASE; ?>/purch/po" "<th>No</th><th>Vendor</th><th>Date</th><th>Status</th><th>Total</th>" "`<tr><td>\${r.poNo}</td><td>\${r.vendor?.name||''}</td><td>\${r.date||''}</td><td>\${r.status}</td><td>\${(r.lines||[]).reduce((a,l)=>a+l.qty*l.price,0).toFixed(2)}</td></tr>`"
make_list_page "grn.php" "GRNs" "<?php echo \$API_BASE; ?>/purch/grn" "<th>ID</th><th>Vendor</th><th>Warehouse</th><th>Date</th><th>Status</th>" "`<tr><td>\${r.id}</td><td>\${r.vendor?.name}</td><td>\${r.warehouse?.code}</td><td>\${r.date||''}</td><td>\${r.status}</td></tr>`"
make_list_page "ap_invoices.php" "AP Invoices" "<?php echo \$API_BASE; ?>/purch/apinv" "<th>ID</th><th>Vendor</th><th>Date</th><th>Status</th><th>Total</th>" "`<tr><td>\${r.id}</td><td>\${r.vendor?.name||''}</td><td>\${r.date||''}</td><td>\${r.status}</td><td>\${(r.lines||[]).reduce((a,l)=>a+l.qty*l.price,0).toFixed(2)}</td></tr>`"

# Sales pages
make_list_page "quotes.php" "Quotes" "<?php echo \$API_BASE; ?>/sales/quotes" "<th>ID</th><th>Customer</th><th>Date</th><th>Status</th><th>Total</th>" "`<tr><td>\${r.id}</td><td>\${r.customer?.name||''}</td><td>\${r.date||''}</td><td>\${r.status}</td><td>\${(r.lines||[]).reduce((a,l)=>a+l.qty*l.price,0).toFixed(2)}</td></tr>`"
make_list_page "ar_invoices.php" "AR Invoices" "<?php echo \$API_BASE; ?>/sales/arinv" "<th>ID</th><th>Customer</th><th>Date</th><th>Status</th><th>Total</th>" "`<tr><td>\${r.id}</td><td>\${r.customer?.name||''}</td><td>\${r.date||''}</td><td>\${r.status}</td><td>\${(r.lines||[]).reduce((a,l)=>a+l.qty*l.price,0).toFixed(2)}</td></tr>`"

# Finance pages
make_list_page "expenses.php" "Expenses" "<?php echo \$API_BASE; ?>/core/expenses" "<th>ID</th><th>Date</th><th>Category</th><th>Amount</th><th>Tax</th><th>Status</th>" "`<tr><td>\${r.id}</td><td>\${r.date||''}</td><td>\${r.category||''}</td><td>\${r.amount?.toFixed(2)||'0.00'}</td><td>\${r.tax?.toFixed(2)||'0.00'}</td><td>\${r.status}</td></tr>`"

# HR pages
make_list_page "employees.php" "Employees" "<?php echo \$API_BASE; ?>/core/employees" "<th>ID</th><th>Name</th><th>Position</th><th>Currency</th><th>Base</th><th>Active</th>" "`<tr><td>\${r.id}</td><td>\${r.name}</td><td>\${r.position||''}</td><td>\${r.currency}</td><td>\${r.salaryBase?.toFixed(2)||'0.00'}</td><td>\${r.active?'Yes':'No'}</td></tr>`"
make_list_page "payroll.php" "Payroll Runs" "<?php echo \$API_BASE; ?>/core/payroll" "<th>ID</th><th>Start</th><th>End</th><th>Posted</th><th>Items</th>" "`<tr><td>\${r.id}</td><td>\${r.periodStart||''}</td><td>\${r.periodEnd||''}</td><td>\${r.posted?'Yes':'No'}</td><td>\${(r.items||[]).length}</td></tr>`"

echo ">> Upgrade complete."