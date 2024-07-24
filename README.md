# ps-banking
Compatible with QBCore and ESX.

# Depedency
1. [qb-core](https://github.com/qbcore-framework/qb-core) or [ESX](https://github.com/esx-framework)
2. [ox_lib](https://github.com/overextended/ox_lib)

# Installation
* Download release files.
* Drag and drop resource into your server files.
* Start resource through server.cfg.
* Add the ps-banking sql file to your database.
* Restart your server.

## Exports

### Create Bill
```bash
    # Creates a bill invoice in the bank
    exports["ps-banking"]:createBill({
        identifier = "HVZ84591", -- citizen id
        description = "Utility Bill", 
        type = "Expense",
        amount = 150.00,
    })
```

# Features
### Overview Tab:
Includes all essential features such as managing your bills, withdrawing all money, depositing cash, transferring money weekly via Simmy, viewing the latest transactions, and handling unpaid invoices.
![image](https://github.com/user-attachments/assets/7f22afa7-f4d8-427a-b9eb-42ef8b660801)

### Bills
Enables you to send and receive bills.
![image](https://github.com/user-attachments/assets/6d51ffb3-992c-4032-986c-c033c694302a)

### History
Displays a history of all transactions with options to delete specific transactions.
![image](https://github.com/user-attachments/assets/7beabc27-304a-402b-89e4-7d338140e498)

### Stats and Reports
Provides a summary of all transactions made, including total amounts, current balance, and transaction trends by date and amount.
![image](https://github.com/user-attachments/assets/879f0a59-818d-4a4e-a204-c1be4fc22057)

### Accounts
Allows you to create, add, or remove accounts, rename accounts, and perform deposits or withdrawals from specific accounts.
![image](https://github.com/user-attachments/assets/3ec1d109-1346-4148-aa17-f869972f2001)

### ATM Access
Deposit and withdraw from ATMs.
![image](https://github.com/user-attachments/assets/49c135aa-295c-40ed-aa15-962a939e36ae)

# Credits
* [BachPB](https://github.com/BachPB)
