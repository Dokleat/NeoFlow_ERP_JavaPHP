package com.neoflow.minierp.dto;

import com.neoflow.minierp.entity.OrderStatus;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class OrderDTO {
  public Long id;
  public String orderNo;
  @NotNull public Long customerId;
  public LocalDate orderDate;
  public OrderStatus status;
  public String currency = "EUR";
  @Valid
  @Size(min=1, message="Minimum 1 line")
  public List<OrderLineDTO> lines = new ArrayList<>();
}
