package com.neoflow.minierp.repo;
import com.neoflow.minierp.entity.InventoryMovement; import org.springframework.data.jpa.repository.JpaRepository;
public interface InventoryRepo extends JpaRepository<InventoryMovement, Long>{}
