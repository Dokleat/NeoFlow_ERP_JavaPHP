package com.neoflow.minierp.repo;
import com.neoflow.minierp.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface CustomerRepo extends JpaRepository<Customer, Long> {
  List<Customer> findByNameContainingIgnoreCase(String q);
}
