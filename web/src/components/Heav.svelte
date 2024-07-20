<script lang="ts">
  import { writable } from "svelte/store";
  import { slide } from "svelte/transition";
  import { quintOut } from "svelte/easing";
  import { fetchNui } from "../utils/fetchNui";
  import {
    Notify,
    currentCash,
    bankBalance,
    Locales,
    Currency,
  } from "../store/data";

  let withdrawAmount = writable($bankBalance);
  $: newBank = $bankBalance - $withdrawAmount;

  async function handleWithdraw() {
    if ($bankBalance < $withdrawAmount) {
      Notify(
        `${$Locales.withdraw_error} ${$withdrawAmount.toLocaleString(
          $Currency.lang,
          {
            style: "currency",
            currency: $Currency.currency,
            minimumFractionDigits: 0,
          }
        )}`,
        $Locales.error,
        "coins"
      );
    } else {
      Notify(
        `${$Locales.withdraw_success} ${$withdrawAmount.toLocaleString(
          $Currency.lang,
          {
            style: "currency",
            currency: $Currency.currency,
            minimumFractionDigits: 0,
          }
        )}`,
        $Locales.withdraw_success,
        "coins"
      );
      await fetchNui("ps-banking:client:ATMwithdraw", {
        amount: $withdrawAmount,
      });
      currentCash.update((cash) => cash + $withdrawAmount);
      bankBalance.update((balance) => balance - $withdrawAmount);
      withdrawAmount.set(0);
    }
  }
</script>

<!-- svelte-ignore a11y-label-has-associated-control -->
<div class="absolute w-full h-full bg-gray-800 text-white">
  <div
    class="absolute w-[90%] h-full p-6 overflow-auto left-[130px]"
    in:slide={{ duration: 1000, easing: quintOut }}
  >
    <div
      class="bg-gray-800/50 p-8 rounded-lg shadow-lg border border-blue-200/5"
    >
      <h2 class="text-3xl font-bold mb-6">{$Locales.withdraw}</h2>

      <div class="mb-12">
        <label class="block text-blue-200 mb-1">{$Locales.bank_balance}</label>
        <div class="flex items-center text-2xl font-semibold">
          <i class="fa-duotone fa-university text-gray-400 mr-2"></i>
          {$bankBalance.toLocaleString($Currency.lang, {
            style: "currency",
            currency: $Currency.currency,
            minimumFractionDigits: 0,
          })}
        </div>
      </div>

      <div class="mb-12">
        <label class="block text-blue-200 mb-1">{$Locales.amount}</label>
        <div class="relative">
          <i
            class="fa-duotone fa-money-bill-wave absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
          ></i>
          <input
            type="number"
            class="w-full rounded bg-gray-700/50 text-white pl-10 pr-4 py-3 border border-blue-200/10 rounded-lg focus:outline-none
              focus:border-blue-400/50 transition-colors duration-500"
            bind:value={$withdrawAmount}
          />
        </div>
      </div>

      <div class="mb-12">
        <label class="block text-blue-200 mb-1">{$Locales.new_bank}</label>
        <div class="flex items-center text-2xl font-semibold">
          <i class="fa-duotone fa-coins text-gray-400 mr-2"></i>
          {newBank.toLocaleString($Currency.lang, {
            style: "currency",
            currency: $Currency.currency,
            minimumFractionDigits: 0,
          })}
        </div>
      </div>

      <button
        class="w-full bg-blue-600/10 hover:bg-blue-700/10 text-white font-bold py-3 rounded transition duration-300 flex items-center justify-center border border-blue-500/50"
        on:click={handleWithdraw}
      >
        <i class="fa-duotone fa-money-check-edit text-lg mr-2"></i>
        {$Locales.withdraw_button}
      </button>
    </div>
  </div>
</div>
