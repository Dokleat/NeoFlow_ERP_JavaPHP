package com.neoflow.minierp.entity;
import jakarta.persistence.*; 
@Entity
public class PayrollItem {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private PayrollRun run; @ManyToOne private Employee employee;
  private String type; // BASIC|OVERTIME|BONUS|DEDUCTION|TAX
  private double amount; private String note;
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public PayrollRun getRun(){return run;} public void setRun(PayrollRun r){this.run=r;}
  public Employee getEmployee(){return employee;} public void setEmployee(Employee e){this.employee=e;}
  public String getType(){return type;} public void setType(String t){this.type=t;}
  public double getAmount(){return amount;} public void setAmount(double a){this.amount=a;}
  public String getNote(){return note;} public void setNote(String n){this.note=n;}
}
