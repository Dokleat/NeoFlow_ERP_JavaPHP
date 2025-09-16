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
