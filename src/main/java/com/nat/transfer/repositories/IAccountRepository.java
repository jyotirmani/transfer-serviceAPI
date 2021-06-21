package com.nat.transfer.repositories;

import org.springframework.data.repository.CrudRepository;

import com.nat.transfer.domain.Account;

public interface IAccountRepository extends CrudRepository<Account, Long> {

	Account findByName(String name);
}
