package com.neoflow.minierp.controller;
import com.neoflow.minierp.entity.Order;
import com.neoflow.minierp.entity.OrderLine;
import com.neoflow.minierp.repo.OrderRepo;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.io.ByteArrayOutputStream;
import java.util.List;

@RestController
public class ReportsController {
  private final OrderRepo orderRepo;
  public ReportsController(OrderRepo r){ this.orderRepo = r; }

  @GetMapping("/api/reports/orders.xlsx")
  public ResponseEntity<byte[]> ordersXlsx() throws Exception {
    List<Order> orders = orderRepo.findAll();
    try (Workbook wb = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()){
      Sheet sh = wb.createSheet("Orders");
      int r=0;
      Row h = sh.createRow(r++);
      h.createCell(0).setCellValue("Order ID");
      h.createCell(1).setCellValue("Order No");
      h.createCell(2).setCellValue("Customer");
      h.createCell(3).setCellValue("Status");
      h.createCell(4).setCellValue("Currency");
      h.createCell(5).setCellValue("Lines");
      h.createCell(6).setCellValue("Amount");
      for (Order o : orders){
        double amount = o.getLines().stream().mapToDouble(l -> {
          double base=l.getQty()*l.getUnitPrice();
          return Math.max(0.0, base + base*(l.getTaxRate()/100.0) - l.getDiscount());
        }).sum();
        Row row = sh.createRow(r++);
        row.createCell(0).setCellValue(o.getId());
        row.createCell(1).setCellValue(o.getOrderNo()==null?"":o.getOrderNo());
        row.createCell(2).setCellValue(o.getCustomerId()==null?0:o.getCustomerId());
        row.createCell(3).setCellValue(o.getStatus()==null?"":o.getStatus().name());
        row.createCell(4).setCellValue(o.getCurrency()==null?"EUR":o.getCurrency());
        row.createCell(5).setCellValue(o.getLines()==null?0:o.getLines().size());
        row.createCell(6).setCellValue(amount);
      }
      for(int i=0;i<=6;i++) sh.autoSizeColumn(i);
      wb.write(out);
      byte[] bytes = out.toByteArray();
      return ResponseEntity.ok()
        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"orders.xlsx\"")
        .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
        .body(bytes);
    }
  }
}
