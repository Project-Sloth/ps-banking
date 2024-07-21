<script lang="ts">
  import { writable } from "svelte/store";
  import { onMount } from "svelte";
  import { quintOut } from "svelte/easing";
  import { slide, fade, scale } from "svelte/transition";
  import { fetchNui } from "../utils/fetchNui";
  import {
    showOverview,
    showBills,
    showHistory,
    notifications,
    Bills,
    Notify,
    Transactions,
    Locales,
    Currency,
    type Notification,
  } from "../store/data";

  // Sample data
  let transactions = Transactions;
  let searchQuery = writable("");
  let showDeleteAllModal = writable(false);

  $: filteredTransactions = $transactions.filter(
    (transaction) =>
      transaction.description
        .toLowerCase()
        .includes($searchQuery.toLowerCase()) ||
      transaction.type.toLowerCase().includes($searchQuery.toLowerCase())
  );

  function confirmDeleteAllTransactions() {
    showDeleteAllModal.set(true);
  }

  async function deleteAllTransactions() {
    if ($transactions.length === 0) {
      Notify($Locales.history_empty, $Locales.error, "file-invoice");
      showDeleteAllModal.set(false);
    } else {
      transactions.set([]);
      showDeleteAllModal.set(false);
      Notify($Locales.all_history_deleted, $Locales.success, "file-invoice");
      try {
        const history = await fetchNui("ps-banking:client:deleteHistory", {});
        transactions.set([]);
      } catch (error) {
        console.error(error);
      }
    }
  }

  function formatDate(dateString: string) {
    const options: Intl.DateTimeFormatOptions = {
      year: "numeric",
      month: "numeric",
      day: "numeric",
    };
    return new Date(dateString).toLocaleDateString(undefined, options);
  }

  onMount(async () => {
    try {
      const history = await fetchNui("ps-banking:client:getHistory", {});
      transactions.set(history);
    } catch (error) {
      console.error(error);
    }
  });
</script>

<div class="absolute w-full h-full bg-gray-800">
  <div
    class="absolute w-[90%] h-full p-6 overflow-auto left-[130px] text-blue-200"
    in:slide={{ duration: 1000, easing: quintOut }}
  >
    <div
      class="bg-gray-800/50 p-8 rounded-lg shadow-lg border border-blue-200/5"
    >
      <div class="flex items-center mb-4">
        <i class="fa-duotone fa-list text-2xl text-blue-400 mr-3"></i>
        <h2 class="text-2xl font-bold">{$Locales.history}</h2>
      </div>
      <div class="flex justify-between items-center mb-4">
        <div class="flex items-center">
          <i class="fa-duotone fa-wallet text-xl text-gray-400 mr-2"></i>
          <span class="text-gray-400">{$Locales.total}</span>
        </div>
        <div class="absolute right-16 top-10">
          <i class="fa-duotone fa-receipt text-xl text-gray-400 mr-2"></i>
          <span class="text-xl text-white font-semibold">
            {filteredTransactions.length}
          </span>
        </div>
        <button
          class="bg-gray-700/50 text-blue-200 py-2 px-4 rounded-lg flex items-center hover:bg-gray-500/50 transition duration-500 border border-gray-500/20"
          on:click={confirmDeleteAllTransactions}
        >
          <i class="fa-duotone fa-trash-alt mr-2"
          ></i>{$Locales.delete_all_transactions}
        </button>
      </div>
      <div class="relative mb-6">
        <i class="fa-duotone fa-search absolute left-4 top-4 text-gray-400"></i>
        <input
          type="text"
          class="w-full rounded bg-gray-700/50 text-white pl-10 pr-4 py-3 border border-blue-200/10 rounded-lg focus:outline-none
              focus:border-blue-400/50 transition-colors duration-500"
          placeholder={$Locales.search_transactions}
          bind:value={$searchQuery}
        />
      </div>
      <div class="space-y-4">
        {#each filteredTransactions as transaction (transaction.id)}
          <div
            class="bg-[#334155] p-4 rounded-lg shadow-md transition duration-300 border border-blue-200/5"
            out:slide={{ duration: 500 }}
          >
            <div class="flex justify-between items-center">
              <div class="flex items-center">
                <i
                  class={`fa-duotone ${transaction.isIncome ? "fa-arrow-down-to-arc" : "fa-arrow-up-from-arc"} text-xl mr-3 ${transaction.isIncome ? "text-green-400" : "text-red-400"}`}
                ></i>
                <div>
                  <div class="flex items-center">
                    <i
                      class="fa-duotone fa-file-invoice text-lg text-gray-300 mr-2"
                    ></i>
                    <p class="text-lg font-bold">
                      {transaction.description} #{transaction.id}
                    </p>
                  </div>
                  <div class="flex items-center">
                    <i
                      class="fa-duotone fa-exchange-alt text-sm text-gray-400 mr-2"
                    ></i>
                    <p class="text-sm text-gray-400">{transaction.type}</p>
                  </div>
                  <div class="flex items-center">
                    <i class="fa-duotone fa-clock text-xs text-gray-500 mr-2"
                    ></i>
                    <p class="text-xs text-gray-500">
                      {formatDate(transaction.date)}
                    </p>
                  </div>
                </div>
              </div>
              <div class="text-right">
                <div class="flex items-center">
                  <i class="fa-duotone fa-coins text-lg text-gray-400 mr-2"></i>
                  <p
                    class={`text-lg font-bold ${transaction.isIncome ? "text-green-500" : "text-red-500"}`}
                  >
                    {transaction.isIncome ? "+" : "-"}
                    {transaction.amount.toLocaleString($Currency.lang, {
                      style: "currency",
                      currency: $Currency.currency,
                      minimumFractionDigits: 0,
                    })}
                  </p>
                </div>
              </div>
            </div>
          </div>
        {/each}
      </div>
    </div>
  </div>
</div>
{#if $showDeleteAllModal}
  <div
    class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50"
  >
    <div
      class="bg-gray-700 p-8 rounded-lg shadow-lg w-96"
      in:scale={{ duration: 250, easing: quintOut }}
      out:scale={{ duration: 250, easing: quintOut }}
    >
      <div class="flex items-center mb-4">
        <i class="fa-duotone fa-question-circle text-3xl text-blue-400 mr-3"
        ></i>
        <h2 class="text-2xl text-blue-200 font-bold">
          {$Locales.are_you_sure}
        </h2>
      </div>
      <p class="text-gray-300 mb-6">
        {$Locales.delete_confirmation}
      </p>
      <div class="flex justify-between items-center">
        <button
          class="flex items-center bg-red-600 hover:bg-red-700 text-white py-2 px-4 rounded focus:outline-none"
          on:click={() => showDeleteAllModal.set(false)}
        >
          <i class="fa-duotone fa-times-circle mr-2"></i>{$Locales.cancel}
        </button>
        <button
          class="flex items-center bg-blue-600 hover:bg-blue-700 text-white py-2 px-4 rounded focus:outline-none"
          on:click={deleteAllTransactions}
        >
          <i class="fa-duotone fa-check-circle mr-2"></i>{$Locales.confirm}
        </button>
      </div>
    </div>
  </div>
{/if}
