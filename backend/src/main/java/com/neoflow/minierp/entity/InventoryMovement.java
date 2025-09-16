package com.neoflow.minierp.entity;
import jakarta.persistence.*; import java.time.LocalDateTime;
@Entity
public class InventoryMovement {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne private Product product; private String movementType; private int quantity; private String reference;
  private LocalDateTime createdAt = LocalDateTime.now();
  public Long getId(){return id;} public void setId(Long id){this.id=id;}
  public Product getProduct(){return product;} public void setProduct(Product p){this.product=p;}
  public String getMovementType(){return movementType;} public void setMovementType(String t){this.movementType=t;}
  public int getQuantity(){return quantity;} public void setQuantity(int q){this.quantity=q;}
  public String getReference(){return reference;} public void setReference(String r){this.reference=r;}
  public LocalDateTime getCreatedAt(){return createdAt;} public void setCreatedAt(LocalDateTime t){this.createdAt=t;}
}
