package com.neoflow.minierp.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

@Entity
@Table(name="so_order_lines")
public class OrderLine {
  @Id
  @GeneratedValue(strategy=GenerationType.IDENTITY)
  private Long id;

  @ManyToOne(fetch=FetchType.LAZY)
  @JoinColumn(name="order_id")
  private Order order;

  @NotNull
  private Long productId;

  @Min(1)
  private int qty;

  @Min(0)
  private double unitPrice;

  @Min(0)
  private double taxRate = 0.0;

  @Min(0)
  private double discount = 0.0;

  public Long getId() { return id; }
  public Order getOrder() { return order; }
  public void setOrder(Order order) { this.order = order; }
  public Long getProductId() { return productId; }
  public void setProductId(Long productId) { this.productId = productId; }
  public int getQty() { return qty; }
  public void setQty(int qty) { this.qty = qty; }
  public double getUnitPrice() { return unitPrice; }
  public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }
  public double getTaxRate() { return taxRate; }
  public void setTaxRate(double taxRate) { this.taxRate = taxRate; }
  public double getDiscount() { return discount; }
  public void setDiscount(double discount) { this.discount = discount; }
}
