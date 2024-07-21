<script lang="ts">
  import { writable } from "svelte/store";
  import { onMount } from "svelte";
  import Chart from "chart.js/auto";
  import { fetchNui } from "../utils/fetchNui";
  import { quintOut } from "svelte/easing";
  import { slide, fade, scale } from "svelte/transition";
  import {
    showOverview,
    showBills,
    showHistory,
    showHeav,
    notifications,
    Bills,
    Notify,
    Transactions,
    currentCash,
    bankBalance,
    Locales,
    Currency,
    type Notification,
  } from "../store/data";

  let notificationId = 0;
  let transactions = Bills;
  let phone = false;
  let showSureModalBills = writable(false);
  let showTransferModal = writable(false);
  let transferData = writable({
    idOrPhone: "",
    amount: 0,
    confirm: false,
    contactType: "none",
  });

  let weeklyData = writable({
    totalReceived: 0,
    totalUsed: 0,
  });

  let chart: Chart;
  let chartCanvas: HTMLCanvasElement;

  async function fetchWeeklySummary() {
    try {
      const response = await fetchNui("ps-banking:client:getWeeklySummary", {});
      if (response) {
        weeklyData.set(response);
      }
    } catch (error) {
      console.error(error);
    }
  }

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

  async function payAllBills() {
    const success = await fetchNui("ps-banking:client:payAllBills", {});
    if (success) {
      await getBills();
      Notify(
        $Locales.pay_all_bills_success,
        $Locales.payment_completed,
        "money-bill"
      );
    } else {
      Notify(
        $Locales.pay_all_bills_error,
        $Locales.error,
        "circle-exclamation"
      );
    }
  }

  function openModal() {
    showTransferModal.set(true);
  }

  function closeModal() {
    showTransferModal.set(false);
    transferData.set({
      idOrPhone: "",
      amount: 0,
      confirm: false,
      contactType: "none",
    });
  }

  async function getBills() {
    try {
      const response = await fetchNui("ps-banking:client:getBills", {});
      Bills.set(response);
    } catch (error) {
      console.error(error);
    }
  }

  async function getHistory() {
    try {
      const history = await fetchNui("ps-banking:client:getHistory", {});
      Transactions.set(history);
    } catch (error) {
      console.error(error);
    }
  }

  async function confirmTransfer(id: any, amount: any, method: any) {
    try {
      const response = await fetchNui("ps-banking:client:transferMoney", {
        id: id,
        amount: amount,
        method: method,
      });
      if (response.success) {
        Notify(response.message, $Locales.payment_completed, "user");
      } else {
        Notify(response.message, $Locales.error, "user");
      }
    } catch (error) {
      console.error(error);
    }
    transferData.update((data) => {
      data.confirm = true;
      return data;
    });
    showTransferModal.set(false);
    transferData.set({
      idOrPhone: "",
      amount: 0,
      confirm: false,
      contactType: "none",
    });
  }

  let bankData = {
    balance: $bankBalance,
    cash: $currentCash,
    transactions: $Transactions,
  };

  $: bankData = {
    balance: $bankBalance,
    cash: $currentCash,
    transactions: $Transactions,
  };

  async function heav() {
    try {
      const response = await fetchNui("ps-banking:client:ATMwithdraw", {
        amount: $bankBalance,
      });
      if (response) {
        updateStuff();
      }
    } catch (error) {
      console.error(error);
    }
  }

  async function deposit() {
    try {
      const response = await fetchNui("ps-banking:client:ATMdeposit", {
        amount: $currentCash,
      });
      if (response) {
        updateStuff();
      }
    } catch (error) {
      console.error(error);
    }
  }

  function createChart() {
    if (chartCanvas) {
      chart = new Chart(chartCanvas, {
        type: "bar",
        data: {
          labels: [$Locales.income, $Locales.expenses],
          datasets: [
            {
              label: $Locales.weekly_summary,
              data: [0, 0],
              backgroundColor: ["#3b82f6", "#ef4444"],
            },
          ],
        },
        options: {
          responsive: true,
          scales: {
            y: {
              beginAtZero: true,
            },
          },
        },
      });
    }
  }

  $: {
    weeklyData.subscribe((data) => {
      if (chart) {
        chart.data.datasets[0].data = [data.totalReceived, data.totalUsed];
        chart.update();
      }
    });
  }

  async function updateStuff() {
    // Hot update
    await getBills();
    await getHistory();
    await fetchWeeklySummary();
    await updateBalances();
  }
  
  async function phoneOption() {
    try {
      const response = await fetchNui("ps-banking:client:phoneOption", {});
      phone = response
    } catch (error) {
      console.error(error);
    }
  }

  onMount(async () => {
    createChart();
    updateStuff();
    updateStuff();
    phoneOption();
  });
</script>

<div class="absolute w-full h-full bg-gray-800">
  <div
    class="absolute top-0 left-[240px] w-screen h-screen overflow-hidden p-6 text-white"
    in:slide={{ duration: 1000, easing: quintOut }}
  >
    <!-- Quick Actions -->
    <div class="mb-8">
      <div class="text-xl mb-4 text-blue-200">{$Locales.total_balance}</div>
      <div class="text-3xl font-bold mb-8 text-blue-300">
        {$bankBalance.toLocaleString($Currency.lang, {
          style: "currency",
          currency: $Currency.currency,
          minimumFractionDigits: 0,
        })}
      </div>
    </div>
    <div class="mb-2">
      <div class="text-2xl mb-4 text-blue-200">{$Locales.quick_actions}</div>
      <div class="flex space-x-4">
        <div
          class="flex flex-col items-center bg-gray-700 rounded-xl p-4 w-[280px]"
        >
          <i
            class="fa-duotone fa-arrow-right-arrow-left text-4xl mb-2 text-blue-400"
          ></i>
          <div class="text-2xl font-bold mb-2 text-blue-200">
            {$Locales.transfer_money}
          </div>
          <div class="text-sm mb-2 text-gray-400">
            {$Locales.easy_transfer}
          </div>
          <button
            class="bg-blue-600/10 border border-blue-500 hover:bg-blue-800/50 text-white font-bold py-2 px-4 mt-4 duration-500 rounded-lg cursor-pointer"
            on:click={openModal}
          >
            {$Locales.transfer}
          </button>
        </div>
        <div
          class="flex flex-col items-center bg-gray-700 rounded-xl p-4 w-[280px]"
        >
          <i
            class="fa-duotone fa-file-invoice-dollar text-4xl mb-2 text-blue-400"
          ></i>
          <div class="text-2xl font-bold mb-2 text-blue-200">
            {$Locales.pay_bills}
          </div>
          <div class="text-sm mb-2 text-gray-400">
            {$Locales.pay_pending_bills}
          </div>
          <button
            class="relative -bottom-auto bg-blue-600/10 border border-blue-500 hover:bg-blue-800/50 text-white font-bold py-2 px-8 mt-4 duration-500 rounded-lg cursor-pointer"
            on:click={() => {
              showSureModalBills.set(true);
            }}
          >
            {$Locales.pay}
          </button>
        </div>
        <div
          class="flex flex-col items-center bg-gray-700 rounded-xl p-4 w-[280px]"
        >
          <i class="fa-duotone fa-credit-card text-4xl mb-2 text-blue-400"></i>
          <div class="text-2xl font-bold mb-2 text-blue-200">
            {$Locales.withdraw_all_money}
          </div>
          <div class="text-sm mb-2 text-gray-400">
            {$Locales.withdraw_all_from_account}
          </div>
          <button
            class="bg-blue-600/10 border border-blue-500 hover:bg-blue-800/50 text-white font-bold py-2 px-4 mt-4 duration-500 rounded-lg cursor-pointer"
            on:click={() => {
              if ($bankBalance <= 0) {
                Notify(
                  $Locales.no_money_on_account,
                  $Locales.error,
                  "credit-card"
                );
              } else {
                Notify(
                  $Locales.withdraw_all_success,
                  $Locales.success,
                  "credit-card"
                );
                setTimeout(() => {
                  heav();
                }, 200);
              }
            }}
          >
            {$Locales.withdraw}
          </button>
        </div>
        <div
          class="flex flex-col items-center bg-gray-700 rounded-xl p-4 w-[280px]"
        >
          <i class="fa-duotone fa-piggy-bank text-4xl mb-2 text-blue-400"></i>
          <div class="text-2xl font-bold mb-2 text-blue-200">
            {$Locales.deposit_cash}
          </div>
          <div class="text-sm mb-2 text-gray-400">
            {$Locales.deposit_all_cash}
          </div>
          <button
            class="bg-blue-600/10 border border-blue-500 hover:bg-blue-800/50 text-white font-bold py-2 px-4 mt-4 duration-500 rounded-lg cursor-pointer"
            on:click={() => {
              if ($currentCash <= 0) {
                Notify($Locales.no_cash_on_you, $Locales.error, "coins");
              } else {
                Notify($Locales.deposit_all_success, $Locales.success, "coins");
                setTimeout(() => {
                  deposit();
                }, 200);
              }
            }}
          >
            {$Locales.deposit}
          </button>
        </div>
      </div>
    </div>

    <!-- Lower Section -->
    <div class="flex space-x-4 mt-4">
      <!-- Weekly Summary -->
      <div class="bg-gray-700 rounded-xl p-6 w-[380px] h-[400px] flex-none">
        <div class="flex items-center mb-4">
          <i class="fa-duotone fa-calendar-week text-2xl text-blue-400 mr-2"
          ></i>
          <span class="text-blue-200 font-bold text-xl"
            >{$Locales.weekly_summary}</span
          >
        </div>
        <div
          class="space-y-4 border border-dashed border-blue-400 rounded-lg p-4"
        >
          <div class="flex justify-between border-b border-gray-600 pb-2">
            <span>{$Locales.income}</span>
            <span class="text-blue-400">
              {#if $weeklyData.totalReceived !== undefined}
                {$weeklyData.totalReceived.toLocaleString($Currency.lang, {
                  style: "currency",
                  currency: $Currency.currency,
                  minimumFractionDigits: 0,
                })}
              {:else}
                0
              {/if}
            </span>
          </div>
          <div class="flex justify-between border-b border-gray-600 pb-2">
            <span>{$Locales.expenses}</span>
            <span class="text-red-400">
              {#if $weeklyData.totalUsed !== undefined}
                {$weeklyData.totalUsed.toLocaleString($Currency.lang, {
                  style: "currency",
                  currency: $Currency.currency,
                  minimumFractionDigits: 0,
                })}
              {:else}
                0
              {/if}
            </span>
          </div>
          <div class="mt-6">
            <div class="flex items-center mb-2">
              <i class="fa-duotone fa-chart-bar text-xl text-blue-400 mr-2"></i>
              <span>{$Locales.report}</span>
            </div>
            <div>
              <canvas bind:this={chartCanvas}></canvas>
            </div>
          </div>
        </div>
      </div>

      <!-- Latest Transactions -->
      <div class="bg-gray-700 rounded-xl p-6 w-[380px] h-[400px] flex-none">
        <div class="flex justify-between items-center mb-4">
          <div class="flex items-center">
            <i class="fa-duotone fa-file-invoice text-2xl text-blue-400 mr-2"
            ></i>
            <span class="text-blue-200 font-bold text-xl"
              >{$Locales.latest_transactions}</span
            >
          </div>
          <div class="bg-gray-600 rounded-full px-2 py-1">
            <span class="text-white text-sm"
              >{bankData.transactions.length}</span
            >
          </div>
        </div>
        <div
          class="space-y-3 border border-dashed border-blue-400 rounded-lg p-4 h-[310px]"
        >
          {#if bankData.transactions.length > 0}
            {#each bankData.transactions.slice(0, 5) as transaction}
              <div class="space-y-2">
                <div class="flex justify-between">
                  <span class="truncate">{transaction.description}</span>
                  <p
                    class={`text-md font-bold ${transaction.isIncome ? "text-green-500" : "text-red-500"}`}
                  >
                    {transaction.isIncome ? "+" : "-"}
                    {transaction.amount.toLocaleString($Currency.lang, {
                      style: "currency",
                      currency: $Currency.currency,
                      minimumFractionDigits: 0,
                    })}
                  </p>
                </div>
                <div class="border-b border-gray-600"></div>
              </div>
            {/each}

            <div class="mt-6 flex justify-center">
              <button
                class="bg-blue-600/10 border border-blue-500 hover:bg-blue-800/50 text-white font-bold py-2 px-4 mt-4 duration-500 rounded-lg cursor-pointer"
                on:click={() => {
                  showOverview.set(false);
                  showBills.set(false);
                  showHistory.set(true);
                  showHeav.set(false);
                }}
              >
                {$Locales.see_all}
              </button>
            </div>
          {:else}
            <div class="p-4 text-center text-blue-200">
              <i class="fa-duotone fa-check-circle text-2xl mb-2"></i>
              <p>{$Locales.no_transactions}</p>
            </div>
          {/if}
        </div>
      </div>

      <div class="bg-gray-700 rounded-xl p-4 w-[380px] h-[400px] flex-none">
        <div class="flex justify-between items-center mb-2">
          <div class="flex items-center">
            <i class="fa-duotone fa-file-exclamation text-xl text-blue-400 mr-2"
            ></i>
            <span class="text-blue-200 font-bold text-lg"
              >{$Locales.unpaid_bills}</span
            >
          </div>
          <div class="bg-gray-600 rounded-full px-2 py-1">
            <span class="text-white text-sm">{$transactions.length}</span>
          </div>
        </div>
        <div
          class="space-y-0 border border-dashed border-blue-400 p-1 rounded-lg overflow-auto mt-6 h-[310px]"
        >
          {#if $transactions.length > 0}
            {#each $transactions.slice(0, 2) as transaction (transaction.id)}
              {#if !transaction.isPaid}
                <div class="p-2 rounded-lg flex justify-between items-center">
                  <div class="flex flex-col">
                    <div class="flex items-center">
                      <span class="font-semibold text-[#f1f5f9]"
                        >{transaction.description} #{transaction.id}</span
                      >
                    </div>
                    <div class="flex items-center mt-1">
                      <span class="text-sm text-gray-400"
                        >{transaction.type}</span
                      >
                    </div>
                    <div class="flex items-center mt-1">
                      <span class="text-xs text-gray-500"
                        >{transaction.timeAgo}</span
                      >
                    </div>
                  </div>
                  <div class="text-right flex flex-col items-end">
                    <span
                      class={`text-lg ${transaction.isIncome ? "text-green-400" : "text-red-400"}`}
                    >
                      {transaction.isIncome ? "+" : "-"}
                      {transaction.amount.toLocaleString($Currency.lang, {
                        style: "currency",
                        currency: $Currency.currency,
                        minimumFractionDigits: 0,
                      })}
                    </span>
                    <div class="flex items-center mt-0">
                      <div class="text-sm text-gray-400">
                        {transaction.date}
                      </div>
                    </div>
                  </div>
                </div>
                <div class="border-b border-gray-600"></div>
              {/if}
            {/each}
            <div class="mb-4 space-y-2 text-center">
              <div class="mt-[70px] flex justify-center">
                <button
                  class="bg-blue-600/10 border border-blue-500 hover:bg-blue-800/50 text-white font-bold py-2 px-4 duration-500 rounded-lg cursor-pointer"
                  on:click={() => {
                    showOverview.set(false);
                    showBills.set(true);
                    showHistory.set(false);
                    showHeav.set(false);
                  }}
                >
                  {$Locales.see_all}
                </button>
              </div>
            </div>
          {:else}
            <div class="p-4 text-center text-blue-200">
              <i class="fa-duotone fa-check-circle text-2xl mb-2"></i>
              <p>{$Locales.no_unpaid_bills}</p>
            </div>
          {/if}
        </div>
      </div>
    </div>
  </div>
  <!-- MODALS -->
  {#if $showTransferModal}
    <!-- svelte-ignore a11y-label-has-associated-control -->
    <div
      class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50"
    >
      <div
        class="p-8 bg-gray-800 rounded-lg shadow-lg w-96"
        in:scale={{ duration: 250, easing: quintOut }}
        out:scale={{ duration: 250, easing: quintOut }}
      >
        <div class="flex items-center mb-4">
          <i
            class="fa-duotone fa-arrow-right-arrow-left text-3xl text-blue-400 mr-3"
          ></i>
          <h2 class="text-2xl text-blue-200 font-bold">
            {$Locales.transfer_money}
          </h2>
        </div>

        <!-- Payment Method Selection -->
        <div class="mb-6">
          <p class="capitalize font-semibold text-blue-200 mb-2">
            {$Locales.payment_method}
          </p>
          <div class="flex flex-col space-y-4">
            {#if phone}
              <label
                class="flex items-center cursor-pointer bg-gray-700/50 rounded-lg p-3 border border-gray-600/20 hover:border-blue-400 transition duration-300"
              >
                <input
                  type="radio"
                  name="payment"
                  value="phone"
                  bind:group={$transferData.contactType}
                  class="hidden peer"
                />
                <i class="fa-duotone fa-phone text-lg text-blue-400 mr-3"></i>
                <span class="text-white font-bold">{$Locales.phone_number}</span
                >
                <div class="ml-auto hidden peer-checked:block">
                  <i class="fa-duotone fa-check-circle text-blue-400"></i>
                </div>
              </label>
            {/if}
            <label
              class="flex items-center cursor-pointer bg-gray-700/50 rounded-lg p-3 border border-gray-600/20 hover:border-blue-400 transition duration-300"
            >
              <input
                type="radio"
                name="payment"
                value="id"
                bind:group={$transferData.contactType}
                class="hidden peer"
              />
              <i class="fa-duotone fa-id-badge text-lg text-blue-400 mr-3"></i>
              <span class="text-white font-bold">{$Locales.id}</span>
              <div class="ml-auto hidden peer-checked:block">
                <i class="fa-duotone fa-check-circle text-blue-400"></i>
              </div>
            </label>
          </div>
        </div>

        <!-- ID or Phone Number Input -->
        {#if $transferData.contactType === "phone" || $transferData.contactType === "id"}
          <div class="mb-6">
            <label class="block text-gray-400 mb-2">
              <i class="fa-duotone fa-id-card text-blue-400 mr-2"></i>
              {#if phone}
                {$Locales.id_or_phone_number}
              {:else}
                {$Locales.id}
              {/if}
            </label>
            <div class="relative">
              <input
                type="number"
                min="1"
                class="w-full p-3 bg-gray-700/50 text-white pr-10 border border-blue-200/10 rounded-lg focus:outline-none
              focus:border-blue-400/50 transition-colors duration-500"
                bind:value={$transferData.idOrPhone}
              />
              <i
                class="fa-duotone fa-user absolute top-1/2 right-3 transform -translate-y-1/2 text-gray-400"
              ></i>
            </div>
          </div>
        {/if}

        <!-- Amount Input -->
        <div class="mb-6">
          <label class="block text-gray-400 mb-2">
            <i class="fa-duotone fa-money-bill-wave text-blue-400 mr-2"
            ></i>{$Locales.amount}
          </label>
          <div class="relative">
            <input
              type="number"
              min="1"
              class="w-full p-3 bg-gray-700/50 text-white pr-10 border border-blue-200/10 rounded-lg focus:outline-none
              focus:border-blue-400/50 transition-colors duration-500"
              bind:value={$transferData.amount}
            />
            <i
              class="fa-duotone fa-dollar-sign absolute top-1/2 right-3 transform -translate-y-1/2 text-gray-400"
            ></i>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="flex justify-between items-center mt-6">
          <button
            class="flex items-center bg-red-600 hover:bg-red-700 text-white py-2 px-4 rounded focus:outline-none"
            on:click={closeModal}
          >
            <i class="fa-duotone fa-times-circle mr-2"></i>{$Locales.cancel}
          </button>
          <button
            class="flex items-center bg-blue-600 hover:bg-blue-700 text-white py-2 px-4 rounded focus:outline-none"
            on:click={async () => {
              confirmTransfer(
                $transferData.idOrPhone,
                $transferData.amount,
                $transferData.contactType
              );
            }}
          >
            <i class="fa-duotone fa-check-circle mr-2"></i>{$Locales.confirm}
          </button>
        </div>
      </div>
    </div>
  {/if}
  {#if $showSureModalBills}
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
          {$Locales.confirm_pay_all_bills}
        </p>
        <div class="flex justify-between items-center">
          <button
            class="flex items-center bg-red-600 hover:bg-red-700 text-white py-2 px-4 rounded focus:outline-none"
            on:click={() => {
              showSureModalBills.set(false);
            }}
          >
            <i class="fa-duotone fa-times-circle mr-2"></i>{$Locales.cancel}
          </button>
          <button
            class="flex items-center bg-blue-600 hover:bg-blue-700 text-white py-2 px-4 rounded focus:outline-none"
            on:click={async () => {
              if ($transactions.length > 0) {
                await payAllBills();
                showSureModalBills.set(false);
              } else {
                showSureModalBills.set(false);
                Notify(
                  $Locales.pay_all_bills_error,
                  $Locales.error,
                  "circle-exclamation"
                );
              }
            }}
          >
            <i class="fa-duotone fa-check-circle mr-2"></i>{$Locales.confirm}
          </button>
        </div>
      </div>
    </div>
  {/if}
</div>
