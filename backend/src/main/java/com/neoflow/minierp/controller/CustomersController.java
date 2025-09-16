package com.neoflow.minierp.controller;
import com.neoflow.minierp.entity.Customer;
import com.neoflow.minierp.repo.CustomerRepo;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.net.URI;
import java.util.List;

@RestController @RequestMapping("/api/customers")
public class CustomersController {
  private final CustomerRepo repo;
  public CustomersController(CustomerRepo r){ this.repo=r; }

  @GetMapping public List<Customer> list(@RequestParam(required=false) String q){
    return (q==null||q.isBlank()) ? repo.findAll() : repo.findByNameContainingIgnoreCase(q);
  }
  @GetMapping("/{id}") public Customer get(@PathVariable Long id){ return repo.findById(id).orElseThrow(); }
  @PostMapping public ResponseEntity<Customer> create(@RequestBody Customer c){
    Customer saved = repo.save(c); return ResponseEntity.created(URI.create("/api/customers/"+saved.getId())).body(saved);
  }
  @PutMapping("/{id}") public Customer update(@PathVariable Long id, @RequestBody Customer c){
    Customer e = repo.findById(id).orElseThrow();
    e.setName(c.getName()); e.setEmail(c.getEmail()); e.setPhone(c.getPhone()); e.setCity(c.getCity());
    return repo.save(e);
  }
  @DeleteMapping("/{id}") public ResponseEntity<Void> delete(@PathVariable Long id){ repo.deleteById(id); return ResponseEntity.noContent().build(); }
}
