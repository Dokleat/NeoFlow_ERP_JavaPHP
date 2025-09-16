package com.neoflow.minierp.repo;
import com.neoflow.minierp.entity.Product; import org.springframework.data.jpa.repository.JpaRepository;
public interface ProductRepo extends JpaRepository<Product, Long>{}
