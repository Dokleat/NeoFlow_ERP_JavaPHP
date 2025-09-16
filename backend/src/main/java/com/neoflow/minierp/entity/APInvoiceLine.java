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
