package com.neoflow.minierp.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public class OrderLineDTO {
  public Long id;
  @NotNull public Long productId;
  @Min(1) public int qty;
  @Min(0) public double unitPrice;
  @Min(0) public double taxRate;
  @Min(0) public double discount;
}
