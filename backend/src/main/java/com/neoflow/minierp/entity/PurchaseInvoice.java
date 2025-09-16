package com.neoflow.minierp.entity;
import jakarta.persistence.*;
import java.time.LocalDate;

@Entity @Table(name="ap_purchase_invoices")
public class PurchaseInvoice {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  private String vendorName;
  private LocalDate invoiceDate = LocalDate.now();
  private String currency = "EUR";
  private double amount;
  public Long getId(){return id;} public String getVendorName(){return vendorName;}
  public void setVendorName(String v){vendorName=v;}
  public LocalDate getInvoiceDate(){return invoiceDate;} public void setInvoiceDate(LocalDate d){invoiceDate=d;}
  public String getCurrency(){return currency;} public void setCurrency(String c){currency=c;}
  public double getAmount(){return amount;} public void setAmount(double a){amount=a;}
}
