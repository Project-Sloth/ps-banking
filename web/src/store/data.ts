import { writable, type Writable } from "svelte/store";

export interface Notification {
  id: number;
  message: string;
  title: string;
  icon: string;
}

export const notifications = writable<Notification[]>([]);
let notificationId = 0;

export function Notify(message: string, title: string, icon: string) {
  notificationId += 1;
  const newNotification: Notification = {
    id: notificationId,
    message,
    title,
    icon,
  };
  notifications.update((n) => [...n, newNotification]);
  setTimeout(() => {
    notifications.update((n) =>
      n.filter((notification) => notification.id !== newNotification.id)
    );
  }, 2000);
}

export const showOverview = writable(true);
export const showBills = writable(false);
export const showHistory = writable(false);
export const showHeav = writable(false);
export const showIndseat = writable(false);
export const showStats = writable(false);
export const showAccounts = writable(false);
export const showATM = writable(false);
export const currentCash = writable(500);
export const bankBalance = writable(10000);

export const Currency = writable({
  lang: "en", // da-DK
  currency: "USD", // DKK
});

export const Locales = writable({
  atm: "ATM",
  cash: "Cash",
  bank_balance: "Bank Balance",
  deposit_amount: "Deposit Amount",
  withdraw_amount: "Withdraw Amount",
  submit: "Submit",
  close: "Close",
  overview: "Overview",
  bills: "Bills",
  history: "History",
  withdraw: "Withdraw",
  deposit: "Deposit",
  stats: "Stats",
  transactions: "Transactions",
  total: "Total",
  search_transactions: "Search transactions...",
  description: "Description",
  type: "Type",
  time_ago: "Time Ago",
  amount: "Amount",
  date: "Date",
  pay_invoice: "Pay Invoice",
  payment_completed: "Payment Completed",
  from: "From",
  delete_all_transactions: "Delete All Transactions",
  are_you_sure: "Are you sure?",
  delete_confirmation:
    "Are you sure you want to delete all your transactions? (Only do this if the menu lags!)",
  cancel: "Cancel",
  confirm: "Confirm",
  history_empty: "Your history is empty",
  all_history_deleted: "You have deleted all your history",
  error: "Error",
  success: "Success",
  new_cash: "New Cash",
  withdraw_success: "Withdrawal Successful",
  withdraw_error: "Your bank account does not have enough funds",
  withdraw_button: "WITHDRAW",
  new_bank: "New Bank Balance",
  current_cash: "Current Cash",
  deposit_success: "Deposit Successful",
  deposit_error: "You do not have enough cash",
  deposit_button: "DEPOSIT",
  total_balance: "Total Balance",
  quick_actions: "Quick Actions",
  transfer_money: "Transfer Money",
  easy_transfer: "Easily transfer money to people",
  transfer: "Transfer",
  pay_bills: "Pay Bills",
  pay_pending_bills: "Quickly pay your pending bills",
  pay: "Pay",
  withdraw_all_money: "Withdraw All Money",
  withdraw_all_from_account: "Withdraw all your money from your account",
  deposit_cash: "Deposit Cash",
  deposit_all_cash: "Deposit all your cash into your account",
  weekly_summary: "Weekly Summary",
  income: "Income",
  expenses: "Expenses",
  report: "Report",
  latest_transactions: "Latest Transactions",
  see_all: "SEE ALL",
  unpaid_bills: "Unpaid Invoices",
  no_unpaid_bills: "No unpaid invoices",
  confirm_pay_all_bills: "Are you sure you want to pay all your bills?",
  pay_all_bills: "Pay All Bills",
  pay_all_bills_success: "You have paid all your bills!",
  pay_all_bills_error: "You have no bills",
  payment_method: "Payment Method",
  phone_number: "Phone Number",
  id: "ID",
  id_or_phone_number: "ID or Phone Number",
  no_cash_on_you: "You have no cash on you",
  deposit_all_success: "All your cash has been deposited",
  no_money_on_account: "Your account is empty",
  withdraw_all_success: "You have withdrawn all your money from the account",
  invoices: "Invoices",
  statistics_reports: "Statistics and Reports",
  balance_trend: "Balance Trend",
  balance: "Balance",
  used: "Used",
  month: "Month",
  balance_dkk: "Balance",
  withdrawn: "You have withdrawn",
  deposited: "You have deposited",
  no_transactions: "No recent transactions",
  transactions_trend: "Transactions Trend",
  total_transactions: "Total Transactions",
  accounts: "Accounts",
  account_number_copied: "Account number copied to clipboard",
  new_user_to_account: "New user to account",
  server_id: "Server ID",
  add_user: "Add User",
  new_account_name: "New Account Name",
  new_name: "New Name",
  rename: "Rename",
  create_new_account: "Create New Account",
  account_holder: "Account Holder",
  initial_balance: "Initial Balance",
  create: "Create",
  delete_account: "Delete Account",
  are_you_sure_you_want_to_delete_this_account:
    "Are you sure you want to delete this account?",
  delete: "Delete",
  remove_user_from_account: "Remove User from Account",
  select_user: "Select User",
  remove: "Remove",
  withdraw_from_account: "Withdraw from Account",
  deposit_to_account: "Deposit to Account",
  removed_successfully: "removed Successfully",
  select_account_and_user: "Please select an account and a user",
  account_deleted_successfully: "Account deleted successfully",
  new_account_created_successfully: "New account created successfully",
  withdrew: "Withdrew",
  successfully: "Successfully",
  select_valid_account_and_amount: "Please select a valid account and amount",
  openBank: "Access Bank",
  openATM: "Access ATM",
  account_deletion_failed: "Account deletion failed",
  withdrawal_failed: "Withdrawal failed",
  deposit_failed: "Deposit failed",
  user_added_successfully: "added successfully",
  user_addition_failed: "Failed to add user",
  new_account_creation_failed: "Failed to create new account",
  account_renamed_successfully: "Account renamed successfully",
  account_rename_failed: "Account rename failed",
  rename_account: "Change name",
});

export const Transactions: Writable<Array<any>> = writable([
  // {
  //   id: 8,
  //   description: "Åbnede en ny konto",
  //   type: "Fra konto",
  //   amount: 1000,
  //   date: "2022/08/13",
  //   timeAgo: "For 18 timer siden",
  //   isIncome: false,
  // },
  // {
  //   id: 7,
  //   description: "Indsatte 500 DKK på konto",
  //   type: "Til konto",
  //   amount: 500,
  //   date: "2022/08/13",
  //   timeAgo: "For 18 timer siden",
  //   isIncome: true,
  // },
  // {
  //   id: 6,
  //   description: "Indsatte 500 DKK på konto",
  //   type: "Til konto",
  //   amount: 500,
  //   date: "2022/08/13",
  //   timeAgo: "For 18 timer siden",
  //   isIncome: true,
  // },
  // {
  //   id: 5,
  //   description: "Hævede 500 DKK fra en hæveautomat",
  //   type: "Fra konto",
  //   amount: -500,
  //   date: "2022/08/13",
  //   timeAgo: "For 18 timer siden",
  //   isIncome: false,
  // },
  // {
  //   id: 4,
  //   description: "Indsatte 500 DKK på konto",
  //   type: "Til konto",
  //   amount: 500,
  //   date: "2022/08/13",
  //   timeAgo: "For 18 timer siden",
  //   isIncome: true,
  // },
]);

export const Bills: Writable<Array<any>> = writable([
  // {
  //   id: 1,
  //   description: "Mekaniker Regning",
  //   type: "Auto Exotic",
  //   amount: 1000,
  //   date: "2022/08/13",
  //   timeAgo: "For 18 timer siden",
  //   isPaid: false,
  // },
  // {
  //   id: 2,
  //   description: "Mekaniker Regning",
  //   type: "Auto Exotic",
  //   amount: 1000,
  //   date: "2022/08/13",
  //   timeAgo: "For 18 timer siden",
  //   isPaid: false,
  // },
  // {
  //   id: 3,
  //   description: "Mekaniker Regning",
  //   type: "Auto Exotic",
  //   amount: 1000,
  //   date: "2022/08/13",
  //   timeAgo: "For 18 timer siden",
  //   isPaid: false,
  // },
]);
