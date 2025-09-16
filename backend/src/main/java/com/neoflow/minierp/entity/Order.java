package com.neoflow.minierp.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name="so_orders")
public class Order {
  @Id
  @GeneratedValue(strategy=GenerationType.IDENTITY)
  private Long id;

  @Column(unique = true, length=40, nullable = false)
  private String orderNo;

  @NotNull
  private Long customerId;

  private LocalDate orderDate = LocalDate.now();

  @Enumerated(EnumType.STRING)
  private OrderStatus status = OrderStatus.DRAFT;

  @Column(length=3)
  private String currency = "EUR";

  @OneToMany(mappedBy="order", cascade=CascadeType.ALL, orphanRemoval = true, fetch=FetchType.LAZY)
  private List<OrderLine> lines = new ArrayList<>();

  public Long getId() { return id; }
  public String getOrderNo() { return orderNo; }
  public void setOrderNo(String orderNo) { this.orderNo = orderNo; }
  public Long getCustomerId() { return customerId; }
  public void setCustomerId(Long customerId) { this.customerId = customerId; }
  public LocalDate getOrderDate() { return orderDate; }
  public void setOrderDate(LocalDate orderDate) { this.orderDate = orderDate; }
  public OrderStatus getStatus() { return status; }
  public void setStatus(OrderStatus status) { this.status = status; }
  public String getCurrency() { return currency; }
  public void setCurrency(String currency) { this.currency = currency; }
  public List<OrderLine> getLines() { return lines; }
  public void setLines(List<OrderLine> lines) { this.lines = lines; }
}
