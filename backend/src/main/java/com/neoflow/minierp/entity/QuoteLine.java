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
