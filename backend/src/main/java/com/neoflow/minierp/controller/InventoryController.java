package com.neoflow.minierp.controller;
import com.neoflow.minierp.entity.Product;
import com.neoflow.minierp.entity.InventoryMovement;
import com.neoflow.minierp.repo.ProductRepo;
import com.neoflow.minierp.repo.InventoryRepo;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/inventory")
public class InventoryController {
  private final ProductRepo pRepo; private final InventoryRepo iRepo;
  public InventoryController(ProductRepo pRepo, InventoryRepo iRepo){ this.pRepo=pRepo; this.iRepo=iRepo; }

  @PostMapping("/move")
  public Product move(@RequestParam Long productId,
                      @RequestParam String type, // IN, OUT, ADJUST
                      @RequestParam int qty,
                      @RequestParam(required=false, defaultValue="") String ref){
    Product p = pRepo.findById(productId).orElseThrow();
    int delta = switch (type) { case "IN" -> qty; case "OUT" -> -qty; default -> qty; };
    p.setStockQty(p.getStockQty() + delta);
    InventoryMovement m = new InventoryMovement();
    m.setProduct(p); m.setMovementType(type); m.setQuantity(qty); m.setReference(ref);
    iRepo.save(m);
    return pRepo.save(p);
  }
}
