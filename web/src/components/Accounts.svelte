<script lang="ts">
  import { writable, get, derived } from "svelte/store";
  import { slide, scale, fade } from "svelte/transition";
  import { quintOut } from "svelte/easing";
  import { Notify, type Notification, Locales, Currency } from "../store/data";
  import { fetchNui } from "../utils/fetchNui";
  import { onMount } from "svelte";
  let userData = writable({});
  let accounts = writable([]);
  let totalBalance = derived(accounts, ($accounts) =>
    $accounts.reduce((acc, account) => acc + account.balance, 0)
  );
  let showModal = writable(false);
  let showRenameModal = writable(false);
  let showCreateAccountModal = writable(false);
  let showDeleteModal = writable(false);
  let showRemoveUserModal = writable(false);
  let showWithdrawModal = writable(false);
  let showDepositModal = writable(false);
  let newServerId = writable("");
  let newAccountName = writable("");
  let newAccountHolder = writable("");
  let newAccountBalance = writable(0);
  let selectedAccount = writable<number | null>(null);
  let selectedUser = writable("");
  let transactionAmount = writable<number>(0);

  async function renameAccount(id: number) {
    const newName = get(newAccountName);
    if (newName) {
      try {
        const response = await fetchNui("ps-banking:client:renameAccount", {
          id,
          newName,
        });
        if (response.success) {
          accounts.update((accs) =>
            accs.map((acc) =>
              acc.id === id ? { ...acc, holder: newName } : acc
            )
          );
          newAccountName.set("");
          showRenameModal.set(false);
          getAccounts();
          Notify(
            $Locales.account_renamed_successfully,
            $Locales.success,
            "check-circle"
          );
        } else {
          Notify(
            $Locales.account_rename_failed,
            $Locales.error,
            "exclamation-circle"
          );
        }
      } catch (error) {
        console.error(error);
        Notify(
          $Locales.account_rename_failed,
          $Locales.error,
          "exclamation-circle"
        );
      }
    }
  }

  async function copyAccountNumber(id: number) {
    const account = get(accounts).find((acc) => acc.id === id);
    if (account) {
      await fetchNui("ps-banking:client:copyAccountNumber", {
        accountNumber: account.cardNumber,
      });
      Notify($Locales.account_number_copied, $Locales.success, "clipboard");
    }
  }

  async function addUserToAccount(accountId: number, userId: string) {
    try {
      const response = await fetchNui("ps-banking:client:addUserToAccount", {
        accountId,
        userId,
      });
      if (response.success) {
        accounts.update((accs) => {
          const updatedAccounts = accs.map((acc) => {
            if (acc.id === accountId) {
              return {
                ...acc,
                users: [
                  ...acc.users,
                  { name: response.userName, identifier: userId },
                ],
              };
            }
            return acc;
          });
          return updatedAccounts;
        });
        Notify(
          `${response.userName} ${$Locales.user_added_successfully}`,
          $Locales.success,
          "check-circle"
        );
        showModal.set(false);
        newServerId.set("0");
        getAccounts();
      } else {
        Notify(response.message, $Locales.error, "exclamation-circle");
      }
    } catch (error) {
      console.error(error);
      Notify(
        $Locales.user_addition_failed,
        $Locales.error,
        "exclamation-circle"
      );
    }
  }

  async function removeUserFromAccount() {
    const accountId = get(selectedAccount);
    const user = get(selectedUser);
    if (accountId !== null && user) {
      try {
        const response = await fetchNui(
          "ps-banking:client:removeUserFromAccount",
          { accountId, user }
        );
        if (response.success) {
          accounts.update((accs) => {
            const updatedAccounts = accs.map((acc) =>
              acc.id === accountId
                ? {
                    ...acc,
                    users: acc.users.filter((u) => u.identifier !== user),
                  }
                : acc
            );
            return updatedAccounts;
          });
          Notify(
            `${$Locales.removed_successfully}`,
            $Locales.success,
            "check-circle"
          );
          selectedUser.set("");
          showRemoveUserModal.set(false);
          getAccounts();
        } else {
          Notify(
            $Locales.user_removal_failed,
            $Locales.error,
            "exclamation-circle"
          );
        }
      } catch (error) {
        console.error(error);
        Notify(
          $Locales.user_removal_failed,
          $Locales.error,
          "exclamation-circle"
        );
      }
    } else {
      Notify(
        $Locales.select_account_and_user,
        $Locales.error,
        "exclamation-circle"
      );
    }
  }

  async function deleteAccount(accountId: number) {
    const response = await fetchNui("ps-banking:client:deleteAccount", {
      accountId,
    });
    if (response.success) {
      accounts.update((accs) => accs.filter((acc) => acc.id !== accountId));
      Notify(
        $Locales.account_deleted_successfully,
        $Locales.success,
        "check-circle"
      );
      showDeleteModal.set(false);
    } else {
      Notify(
        $Locales.account_deletion_failed,
        $Locales.error,
        "exclamation-circle"
      );
    }
  }

  function formatCardNumber(cardNumber: string): string {
    return cardNumber.match(/.{1,4}/g)?.join(" ") || cardNumber;
  }

  async function createNewAccount() {
    const holder = get(newAccountHolder);
    const balance = get(newAccountBalance);
    const newId = Math.max(...get(accounts).map((acc) => acc.id)) + 1;
    const rawCardNumber = Math.random().toString().slice(2, 18);
    const cardNumber = formatCardNumber(rawCardNumber);
    const newAccount = {
      id: newId,
      balance: balance,
      holder: holder,
      cardNumber: cardNumber,
      users: [],
      owner: {
        state: true,
        name: get(userData).name,
        identifier: get(userData).identifier,
      },
    };
    const response = await fetchNui("ps-banking:client:createNewAccount", {
      newAccount,
    });
    if (response.success) {
      accounts.update((accs) => [...accs, newAccount]);
      newAccountHolder.set("");
      newAccountBalance.set(0);
      showCreateAccountModal.set(false);
      getAccounts();
      Notify(
        $Locales.new_account_created_successfully,
        $Locales.success,
        "check-circle"
      );
    } else {
      Notify(
        $Locales.new_account_creation_failed,
        $Locales.error,
        "exclamation-circle"
      );
    }
  }

  async function withdrawFromAccount() {
    const accountId = get(selectedAccount);
    const amount = get(transactionAmount);
    if (accountId !== null && amount > 0) {
      const response = await fetchNui("ps-banking:client:withdrawFromAccount", {
        accountId,
        amount,
      });
      if (response.success) {
        accounts.update((accs) => {
          const updatedAccounts = accs.map((acc) =>
            acc.id === accountId && acc.balance >= amount
              ? { ...acc, balance: acc.balance - amount }
              : acc
          );
          return updatedAccounts;
        });
        Notify(
          `${$Locales.withdrew} ${amount} ${$Locales.successfully}`,
          $Locales.success,
          "check-circle"
        );
        transactionAmount.set(0);
        showWithdrawModal.set(false);
      } else {
        Notify(
          $Locales.withdrawal_failed,
          $Locales.error,
          "exclamation-circle"
        );
      }
    } else {
      Notify(
        $Locales.select_valid_account_and_amount,
        $Locales.error,
        "exclamation-circle"
      );
    }
  }

  async function depositToAccount() {
    const accountId = get(selectedAccount);
    const amount = get(transactionAmount);
    if (accountId !== null && amount > 0) {
      const response = await fetchNui("ps-banking:client:depositToAccount", {
        accountId,
        amount,
      });
      if (response.success) {
        accounts.update((accs) => {
          const updatedAccounts = accs.map((acc) =>
            acc.id === accountId
              ? { ...acc, balance: acc.balance + amount }
              : acc
          );
          return updatedAccounts;
        });
        Notify(
          `${$Locales.deposited} ${amount} ${$Locales.successfully}`,
          $Locales.success,
          "check-circle"
        );
        transactionAmount.set(0);
        showDepositModal.set(false);
      } else {
        Notify($Locales.deposit_failed, $Locales.error, "exclamation-circle");
      }
    } else {
      Notify(
        $Locales.select_valid_account_and_amount,
        $Locales.error,
        "exclamation-circle"
      );
    }
  }

  async function getUser() {
    try {
      const response = await fetchNui("ps-banking:client:getUser", {});
      userData.set(response);
    } catch (error) {
      console.error(error);
    }
  }

  async function getAccounts() {
    try {
      const response = await fetchNui("ps-banking:client:getAccounts", {});
      accounts.set(response);
    } catch (error) {
      console.error(error);
    }
  }

  onMount(() => {
    getUser();
    getAccounts();
  });
</script>

<div class="absolute w-full h-full bg-gray-800 text-white">
  <div
    class="absolute w-[90%] h-full p-6 overflow-auto left-[130px]"
    in:slide={{ duration: 1000, easing: quintOut }}
  >
    <div
      class="bg-gray-700/10 p-8 rounded-xl shadow-lg border border-blue-200/5"
    >
      <div class="text-5xl font-extrabold text-left text-blue-400 mb-10">
        <i class="fa-duotone fa-users text-3xl text-blue-200 mr-3"></i>
        {$Locales.accounts}
      </div>
      <div class="relative grid grid-cols-3 gap-y-10 gap-x-4 w-[90%]">
        {#each $accounts as account (account.id)}
          <div
            class="py-8 px-8 w-auto h-auto rounded-2xl shadow-lg flex flex-col justify-between bg-[#1c2333] text-blue-400 relative"
            out:fade={{ duration: 1000, easing: quintOut }}
          >
            <div class="flex justify-between items-center">
              <div class="text-2xl font-bold">
                {account.balance.toLocaleString($Currency.lang, {
                  style: "currency",
                  currency: $Currency.currency,
                  minimumFractionDigits: 0,
                })}
              </div>
              <div class="text-sm font-semibold">#{account.id}</div>
            </div>
            <div class="text-xl mt-2">{account.cardNumber}</div>
            <div class="flex justify-between items-center mt-4">
              <div class="text-lg">{account.owner.name} - {account.holder}</div>
              <div class="flex space-x-2">
                <button
                  class="text-gray-400 hover:text-blue-300 duration-500"
                  on:click={() => copyAccountNumber(account.id)}
                >
                  <i class="fa-duotone fa-copy"></i>
                </button>
                {#if account.owner.identifier === get(userData).identifier || account.users.some(user => user.identifier === get(userData).identifier)}
                  <button
                    class="text-gray-400 hover:text-blue-300 duration-500"
                    on:click={() => showRenameModal.set(account.id)}
                  >
                    <i class="fa-duotone fa-pen"></i>
                  </button>
                  {#if account.owner.identifier === get(userData).identifier}
                    <button
                      class="text-gray-400 hover:text-blue-300 duration-500"
                      on:click={() => showModal.set(account.id)}
                    >
                      <i class="fa-duotone fa-user-plus"></i>
                    </button>
                    <button
                      class="text-gray-400 hover:text-blue-300 duration-500"
                      on:click={() => {
                        selectedAccount.set(account.id);
                        selectedUser.set("");
                        showRemoveUserModal.set(true);
                      }}
                    >
                      <i class="fa-duotone fa-user-minus"></i>
                    </button>
                    
                      <button
                        class="text-red-400 hover:text-red-300 duration-500"
                        on:click={() => {
                        selectedAccount.set(account.id);
                        showDeleteModal.set(true);
                        }}
                      >
                        <i class="fa-duotone fa-trash"></i>
                      </button>
                  {/if}
                  <button
                    class="text-green-400 hover:text-green-300 duration-500"
                    on:click={() => {
                      selectedAccount.set(account.id);
                      showDepositModal.set(true);
                    }}
                  >
                    <i class="fa-duotone fa-arrow-up"></i>
                  </button>
                  <button
                    class="text-yellow-400 hover:text-yellow-300 duration-500"
                    on:click={() => {
                      selectedAccount.set(account.id);
                      showWithdrawModal.set(true);
                    }}
                  >
                    <i class="fa-duotone fa-arrow-down"></i>
                  </button>
                {/if}
              </div>
            </div>
          </div>
        {/each}
      </div>
      <button
        class="bg-[#1c2333] mt-6 py-8 px-8 w-[250px] h-[200px] rounded-2xl shadow-lg flex items-center justify-center cursor-pointer border border-dashed border-blue-400 hover:border-blue-600 transition-all duration-500"
        on:click={() => showCreateAccountModal.set(true)}
      >
        <i class="fa-duotone fa-plus text-4xl text-gray-200"></i>
      </button>
    </div>
  </div>
</div>

{#if $showModal}
  <div
    class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50"
  >
    <div
      class="bg-[#1c2333] p-8 rounded-lg shadow-2xl w-96 relative"
      in:scale={{ duration: 250, easing: quintOut }}
      out:scale={{ duration: 250, easing: quintOut }}
    >
      <h2 class="text-2xl font-bold text-blue-400 mb-4 flex items-center">
        <i class="fa-duotone fa-exchange-alt mr-2"></i>
        {$Locales.new_user_to_account}
      </h2>
      <div class="mb-4">
        <label class="block text-blue-400 mb-2" for="ServerID"
          >{$Locales.server_id}</label
        >
        <div class="relative">
          <input
            type="number"
            id="ServerID"
            bind:value={$newServerId}
            class="w-full bg-[#283040] text-white font-bold pl-4 pr-12 py-3 rounded-lg border border-blue-400 focus:outline-none focus:border-blue-600 transition-colors duration-500 placeholder-gray-500"
            placeholder="ID"
          />
          <i
            class="fa-duotone fa-id-card absolute top-1/2 right-4 transform -translate-y-1/2 text-blue-400"
          ></i>
        </div>
      </div>
      <div class="flex justify-center space-x-4">
        <button
          class="bg-red-600 text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-300"
          on:click={() => {
            showModal.set(false);
            newServerId.set(0);
          }}
        >
          <i class="fa-duotone fa-times-circle text-lg mr-2"></i>
          {$Locales.cancel}
        </button>
        <button
          class="bg-blue-600 text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-300"
          on:click={() => addUserToAccount(get(showModal), $newServerId)}
        >
          <i class="fa-duotone fa-check-circle text-lg mr-2"></i>
          {$Locales.add_user}
        </button>
      </div>
    </div>
  </div>
{/if}

{#if $showRenameModal}
  <div
    class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50"
  >
    <div
      class="bg-[#1c2333] p-8 rounded-lg shadow-2xl w-96 relative"
      in:scale={{ duration: 250, easing: quintOut }}
      out:scale={{ duration: 250, easing: quintOut }}
    >
      <h2 class="text-2xl font-bold text-blue-400 mb-4 flex items-center">
        <i class="fa-duotone fa-edit mr-2"></i>
        {$Locales.rename_account}
      </h2>
      <div class="mb-4">
        <label class="block text-blue-400 mb-2" for="AccountName"
          >{$Locales.new_account_name}</label
        >
        <div class="relative">
          <input
            type="text"
            id="AccountName"
            bind:value={$newAccountName}
            class="w-full bg-[#283040] text-white font-bold pl-4 pr-12 py-3 rounded-lg border border-blue-400 focus:outline-none focus:border-blue-600 transition-colors duration-500 placeholder-gray-500"
            placeholder={$Locales.new_name}
          />
          <i
            class="fa-duotone fa-pen-nib absolute top-1/2 right-4 transform -translate-y-1/2 text-blue-400"
          ></i>
        </div>
      </div>
      <div class="flex justify-center space-x-4">
        <button
          class="bg-red-600 text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-300"
          on:click={() => showRenameModal.set(false)}
        >
          <i class="fa-duotone fa-times-circle text-lg mr-2"></i>
          {$Locales.cancel}
        </button>
        <button
          class="bg-blue-600 text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-300"
          on:click={() => renameAccount(get(showRenameModal))}
        >
          <i class="fa-duotone fa-check-circle text-lg mr-2"></i>
          {$Locales.rename}
        </button>
      </div>
    </div>
  </div>
{/if}

{#if $showCreateAccountModal}
  <div
    class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50"
  >
    <div
      class="bg-[#1c2333] p-8 rounded-lg shadow-2xl w-96 relative"
      in:scale={{ duration: 250, easing: quintOut }}
      out:scale={{ duration: 250, easing: quintOut }}
    >
      <h2 class="text-2xl font-bold text-blue-400 mb-4 flex items-center">
        <i class="fa-duotone fa-plus mr-2"></i>
        {$Locales.create_new_account}
      </h2>
      <div class="mb-4">
        <label class="block text-blue-400 mb-2" for="AccountHolder"
          >{$Locales.account_holder}</label
        >
        <div class="relative">
          <input
            type="text"
            id="AccountHolder"
            bind:value={$newAccountHolder}
            class="w-full bg-[#283040] text-white font-bold pl-4 pr-12 py-3 rounded-lg border border-blue-400 focus:outline-none focus:border-blue-600 transition-colors duration-500 placeholder-gray-500"
            placeholder={$Locales.account_holder}
          />
          <i
            class="fa-duotone fa-user absolute top-1/2 right-4 transform -translate-y-1/2 text-blue-400"
          ></i>
        </div>
      </div>
      <div class="flex justify-center space-x-4">
        <button
          class="bg-red-600 text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-300"
          on:click={() => showCreateAccountModal.set(false)}
        >
          <i class="fa-duotone fa-times-circle text-lg mr-2"></i>
          {$Locales.cancel}
        </button>
        <button
          class="bg-blue-600 text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-300"
          on:click={createNewAccount}
        >
          <i class="fa-duotone fa-check-circle text-lg mr-2"></i>
          {$Locales.create}
        </button>
      </div>
    </div>
  </div>
{/if}

{#if $showDeleteModal}
  <div
    class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50"
  >
    <div
      class="bg-[#1c2333] p-8 rounded-lg shadow-2xl w-96 relative"
      in:scale={{ duration: 250, easing: quintOut }}
      out:scale={{ duration: 250, easing: quintOut }}
    >
      <h2 class="text-2xl font-bold text-red-400 mb-4 flex items-center">
        <i class="fa-duotone fa-exclamation-triangle mr-2"></i>
        {$Locales.delete_account}
      </h2>
      <p class="text-blue-400 mb-4">
        {$Locales.are_you_sure_you_want_to_delete_this_account}
      </p>
      <div class="flex justify-center space-x-4">
        <button
          class="bg-gray-600 text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-300"
          on:click={() => showDeleteModal.set(false)}
        >
          <i class="fa-duotone fa-times-circle text-lg mr-2"></i>
          {$Locales.cancel}
        </button>
        <button
          class="bg-red-600 text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-300"
          on:click={() => deleteAccount(get(selectedAccount))}
        >
          <i class="fa-duotone fa-check-circle text-lg mr-2"></i>
          {$Locales.delete}
        </button>
      </div>
    </div>
  </div>
{/if}

{#if $showRemoveUserModal}
  <div
    class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50"
  >
    <div
      class="bg-[#1c2333] p-8 rounded-lg shadow-2xl w-96 relative"
      in:scale={{ duration: 250, easing: quintOut }}
      out:scale={{ duration: 250, easing: quintOut }}
    >
      <h2 class="text-2xl font-bold text-blue-400 mb-4 flex items-center">
        <i class="fa-duotone fa-user-minus mr-2"></i>
        {$Locales.remove_user_from_account}
      </h2>
      <div class="mb-4">
        <label class="block text-blue-400 mb-2" for="UserSelect"
          >{$Locales.select_user}</label
        >
        <div class="relative">
          <select
            id="UserSelect"
            bind:value={$selectedUser}
            class="w-full bg-[#283040] text-white font-bold pl-4 pr-12 py-3 rounded-lg border border-blue-400 focus:outline-none focus:border-blue-600 transition-colors duration-500 placeholder-gray-500 appearance-none"
            style="background-image: none; -moz-appearance: none; -webkit-appearance: none;"
          >
            {#each $accounts.find((acc) => acc.id === $selectedAccount)?.users as user}
              <option
                value={user.identifier}
                class="bg-[#283040] text-white rounded-xl font-bold pl-4 pr-12 py-4 rounded-lg transition-colors duration-500 hover:bg-blue-300/20 hover:text-gray-200 border-b border-blue-200"
              >
                {user.name}
              </option>
            {/each}
          </select>
          <i
            class="fa-duotone fa-user absolute top-1/2 right-4 transform -translate-y-1/2 text-blue-400"
          ></i>
        </div>
      </div>
      <div class="flex justify-center space-x-4">
        <button
          class="bg-gray-600 text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-300"
          on:click={() => {
            showRemoveUserModal.set(false);
            selectedUser.set("");
          }}
        >
          <i class="fa-duotone fa-times-circle text-lg mr-2"></i>
          {$Locales.cancel}
        </button>
        <button
          class="bg-red-600 text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-300"
          on:click={removeUserFromAccount}
        >
          <i class="fa-duotone fa-check-circle text-lg mr-2"></i>
          {$Locales.remove}
        </button>
      </div>
    </div>
  </div>
{/if}

{#if $showWithdrawModal}
  <div
    class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50"
  >
    <div
      class="bg-[#1c2333] p-8 rounded-lg shadow-2xl w-96 relative"
      in:scale={{ duration: 250, easing: quintOut }}
      out:scale={{ duration: 250, easing: quintOut }}
    >
      <h2 class="text-2xl font-bold text-yellow-400 mb-4 flex items-center">
        <i class="fa-duotone fa-arrow-down mr-2"></i>
        {$Locales.withdraw_from_account}
      </h2>
      <div class="mb-4">
        <label class="block text-yellow-400 mb-2" for="WithdrawAmount"
          >{$Locales.withdraw_amount}</label
        >
        <div class="relative">
          <input
            type="number"
            id="WithdrawAmount"
            bind:value={$transactionAmount}
            class="w-full bg-[#283040] text-white font-bold pl-4 pr-12 py-3 rounded-lg border border-yellow-400 focus:outline-none focus:border-yellow-600 transition-colors duration-500 placeholder-gray-500"
            placeholder="0"
          />
          <i
            class="fa-duotone fa-dollar-sign absolute top-1/2 right-4 transform -translate-y-1/2 text-yellow-400"
          ></i>
        </div>
      </div>
      <div class="flex justify-center space-x-4">
        <button
          class="bg-gray-600 text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-300"
          on:click={() => {
            showWithdrawModal.set(false);
            transactionAmount.set(0);
          }}
        >
          <i class="fa-duotone fa-times-circle text-lg mr-2"></i>
          {$Locales.cancel}
        </button>
        <button
          class="bg-yellow-600 text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-300"
          on:click={withdrawFromAccount}
        >
          <i class="fa-duotone fa-check-circle text-lg mr-2"></i>
          {$Locales.withdraw}
        </button>
      </div>
    </div>
  </div>
{/if}

{#if $showDepositModal}
  <div
    class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50"
  >
    <div
      class="bg-[#1c2333] p-8 rounded-lg shadow-2xl w-96 relative"
      in:scale={{ duration: 250, easing: quintOut }}
      out:scale={{ duration: 250, easing: quintOut }}
    >
      <h2 class="text-2xl font-bold text-green-400 mb-4 flex items-center">
        <i class="fa-duotone fa-arrow-up mr-2"></i>
        {$Locales.deposit_to_account}
      </h2>
      <div class="mb-4">
        <label class="block text-green-400 mb-2" for="DepositAmount"
          >{$Locales.deposit_amount}</label
        >
        <div class="relative">
          <input
            type="number"
            id="DepositAmount"
            bind:value={$transactionAmount}
            class="w-full bg-[#283040] text-white font-bold pl-4 pr-12 py-3 rounded-lg border border-green-400 focus:outline-none focus:border-green-600 transition-colors duration-500 placeholder-gray-500"
            placeholder="0"
          />
          <i
            class="fa-duotone fa-dollar-sign absolute top-1/2 right-4 transform -translate-y-1/2 text-green-400"
          ></i>
        </div>
      </div>
      <div class="flex justify-center space-x-4">
        <button
          class="bg-gray-600 text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-300"
          on:click={() => {
            showDepositModal.set(false);
            transactionAmount.set(0);
          }}
        >
          <i class="fa-duotone fa-times-circle text-lg mr-2"></i>
          {$Locales.cancel}
        </button>
        <button
          class="bg-green-600 text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-300"
          on:click={depositToAccount}
        >
          <i class="fa-duotone fa-check-circle text-lg mr-2"></i>
          {$Locales.deposit}
        </button>
      </div>
    </div>
  </div>
{/if}
