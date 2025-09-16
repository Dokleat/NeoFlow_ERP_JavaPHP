package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDate; import java.util.*;
@Entity
public class GRN {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private PO po; @ManyToOne private Vendor vendor;
  private LocalDate date=LocalDate.now(); private String status="OPEN"; @ManyToOne private Warehouse warehouse;
  @OneToMany(mappedBy="grn", cascade=CascadeType.ALL, orphanRemoval=true) private List<GRNLine> lines=new ArrayList<>();
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public PO getPo(){return po;} public void setPo(PO p){this.po=p;}
  public Vendor getVendor(){return vendor;} public void setVendor(Vendor v){this.vendor=v;}
  public Warehouse getWarehouse(){return warehouse;} public void setWarehouse(Warehouse w){this.warehouse=w;}
  public LocalDate getDate(){return date;} public void setDate(LocalDate d){this.date=d;}
  public String getStatus(){return status;} public void setStatus(String s){this.status=s;}
  public List<GRNLine> getLines(){return lines;} public void setLines(List<GRNLine> ls){this.lines=ls;}
}
