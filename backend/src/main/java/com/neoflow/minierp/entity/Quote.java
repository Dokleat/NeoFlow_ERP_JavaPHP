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
