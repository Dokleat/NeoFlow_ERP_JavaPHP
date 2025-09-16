package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDateTime;
@Entity
public class Product {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @Column(unique=true) private String sku;
  private String name; private double unitPrice; private int stockQty; private int minStock;
  private LocalDateTime createdAt = LocalDateTime.now();
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public String getSku(){return sku;} public void setSku(String sku){this.sku=sku;}
  public String getName(){return name;} public void setName(String name){this.name=name;}
  public double getUnitPrice(){return unitPrice;} public void setUnitPrice(double p){this.unitPrice=p;}
  public int getStockQty(){return stockQty;} public void setStockQty(int q){this.stockQty=q;}
  public int getMinStock(){return minStock;} public void setMinStock(int q){this.minStock=q;}
  public LocalDateTime getCreatedAt(){return createdAt;} public void setCreatedAt(LocalDateTime t){this.createdAt=t;}
}
