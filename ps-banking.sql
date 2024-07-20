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
