<script lang="ts">
  import { onMount } from "svelte";
  import { useNuiEvent } from "../utils/useNuiEvent";
  import { fetchNui } from "../utils/fetchNui";
  import { visibility } from "../store/stores";
  import OverviewPage from "./Overview.svelte";
  import BillsPage from "./Bills.svelte";
  import HistoryPage from "./History.svelte";
  import HeavPage from "./Heav.svelte";
  import IndseatPage from "./Indseat.svelte";
  import StatsPage from "./Stats.svelte";
  import AccountsPage from "./Accounts.svelte";
  import { slide, fade, scale } from "svelte/transition";
  import { quintOut } from "svelte/easing";
  import {
    showOverview,
    showBills,
    showHistory,
    showHeav,
    showIndseat,
    showStats,
    showAccounts,
    Locales,
    bankBalance,
    currentCash,
  } from "../store/data";
  import { writable } from "svelte/store";

  async function updateBalances() {
    try {
      const response = await fetchNui("ps-banking:client:getMoneyTypes", {});
      const bank = response.find(
        (item: { name: string }) => item.name === "bank"
      );
      const cash = response.find(
        (item: { name: string }) => item.name === "cash"
      );
      if (bank) {
        bankBalance.set(bank.amount);
      }
      if (cash) {
        currentCash.set(cash.amount);
      }
    } catch (error) {
      console.error(error);
    }
  }

  onMount(async () => {
    updateBalances();
    try {
      const response = await fetchNui("ps-banking:client:getLocales", {});
      Locales.set(response);
    } catch (error) {
      console.error(error);
    }
  });
</script>

<div
  class="h-screen w-screen flex flex-col items-center justify-center select-none overflow-hidden"
>
  <div
    class="absolute w-[80%] h-[90%] rounded-xl overflow-hidden"
    in:scale={{ duration: 1000, easing: quintOut }}
    out:fade={{ duration: 1000, easing: quintOut }}
  >
    {#if $showOverview}
      <OverviewPage />
    {:else if $showBills}
      <BillsPage />
    {:else if $showHistory}
      <HistoryPage />
    {:else if $showHeav}
      <HeavPage />
    {:else if $showIndseat}
      <IndseatPage />
    {:else if $showStats}
      <StatsPage />
    {:else if $showAccounts}
      <AccountsPage />
    {/if}
    <!-- SideBar -->
    <div
      class="relative bg-gray-700/90 left-0 border border-gray-600/40 h-full w-28 flex flex-col items-center rounded-l-xl overflow-hidden"
    >
      <div class="relative h-full w-full top-3 left-[2px] space-y-2">
        <label
          class="text-white font-bold p-0 rounded flex flex-col items-center uppercase w-[97%]"
        >
          <input
            type="radio"
            name="radio"
            value="overview"
            class="hidden peer"
            checked={$showOverview}
            on:change={() => {
              showOverview.set(true);
              showBills.set(false);
              showHistory.set(false);
              showHeav.set(false);
              showIndseat.set(false);
              showStats.set(false);
              showAccounts.set(false);
            }}
          />
          <span
            class="w-[97%] relative flex flex-col items-center text-gray-300 py-4 peer-checked:shadow-md transition-all duration-500 rounded-xl
              peer-checked:text-blue-400 peer-checked:shadow-lg hover:text-blue-300 duration-500 peer-checked:bg-gray-600 hover:cursor-pointer hover:bg-gray-800/80"
          >
            <i class="fa-duotone fa-house text-3xl text-blue-300 mb-2"></i>
            <span class="relative">{$Locales.overview}</span>
          </span>
        </label>
        <label
          class="text-white font-bold p-0 rounded flex flex-col items-center uppercase w-[97%]"
        >
          <input
            type="radio"
            name="radio"
            value="send"
            class="hidden peer"
            checked={$showBills}
            on:change={() => {
              showOverview.set(false);
              showBills.set(true);
              showHistory.set(false);
              showHeav.set(false);
              showIndseat.set(false);
              showStats.set(false);
              showAccounts.set(false);
            }}
          />
          <span
            class="w-[97%] relative flex flex-col items-center text-gray-300 py-4 peer-checked:shadow-md transition-all duration-500 rounded-xl
              peer-checked:text-blue-400 peer-checked:shadow-lg hover:text-blue-300 duration-500 peer-checked:bg-gray-600 hover:cursor-pointer hover:bg-gray-800/80"
          >
            <i class="fa-duotone fa-file-invoice text-3xl text-blue-300 mb-2"
            ></i>
            <span class="relative">{$Locales.bills}</span>
          </span>
        </label>
        <label
          class="text-white font-bold p-0 rounded flex flex-col items-center uppercase w-[97%]"
        >
          <input
            type="radio"
            name="radio"
            value="history"
            class="hidden peer"
            checked={$showHistory}
            on:change={() => {
              showOverview.set(false);
              showBills.set(false);
              showHistory.set(true);
              showHeav.set(false);
              showIndseat.set(false);
              showStats.set(false);
              showAccounts.set(false);
            }}
          />
          <span
            class="w-[97%] relative flex flex-col items-center text-gray-300 py-4 peer-checked:shadow-md transition-all duration-500 rounded-xl
              peer-checked:text-blue-400 peer-checked:shadow-lg hover:text-blue-300 duration-500 peer-checked:bg-gray-600 hover:cursor-pointer hover:bg-gray-800/80"
          >
            <i class="fa-duotone fa-circle-dollar text-3xl text-blue-300 mb-2"
            ></i>
            <span class="relative">{$Locales.history}</span>
          </span>
        </label>
        <label
          class="text-white font-bold p-0 rounded flex flex-col items-center uppercase w-[97%]"
        >
          <input
            type="radio"
            name="radio"
            value="control"
            class="hidden peer"
            checked={$showHeav}
            on:change={() => {
              showOverview.set(false);
              showBills.set(false);
              showHistory.set(false);
              showHeav.set(true);
              showIndseat.set(false);
              showStats.set(false);
              showAccounts.set(false);
            }}
          />
          <span
            class="w-[97%] relative flex flex-col items-center text-gray-300 py-4 peer-checked:shadow-md transition-all duration-500 rounded-xl
              peer-checked:text-blue-400 peer-checked:shadow-lg hover:text-blue-300 duration-500 peer-checked:bg-gray-600 hover:cursor-pointer hover:bg-gray-800/80"
          >
            <i class="fa-duotone fa-minus text-3xl text-blue-300 mb-2"></i>
            <span class="relative">{$Locales.withdraw}</span>
          </span>
        </label>
        <label
          class="text-white font-bold p-0 rounded flex flex-col items-center uppercase w-[97%]"
        >
          <input
            type="radio"
            name="radio"
            value="control"
            class="hidden peer"
            checked={$showIndseat}
            on:change={() => {
              showOverview.set(false);
              showBills.set(false);
              showHistory.set(false);
              showHeav.set(false);
              showIndseat.set(true);
              showStats.set(false);
              showAccounts.set(false);
            }}
          />
          <span
            class="w-[97%] relative flex flex-col items-center text-gray-300 py-4 peer-checked:shadow-md transition-all duration-500 rounded-xl
              peer-checked:text-blue-400 peer-checked:shadow-lg hover:text-blue-300 duration-500 peer-checked:bg-gray-600 hover:cursor-pointer hover:bg-gray-800/80"
          >
            <i class="fa-duotone fa-plus text-3xl text-blue-300 mb-2"></i>
            <span class="relative">{$Locales.deposit}</span>
          </span>
        </label>
        <label
          class="text-white font-bold p-0 rounded flex flex-col items-center uppercase w-[97%]"
        >
          <input
            type="radio"
            name="radio"
            value="control"
            class="hidden peer"
            checked={$showStats}
            on:change={() => {
              showOverview.set(false);
              showBills.set(false);
              showHistory.set(false);
              showHeav.set(false);
              showIndseat.set(false);
              showStats.set(true);
              showAccounts.set(false);
            }}
          />
          <span
            class="w-[97%] relative flex flex-col items-center text-gray-300 py-4 peer-checked:shadow-md transition-all duration-500 rounded-xl
              peer-checked:text-blue-400 peer-checked:shadow-lg hover:text-blue-300 duration-500 peer-checked:bg-gray-600 hover:cursor-pointer hover:bg-gray-800/80"
          >
            <i class="fa-duotone fa-chart-simple text-3xl text-blue-300 mb-2"
            ></i>
            <span class="relative">{$Locales.stats}</span>
          </span>
        </label>
        <label
          class="text-white font-bold p-0 rounded flex flex-col items-center uppercase w-[97%]"
        >
          <input
            type="radio"
            name="radio"
            value="control"
            class="hidden peer"
            checked={$showAccounts}
            on:change={() => {
              showOverview.set(false);
              showBills.set(false);
              showHistory.set(false);
              showHeav.set(false);
              showIndseat.set(false);
              showStats.set(false);
              showAccounts.set(true);
            }}
          />
          <span
            class="w-[97%] relative flex flex-col items-center text-gray-300 py-4 peer-checked:shadow-md transition-all duration-500 rounded-xl
              peer-checked:text-blue-400 peer-checked:shadow-lg hover:text-blue-300 duration-500 peer-checked:bg-gray-600 hover:cursor-pointer hover:bg-gray-800/80"
          >
            <i class="fa-duotone fa-users text-3xl text-blue-300 mb-2"></i>
            <span class="relative">{$Locales.accounts}</span>
          </span>
        </label>
        <!-- Close -->
        <div class="relative -bottom-48 left-[.5px]">
          <button
            class="w-[95%] text-blue-200 font-bold uppercase p-5 rounded-lg hover:bg-gray-800/80 duration-500 h-[100px] flex flex-col items-center"
            on:click={() => {
              fetchNui("ps-banking:client:hideUI");
              visibility.set(false);
            }}
          >
            <i class="fa-duotone fa-circle-xmark text-3xl text-blue-300 mb-2"
            ></i>
            <span class="relative">{$Locales.close}</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</div>
