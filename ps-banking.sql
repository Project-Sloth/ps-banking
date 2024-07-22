CREATE TABLE
    `ps_banking_transactions` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `identifier` VARCHAR(50) NOT NULL,
        `description` VARCHAR(255) NOT NULL,
        `type` VARCHAR(50) NOT NULL,
        `amount` DECIMAL(10, 2) NOT NULL,
        `date` DATE NOT NULL,
        `isIncome` BOOLEAN NOT NULL,
        PRIMARY KEY (`id`)
    ) ENGINE = InnoDB;

CREATE TABLE
    `ps_banking_bills` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `identifier` VARCHAR(50) NOT NULL,
        `description` VARCHAR(255) NOT NULL,
        `type` VARCHAR(50) NOT NULL,
        `amount` DECIMAL(10, 2) NOT NULL,
        `date` DATE NOT NULL,
        `isPaid` BOOLEAN NOT NULL,
        PRIMARY KEY (`id`)
    ) ENGINE = InnoDB;

CREATE TABLE
    `ps_banking_accounts` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `balance` BIGINT NOT NULL,
        `holder` VARCHAR(255) NOT NULL,
        `cardNumber` VARCHAR(255) NOT NULL,
        `users` JSON NOT NULL,
        `owner` JSON NOT NULL,
        PRIMARY KEY (`id`)
    ) ENGINE = InnoDB;

    

/* Dummy data (Ignore)
INSERT INTO `ps_banking_bills` (`identifier`, `description`, `type`, `amount`, `date`, `isPaid`) VALUES
('char1:df6c12c50e2712c57b1386e7103d5a372fb960a0', 'Utility Bill', 'Expense', 150.00, '2024-07-20', 0);

INSERT INTO `ps_banking_transactions` (`identifier`, `description`, `type`, `amount`, `date`, `isIncome`) VALUES
('char1:df6c12c50e2712c57b1386e7103d5a372fb960a0', 'Opened a new account', 'From account', 1000.00, '2022-08-13', 0),
('char1:df6c12c50e2712c57b1386e7103d5a372fb960a0', 'Deposited 500 DKK to account', 'To account', 500.00, '2022-08-13', 1),
('char1:df6c12c50e2712c57b1386e7103d5a372fb960a0', 'Deposited 500 DKK to account', 'To account', 500.00, '2022-08-13', 1),
('char1:df6c12c50e2712c57b1386e7103d5a372fb960a0', 'Withdrew 500 DKK from ATM', 'From account', -500.00, '2022-08-13', 0),
('char1:df6c12c50e2712c57b1386e7103d5a372fb960a0', 'Deposited 500 DKK to account', 'To account', 500.00, '2022-08-13', 1),
('char2:ab12c34d5e67f89g01234h56789i012j34kl567m8', 'Opened a new account', 'From account', 2000.00, '2022-08-14', 0),
('char2:ab12c34d5e67f89g01234h56789i012j34kl567m8', 'Deposited 1000 DKK to account', 'To account', 1000.00, '2022-08-14', 1),
('char2:ab12c34d5e67f89g01234h56789i012j34kl567m8', 'Withdrew 300 DKK from ATM', 'From account', -300.00, '2022-08-14', 0),
('char2:ab12c34d5e67f89g01234h56789i012j34kl567m8', 'Deposited 400 DKK to account', 'To account', 400.00, '2022-08-14', 1),
('char2:ab12c34d5e67f89g01234h56789i012j34kl567m8', 'Withdrew 200 DKK from ATM', 'From account', -200.00, '2022-08-14', 0);

 */
