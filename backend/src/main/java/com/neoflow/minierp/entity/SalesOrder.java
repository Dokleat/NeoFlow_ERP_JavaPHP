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
