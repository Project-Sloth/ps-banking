<script lang="ts">
  import { onMount } from "svelte";
  import { writable } from "svelte/store";
  import { slide } from "svelte/transition";
  import { quintOut } from "svelte/easing";
  import {
    Notify,
    currentCash,
    bankBalance,
    Locales,
    Currency,
  } from "../store/data";
  import { fetchNui } from "../utils/fetchNui";

  let depositAmount = writable($currentCash);

  $: newCash = $currentCash - $depositAmount;

  async function handleDeposit() {
    if ($currentCash < $depositAmount) {
      Notify(
        `${$Locales.deposit_error} ${$depositAmount.toLocaleString(
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
        `${$Locales.deposit_success} ${$depositAmount.toLocaleString(
          $Currency.lang,
          {
            style: "currency",
            currency: $Currency.currency,
            minimumFractionDigits: 0,
          }
        )} `,
        $Locales.deposit_success,
        "coins"
      );
      await fetchNui("ps-banking:client:ATMdeposit", {
        amount: $depositAmount,
      });
      currentCash.update((cash) => cash - $depositAmount);
      bankBalance.update((balance) => balance + $depositAmount);
      depositAmount.set(0);
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
      <h2 class="text-3xl font-bold mb-6">{$Locales.deposit}</h2>

      <div class="mb-12">
        <label class="block text-blue-200 mb-1">{$Locales.current_cash}</label>
        <div class="flex items-center text-2xl font-semibold">
          <i class="fa-duotone fa-wallet text-gray-400 mr-2"></i>
          {$currentCash.toLocaleString($Currency.lang, {
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
            bind:value={$depositAmount}
          />
        </div>
      </div>

      <div class="mb-12">
        <label class="block text-blue-200 mb-1">{$Locales.new_cash}</label>
        <div class="flex items-center text-2xl font-semibold">
          <i class="fa-duotone fa-coins text-gray-400 mr-2"></i>
          {newCash.toLocaleString($Currency.lang, {
            style: "currency",
            currency: $Currency.currency,
            minimumFractionDigits: 0,
          })}
        </div>
      </div>

      <button
        class="w-full bg-blue-600/10 hover:bg-blue-700/10 text-white font-bold py-3 rounded transition duration-300 flex items-center justify-center border border-blue-500/50"
        on:click={handleDeposit}
      >
        <i class="fa-duotone fa-money-check-edit text-lg mr-2"></i>
        {$Locales.deposit_button}
      </button>
    </div>
  </div>
</div>
