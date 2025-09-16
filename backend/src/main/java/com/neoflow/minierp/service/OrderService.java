package com.neoflow.minierp.service;

import com.neoflow.minierp.dto.OrderDTO;
import com.neoflow.minierp.dto.OrderLineDTO;
import com.neoflow.minierp.entity.Order;
import com.neoflow.minierp.entity.OrderLine;
import com.neoflow.minierp.entity.OrderStatus;
import com.neoflow.minierp.repo.OrderRepo;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Random;
import java.util.stream.Collectors;

@Service
public class OrderService {
  private final OrderRepo repo;
  private final Random rnd = new Random();

  public OrderService(OrderRepo repo){ this.repo = repo; }

  private String nextOrderNo(){
    int n = 10000 + rnd.nextInt(90000);
    return "SO-" + LocalDate.now().getYear() + "-" + n;
  }

  private void applyLines(Order order, List<OrderLineDTO> lines){
    order.getLines().clear();
    for (OrderLineDTO d : lines){
      OrderLine l = new OrderLine();
      l.setOrder(order);
      l.setProductId(d.productId);
      l.setQty(Math.max(1, d.qty));
      l.setUnitPrice(Math.max(0, d.unitPrice));
      l.setTaxRate(Math.max(0, d.taxRate));
      l.setDiscount(Math.max(0, d.discount));
      order.getLines().add(l);
    }
  }

  private void assertEditable(Order o){
    if (o.getStatus()==OrderStatus.CLOSED || o.getStatus()==OrderStatus.INVOICED){
      throw new IllegalStateException("Order nuk mund të ndryshohet në status: " + o.getStatus());
    }
  }

  private void assertHasLines(Order o){
    if (o.getLines()==null || o.getLines().isEmpty()){
      throw new IllegalStateException("Order duhet të ketë të paktën një linjë.");
    }
  }

  @Transactional
  public Order create(OrderDTO dto){
    Order o = new Order();
    o.setOrderNo(nextOrderNo());
    o.setCustomerId(dto.customerId);
    o.setOrderDate(dto.orderDate!=null ? dto.orderDate : LocalDate.now());
    o.setCurrency(dto.currency!=null ? dto.currency : "EUR");
    o.setStatus(OrderStatus.DRAFT);
    applyLines(o, dto.lines);
    assertHasLines(o);
    return repo.save(o);
  }

  @Transactional
  public Order update(Long id, OrderDTO dto){
    Order o = repo.findById(id).orElseThrow(() -> new NoSuchElementException("Order not found"));
    assertEditable(o);
    o.setCustomerId(dto.customerId);
    if (dto.orderDate!=null) o.setOrderDate(dto.orderDate);
    if (dto.currency!=null) o.setCurrency(dto.currency);
    applyLines(o, dto.lines);
    assertHasLines(o);
    return repo.save(o);
  }

  @Transactional(readOnly = true)
  public List<Order> list(){
    return repo.findAll();
  }

  @Transactional(readOnly = true)
  public Order get(Long id){
    return repo.findById(id).orElseThrow(() -> new NoSuchElementException("Order not found"));
  }

  @Transactional
  public void delete(Long id){
    Order o = repo.findById(id).orElseThrow(() -> new NoSuchElementException("Order not found"));
    if (o.getStatus()!=OrderStatus.DRAFT){
      throw new IllegalStateException("Mund të fshihet vetëm DRAFT.");
    }
    repo.delete(o);
  }

  @Transactional
  public Order confirm(Long id){
    Order o = get(id);
    if (o.getStatus()!=OrderStatus.DRAFT) throw new IllegalStateException("Lejohet nga DRAFT vetëm.");
    assertHasLines(o);
    o.setStatus(OrderStatus.CONFIRMED);
    return repo.save(o);
  }

  @Transactional
  public Order fulfill(Long id){
    Order o = get(id);
    if (o.getStatus()!=OrderStatus.CONFIRMED) throw new IllegalStateException("Lejohet nga CONFIRMED vetëm.");
    o.setStatus(OrderStatus.FULFILLED);
    return repo.save(o);
  }

  @Transactional
  public Order invoice(Long id){
    Order o = get(id);
    if (o.getStatus()!=OrderStatus.FULFILLED) throw new IllegalStateException("Lejohet nga FULFILLED vetëm.");
    o.setStatus(OrderStatus.INVOICED);
    return repo.save(o);
  }

  @Transactional
  public Order close(Long id){
    Order o = get(id);
    if (o.getStatus()!=OrderStatus.INVOICED) throw new IllegalStateException("Lejohet nga INVOICED vetëm.");
    o.setStatus(OrderStatus.CLOSED);
    return repo.save(o);
  }

  public static OrderDTO toDTO(Order o){
    OrderDTO d = new OrderDTO();
    d.id = o.getId(); d.orderNo = o.getOrderNo();
    d.customerId = o.getCustomerId(); d.orderDate = o.getOrderDate();
    d.status = o.getStatus(); d.currency = o.getCurrency();
    d.lines = o.getLines().stream().map(l -> {
      OrderLineDTO x = new OrderLineDTO();
      x.id = l.getId(); x.productId = l.getProductId();
      x.qty = l.getQty(); x.unitPrice = l.getUnitPrice();
      x.taxRate = l.getTaxRate(); x.discount = l.getDiscount();
      return x;
    }).collect(Collectors.toList());
    return d;
  }
}
