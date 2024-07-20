<script lang="ts">
  import { writable } from "svelte/store";
  import { onMount } from "svelte";
  import { fetchNui } from "../utils/fetchNui";
  import { slide, fade, scale } from "svelte/transition";
  import { quintOut } from "svelte/easing";
  import { Bills } from "../store/data";
  import { Notify, Locales, Currency } from "../store/data";

  let transactions = Bills;
  let searchQuery = writable("");

  $: filteredTransactions = $transactions.filter(
    (transaction) =>
      transaction.description
        .toLowerCase()
        .includes($searchQuery.toLowerCase()) ||
      transaction.type.toLowerCase().includes($searchQuery.toLowerCase())
  );

  function formatDate(dateString: string) {
    const options: Intl.DateTimeFormatOptions = {
      year: "numeric",
      month: "numeric",
      day: "numeric",
    };
    return new Date(dateString).toLocaleDateString(undefined, options);
  }

  async function payBill(transaction: { id: any; type: any }) {
    try {
      const result = await fetchNui("ps-banking:client:payBill", {
        id: transaction.id,
      });
      if (result) {
        Notify(
          `${$Locales.pay_invoice} #${transaction.id} ${$Locales.from} ${transaction.type}`,
          $Locales.payment_completed,
          "coins"
        );
        transactions.update((items) => {
          const index = items.findIndex((t) => transaction.id === t.id);
          if (index !== -1) {
            items.splice(index, 1);
          }
          return items;
        });
        return true;
      } else {
        Notify(`${$Locales.no_money_on_account}`, `${$Locales.error}`, "coins");
        return false;
      }
    } catch (error) {
      console.error(error);
      return false;
    }
  }

  onMount(async () => {
    try {
      const response = await fetchNui("ps-banking:client:getBills", {});
      Bills.set(response);
    } catch (error) {
      console.error(error);
    }
  });
</script>

<div class="absolute w-full h-full bg-gray-800 text-white">
  <div
    class="absolute w-[90%] h-full p-6 overflow-auto left-[130px]"
    in:slide={{ duration: 1000, easing: quintOut }}
  >
    <div
      class="bg-gray-800/50 p-8 rounded-lg shadow-lg border border-blue-200/5"
    >
      <div class="flex justify-between items-center mb-6">
        <div class="flex items-center">
          <i class="fa-duotone fa-list text-3xl text-blue-200 mr-3"></i>
          <h2 class="text-3xl font-bold text-blue-200">{$Locales.bills}</h2>
        </div>
        <div class="bg-[#334155] rounded-full px-3 py-1 flex items-center">
          <i class="fa-duotone fa-file-invoice-dollar text-gray-400 mr-2"></i>
          <span class="text-sm text-gray-400 mr-2">{$Locales.total}</span>
          <span class="text-lg font-semibold text-white">
            {$transactions.length}
          </span>
        </div>
      </div>
      <div class="relative mb-6">
        <i class="fa-duotone fa-search absolute left-4 top-4 text-gray-400"></i>
        <input
          type="text"
          class="w-full bg-gray-800 text-white pl-10 pr-4 py-3 rounded-lg border border-blue-200/10 focus:outline-none focus:border-blue-400/50 transition-colors duration-500 placeholder-gray-500"
          placeholder={$Locales.search_transactions}
          bind:value={$searchQuery}
        />
      </div>
      <div class="space-y-6">
        {#each filteredTransactions as transaction (transaction.id)}
          <div
            class="p-4 bg-[#334155] rounded-lg flex justify-between items-center"
            out:slide={{ duration: 1000, easing: quintOut }}
          >
            <div class="flex flex-col space-y-1">
              <div class="flex items-center space-x-2">
                <i class="fa-duotone fa-file-invoice text-2xl text-[#f1f5f9]"
                ></i>
                <span class="font-semibold text-[#f1f5f9]"
                  >{transaction.description} #{transaction.id}</span
                >
              </div>
              <div class="flex items-center space-x-2">
                <i class="fa-duotone fa-user text-sm text-gray-400"></i>
                <span class="text-sm text-gray-400">{transaction.type}</span>
              </div>
              <div class="flex items-center space-x-2">
                <i class="fa-duotone fa-clock text-xs text-gray-500"></i>
                <span class="text-xs text-gray-500"
                  >{formatDate(transaction.date)}</span
                >
              </div>
            </div>
            <div class="text-right flex flex-col items-end space-y-1">
              <span
                class={`text-lg font-bold ${transaction.isIncome ? "text-green-500" : "text-red-500"}`}
              >
                <i class="fa-duotone fa-coins text-lg text-gray-400 mr-2"></i>
                {transaction.isIncome ? "+" : "-"}
                {transaction.amount.toLocaleString($Currency.lang, {
                  style: "currency",
                  currency: $Currency.currency,
                  minimumFractionDigits: 0,
                })}
              </span>
              {#if !transaction.isPaid}
                <button
                  class="bg-blue-600/10 border border-blue-500 hover:bg-blue-800/50 text-white font-bold py-2 px-4 rounded-lg flex items-center transition-colors duration-300"
                  on:click={() => {
                    payBill(transaction);
                  }}
                >
                  <i class="fa-duotone fa-money-check-edit text-lg mr-2"></i>
                  {$Locales.pay_invoice}
                </button>
              {/if}
            </div>
          </div>
        {/each}
      </div>
    </div>
  </div>
</div>
