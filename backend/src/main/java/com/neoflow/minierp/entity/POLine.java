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
