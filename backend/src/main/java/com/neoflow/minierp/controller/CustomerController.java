package com.neoflow.minierp.controller;
import com.neoflow.minierp.entity.Customer; import com.neoflow.minierp.repo.CustomerRepo;
import org.springframework.web.bind.annotation.*; import java.util.List;
@RestController @RequestMapping("/api/customers")
public class CustomerController {
  private final CustomerRepo repo; public CustomerController(CustomerRepo repo){this.repo=repo;}
  @GetMapping public List<Customer> all(){return repo.findAll();}
  @PostMapping public Customer create(@RequestBody Customer c){return repo.save(c);}
  @PutMapping("/{id}") public Customer update(@PathVariable Long id,@RequestBody Customer c){c.setId(id); return repo.save(c);}
  @DeleteMapping("/{id}") public void delete(@PathVariable Long id){repo.deleteById(id);}
}
