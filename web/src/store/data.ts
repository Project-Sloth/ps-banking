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
export const showATM = writable(false);
export const currentCash = writable(500);
export const bankBalance = writable(10000);

export const Currency = writable({
  lang: "en", // da-DK
  currency: "USD", // DKK
});

export const Locales = writable({
  // ATM
  atm: "ATM",
  cash: "Kontant",
  bank_balance: "Bank Saldo",
  withdraw_2000: "Hæv 2,000kr",
  withdraw_5000: "Hæv 5,000kr",
  withdraw_10000: "Hæv 10,000kr",
  deposit_2000: "Indsæt 2,000kr",
  deposit_5000: "Indsæt 5,000kr",
  deposit_10000: "Indsæt 10,000kr",
  deposit_amount: "Indsæt Beløb",
  withdraw_amount: "Hæv Beløb",
  submit: "Indsæt",
  close: "Luk",
  // Main
  overview: "Oversigt",
  bills: "Regninger",
  history: "Historie",
  withdraw: "Hæv",
  deposit: "Indsæt",
  stats: "Stats",
  // Bills
  transactions: "Transaktioner",
  total: "Total",
  search_transactions: "Søg i transaktioner...",
  description: "Beskrivelse",
  type: "Type",
  time_ago: "For X Tid Siden",
  amount: "Beløb",
  date: "Dato",
  pay_invoice: "Betal Faktura",
  payment_completed: "Betaling gennemført",
  from: "fra",
  // History
  delete_all_transactions: "Slet Alle Transaktioner",
  are_you_sure: "Er du sikker?",
  delete_confirmation:
    "Er du sikker på, at du vil slette alle dine transaktioner? (Gør kun dette hvis menuen lagger!)",
  cancel: "Annuller",
  confirm: "Bekræft",
  history_empty: "Din historie er tom",
  all_history_deleted: "Du har slettet alt i din historie",
  error: "Fejl",
  success: "Succes",
  // Heav
  new_cash: "Nye kontanter",
  withdraw_success: "Hævning Vellykket",
  withdraw_error: "Din bankkonto har ikke",
  withdraw_button: "HÆV",
  new_bank: "Ny bank saldo",
  // Indseat
  current_cash: "Nuværende kontanter",
  deposit_success: "Indbetaling Vellykket",
  deposit_error: "Du har ikke",
  deposit_button: "INDBETAL",
  // Overview
  total_balance: "Total balance",
  quick_actions: "Hurtige Handlinger",
  transfer_money: "Overfør Penge",
  easy_transfer: "Let overfør penge til personer",
  transfer: "Overfør",
  pay_bills: "Betal Regninger",
  pay_pending_bills: "Hurtig betal dine ventende regninger",
  pay: "Betal",
  withdraw_all_money: "Hæv alle dine penge",
  withdraw_all_from_account: "Hæv alle dine penge fra din konto",
  deposit_cash: "Indsæt Kontanter",
  deposit_all_cash: "Indsæt alle dine kontanter på din konto",
  weekly_summary: "Ugens Oversigt",
  income: "Indkomst",
  expenses: "Udgifter",
  report: "Rapport",
  latest_transactions: "Seneste Transaktioner",
  see_all: "SE ALLE",
  unpaid_bills: "Ubetalte Fakturaer",
  no_unpaid_bills: "Ingen ubetalte fakturaer",
  confirm_pay_all_bills:
    "Er du sikker på, at du vil betale alle dine regninger?",
  pay_all_bills: "Betal Alle Regninger",
  pay_all_bills_success: "Du har betalt alle dine regninger!",
  pay_all_bills_error: "Du har ikke nogle regninger",
  payment_method: "Betalings Metode",
  phone_number: "Telefonnummer",
  id: "ID",
  id_or_phone_number: "ID eller Telefonnummer",
  no_cash_on_you: "Du har ikke nogle kontanter på dig",
  deposit_all_success: "Alt fra din konto er hævet",
  no_money_on_account: "Din konto er tom",
  withdraw_all_success: "Du har sat alle dine kontanter i banken",
  invoices: "Invoices",
  // Stats
  statistics_reports: "Statistics and Reports",
  balance_trend: "Balance Trend",
  balance: "Balance",
  used: "Used",
  month: "Month",
  balance_dkk: "Balance (DKK)",
  withdrawn: "Du har hævet",
  deposited: "Du har indsat",
  no_transactions: "No recent transactions",
  transactions_trend: "Transaktioner Trend",
  total_transactions: "Totale Transaktioner",
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
