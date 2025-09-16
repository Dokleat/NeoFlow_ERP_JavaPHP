package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate; import java.util.*;
@Entity
public class PO {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @Column(unique=true) private String poNo;
  @ManyToOne private Vendor vendor; private LocalDate date=LocalDate.now(); private String status="OPEN";
  @OneToMany(mappedBy="po", cascade=CascadeType.ALL, orphanRemoval=true) private List<POLine> lines=new ArrayList<>();
  public double getTotal(){ return lines.stream().mapToDouble(l->l.getQty()*l.getPrice()).sum(); }
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public String getPoNo(){return poNo;} public void setPoNo(String s){this.poNo=s;}
  public Vendor getVendor(){return vendor;} public void setVendor(Vendor v){this.vendor=v;}
  public LocalDate getDate(){return date;} public void setDate(LocalDate d){this.date=d;}
  public String getStatus(){return status;} public void setStatus(String s){this.status=s;}
  public List<POLine> getLines(){return lines;} public void setLines(List<POLine> ls){this.lines=ls;}
}
