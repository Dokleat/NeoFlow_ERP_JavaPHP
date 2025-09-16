package com.neoflow.minierp.controller;
import com.neoflow.minierp.entity.PurchaseInvoice;
import com.neoflow.minierp.repo.PurchaseInvoiceRepo;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.net.URI;
import java.util.List;

@RestController @RequestMapping("/api/purchase-invoices")
public class PurchaseInvoicesController {
  private final PurchaseInvoiceRepo repo;
  public PurchaseInvoicesController(PurchaseInvoiceRepo r){ this.repo=r; }

  @GetMapping public List<PurchaseInvoice> list(){ return repo.findAll(); }
  @PostMapping public ResponseEntity<PurchaseInvoice> create(@RequestBody PurchaseInvoice p){
    PurchaseInvoice s = repo.save(p);
    return ResponseEntity.created(URI.create("/api/purchase-invoices/"+s.getId())).body(s);
  }
  @DeleteMapping("/{id}") public ResponseEntity<Void> delete(@PathVariable Long id){
    repo.deleteById(id); return ResponseEntity.noContent().build();
  }
}
