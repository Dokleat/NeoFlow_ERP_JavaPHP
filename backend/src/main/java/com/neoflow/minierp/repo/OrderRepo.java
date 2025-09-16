package com.neoflow.minierp.repo;

import com.neoflow.minierp.entity.Order;
import com.neoflow.minierp.entity.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface OrderRepo extends JpaRepository<Order, Long> {
  List<Order> findByStatus(OrderStatus status);
  List<Order> findByCustomerId(Long customerId);
  List<Order> findByOrderDateBetween(LocalDate start, LocalDate end);
}
