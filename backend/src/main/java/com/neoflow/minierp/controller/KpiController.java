package com.neoflow.minierp.controller;

import com.neoflow.minierp.entity.Order;
import com.neoflow.minierp.repo.OrderRepo;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
public class KpiController {
  private final OrderRepo orderRepo;
  public KpiController(OrderRepo orderRepo){ this.orderRepo = orderRepo; }

  @GetMapping("/api/kpi")
  public Map<String,Object> kpi(){
    List<Order> orders = orderRepo.findAll();
    int orderCount = orders.size();

    double revenue = orders.stream().mapToDouble(o ->
      o.getLines().stream().mapToDouble(l -> {
        double base = l.getQty() * l.getUnitPrice();
        double tax  = base * (l.getTaxRate() / 100.0);
        double line = base + tax - l.getDiscount();
        return Math.max(0.0, line);
      }).sum()
    ).sum();

    Map<String,Object> m = new HashMap<>();
    m.put("orders", orderCount);
    m.put("revenue", revenue);
    m.put("currency", "EUR");
    return m;
  }
}
