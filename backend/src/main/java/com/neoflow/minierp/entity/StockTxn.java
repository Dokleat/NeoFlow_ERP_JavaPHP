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
