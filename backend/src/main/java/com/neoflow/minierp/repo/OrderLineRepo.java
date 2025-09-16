package com.neoflow.minierp.repo;
import com.neoflow.minierp.entity.OrderLine; import org.springframework.data.jpa.repository.JpaRepository;
public interface OrderLineRepo extends JpaRepository<OrderLine, Long>{}
