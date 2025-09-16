package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate;
@Entity
public class Employee {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  private String name; private String position; private LocalDate hireDate=LocalDate.now(); private String currency="EUR"; private double salaryBase;
  @ManyToOne private CostCenter costCenter; private boolean active=true;
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public String getName(){return name;} public void setName(String name){this.name=name;}
  public String getPosition(){return position;} public void setPosition(String p){this.position=p;}
  public LocalDate getHireDate(){return hireDate;} public void setHireDate(LocalDate d){this.hireDate=d;}
  public String getCurrency(){return currency;} public void setCurrency(String c){this.currency=c;}
  public double getSalaryBase(){return salaryBase;} public void setSalaryBase(double s){this.salaryBase=s;}
  public CostCenter getCostCenter(){return costCenter;} public void setCostCenter(CostCenter c){this.costCenter=c;}
  public boolean isActive(){return active;} public void setActive(boolean a){this.active=a;}
}
