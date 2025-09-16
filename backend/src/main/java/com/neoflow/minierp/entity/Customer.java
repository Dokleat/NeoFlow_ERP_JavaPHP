package com.neoflow.minierp.entity;
import jakarta.persistence.*;

@Entity @Table(name="ar_customers")
public class Customer {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY)
  private Long id;

  @Column(nullable=false, length=120) private String name;
  @Column(length=120) private String email;
  @Column(length=40)  private String phone;
  @Column(length=80)  private String city;

  public Long getId(){return id;}
  public void setId(Long id){ this.id = id; }  // <— shtuar

  public String getName(){return name;}
  public void setName(String v){name=v;}

  public String getEmail(){return email;}
  public void setEmail(String v){email=v;}

  public String getPhone(){return phone;}
  public void setPhone(String v){phone=v;}

  public String getCity(){return city;}
  public void setCity(String v){city=v;}
}
