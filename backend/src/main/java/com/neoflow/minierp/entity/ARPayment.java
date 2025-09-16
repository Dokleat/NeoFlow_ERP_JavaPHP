package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate;
@Entity
public class ARPayment {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private ARInvoice invoice; private double amount; private LocalDate date=LocalDate.now(); private String method="TRF";
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public ARInvoice getInvoice(){return invoice;} public void setInvoice(ARInvoice i){this.invoice=i;}
  public double getAmount(){return amount;} public void setAmount(double a){this.amount=a;}
  public LocalDate getDate(){return date;} public void setDate(LocalDate d){this.date=d;}
  public String getMethod(){return method;} public void setMethod(String m){this.method=m;}
}
