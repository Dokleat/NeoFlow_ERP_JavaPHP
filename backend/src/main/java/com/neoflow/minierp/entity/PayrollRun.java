package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate; import java.util.*;
@Entity
public class PayrollRun {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  private LocalDate periodStart; private LocalDate periodEnd; private boolean posted=false;
  @OneToMany(mappedBy="run", cascade=CascadeType.ALL, orphanRemoval=true) private List<PayrollItem> items=new ArrayList<>();
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public LocalDate getPeriodStart(){return periodStart;} public void setPeriodStart(LocalDate d){this.periodStart=d;}
  public LocalDate getPeriodEnd(){return periodEnd;} public void setPeriodEnd(LocalDate d){this.periodEnd=d;}
  public boolean isPosted(){return posted;} public void setPosted(boolean p){this.posted=p;}
  public List<PayrollItem> getItems(){return items;} public void setItems(List<PayrollItem> ls){this.items=ls;}
}
