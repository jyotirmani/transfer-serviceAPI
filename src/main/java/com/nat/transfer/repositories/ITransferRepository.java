package com.nat.transfer.repositories;

import org.springframework.data.repository.CrudRepository;

import com.nat.transfer.domain.Transfer;

public interface ITransferRepository extends CrudRepository<Transfer, Long> {
}
