package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate;
@Entity
public class Expense {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  private LocalDate date=LocalDate.now(); private String category; private String currency="EUR";
  private double amount; private double tax; private String status="DRAFT"; private String vendorText;
  @ManyToOne private Employee employee; @ManyToOne private CostCenter costCenter;
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public LocalDate getDate(){return date;} public void setDate(LocalDate d){this.date=d;}
  public String getCategory(){return category;} public void setCategory(String c){this.category=c;}
  public String getCurrency(){return currency;} public void setCurrency(String c){this.currency=c;}
  public double getAmount(){return amount;} public void setAmount(double a){this.amount=a;}
  public double getTax(){return tax;} public void setTax(double t){this.tax=t;}
  public String getStatus(){return status;} public void setStatus(String s){this.status=s;}
  public String getVendorText(){return vendorText;} public void setVendorText(String v){this.vendorText=v;}
  public Employee getEmployee(){return employee;} public void setEmployee(Employee e){this.employee=e;}
  public CostCenter getCostCenter(){return costCenter;} public void setCostCenter(CostCenter c){this.costCenter=c;}
}
