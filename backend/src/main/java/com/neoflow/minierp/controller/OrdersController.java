package com.neoflow.minierp.controller;

import com.neoflow.minierp.dto.OrderDTO;
import com.neoflow.minierp.entity.Order;
import com.neoflow.minierp.service.OrderService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/api/orders")
public class OrdersController {
  private final OrderService service;
  public OrdersController(OrderService s){ this.service = s; }

  @GetMapping
  public List<OrderDTO> list(){
    return service.list().stream().map(OrderService::toDTO).toList();
  }

  @GetMapping("/{id}")
  public OrderDTO get(@PathVariable Long id){
    return OrderService.toDTO(service.get(id));
  }

  @PostMapping
  public ResponseEntity<OrderDTO> create(@Valid @RequestBody OrderDTO dto){
    Order created = service.create(dto);
    return ResponseEntity.created(URI.create("/api/orders/" + created.getId()))
        .body(OrderService.toDTO(created));
  }

  @PutMapping("/{id}")
  public OrderDTO update(@PathVariable Long id, @Valid @RequestBody OrderDTO dto){
    return OrderService.toDTO(service.update(id, dto));
  }

  @DeleteMapping("/{id}")
  public ResponseEntity<Void> delete(@PathVariable Long id){
    service.delete(id);
    return ResponseEntity.noContent().build();
  }

  @PostMapping("/{id}/confirm")
  public OrderDTO confirm(@PathVariable Long id){ return OrderService.toDTO(service.confirm(id)); }

  @PostMapping("/{id}/fulfill")
  public OrderDTO fulfill(@PathVariable Long id){ return OrderService.toDTO(service.fulfill(id)); }

  @PostMapping("/{id}/invoice")
  public OrderDTO invoice(@PathVariable Long id){ return OrderService.toDTO(service.invoice(id)); }

  @PostMapping("/{id}/close")
  public OrderDTO close(@PathVariable Long id){ return OrderService.toDTO(service.close(id)); }
}
