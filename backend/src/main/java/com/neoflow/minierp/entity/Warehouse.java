package com.neoflow.minierp.entity;
import jakarta.persistence.*;
@Entity
public class Warehouse {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @Column(unique=true) private String code;
  private String name; private String location;
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public String getCode(){return code;} public void setCode(String code){this.code=code;}
  public String getName(){return name;} public void setName(String name){this.name=name;}
  public String getLocation(){return location;} public void setLocation(String l){this.location=l;}
}
