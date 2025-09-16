package com.neoflow.minierp.controller;
import com.neoflow.minierp.entity.Product; import com.neoflow.minierp.repo.ProductRepo;
import org.springframework.web.bind.annotation.*; import java.util.List;
@RestController @RequestMapping("/api/products")
public class ProductController {
  private final ProductRepo repo; public ProductController(ProductRepo repo){this.repo=repo;}
  @GetMapping public List<Product> all(){return repo.findAll();}
  @PostMapping public Product create(@RequestBody Product p){return repo.save(p);}
  @PutMapping("/{id}") public Product update(@PathVariable Long id,@RequestBody Product p){p.setId(id); return repo.save(p);}
  @DeleteMapping("/{id}") public void delete(@PathVariable Long id){repo.deleteById(id);}
}
